//
//  SearchViewController.swift
//  seniorProject62
//
//  Created by Praewey Spokkokkak on 28/12/2562 BE.
//  Copyright © 2562 Praewey Spokkokkak. All rights reserved.
//

import UIKit
import AVFoundation
import Speech
import Firebase
import Alamofire

class SearchViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var loadingView: UIImageView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var adView: UIView!
    @IBOutlet weak var btnView: UIView!
    @IBOutlet weak var speechLabel: UILabel!
    @IBOutlet weak var speechBtn: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var fakeTextField: UITextField!
    @IBOutlet weak var playAgainBtn: UIButton!
    
    var player: AVQueuePlayer!
    var playerLayer: AVPlayerLayer!
    
    var isSpeech: Bool = false
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "th-TH"))//แปลงเสียงเป็น text
    let request = SFSpeechAudioBufferRecognitionRequest() //แปลง buffer เป็นเสียง
    var recognitionTask: SFSpeechRecognitionTask?//ตัวจัดการการแปลงเสียงเป็น text
    var audioInputNode: AVAudioInputNode?
    
    var currentVideoIndex: Int = 0//เก็บ index เพื่อดูว่าวีดีเล่นที่ไหนแล้ว
    var cutWords: [String] = []
    var realWords: [String] = []
    
    var isCallAPI: Bool = false // มีการเรียก API ไปหรือยัง
    var isCancelAPI: Bool = false // มีการยกเลิก API ไปยัง
    
    var adPlayer: AVPlayer!
    var adPlayerLayer: AVPlayerLayer!
    
    let db = Firestore.firestore()
    
    func updateUnreadMessage() {
        db.collection("activities").getDocuments { query, error in
            self.db.collection("reads").whereField("email", isEqualTo: Auth.auth().currentUser?.email ?? "").getDocuments { queryRead, errorRead in
                
                let reads = queryRead!.documents
                var unreadCount = 0
                if reads.count > 0 {
                    unreadCount = query!.count - (reads.first!.data()["reads"] as! [String]).count
                } else {
                    unreadCount = query!.count
                }
                
                if unreadCount > 0 {
                    self.tabBarController?.tabBar.items?[2].badgeValue = "\(unreadCount)"
                } else {
                    self.tabBarController?.tabBar.items?[2].badgeValue = nil
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUnreadMessage()
        
        //loadingView.isHidden = true
        self.videoView.backgroundColor = UIColor(patternImage: UIImage(named: "bgfuncSpeech2.jpg")!)
        speechBtn.layer.cornerRadius = speechBtn.frame.height / 2
        speechBtn.clipsToBounds = true
        
        player = AVQueuePlayer()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill //ขนาดคลิป
        
        videoView.layer.addSublayer(playerLayer)
        
        fakeTextField.inputAccessoryView = searchTextField
        
        let tapVideo = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        videoView.addGestureRecognizer(tapVideo)
        
        let tapAd = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        adView.addGestureRecognizer(tapAd)
        
        searchTextField.delegate = self
        
        playAgainBtn.isHidden = true
        
        adPlayer = AVPlayer(url: URL(fileURLWithPath: Bundle.main.path(forResource: "support", ofType: "mov")!))
        adPlayerLayer = AVPlayerLayer(player: adPlayer)
        adPlayerLayer.videoGravity = .resizeAspectFill
        adView.layer.addSublayer(adPlayerLayer)
        
        adView.isHidden = true // ซ่อน ad ไว้
    }
    
    
    
    @objc func hideKeyboard() {
        searchTextField.resignFirstResponder()
        fakeTextField.resignFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = videoView.bounds
        adPlayerLayer.frame = adView.bounds
    }
    
    
    //
    @IBAction func touchSpeech(_ sender: Any) {
        //animation
        //        let pulse = PauseAnimation(nemberOfPulses: Float.infinity, radius: 50, position: (sender as AnyObject).center)
        //        pulse.animationDuration = 1.0
        //        pulse.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        //        self.btnView.layer.insertSublayer(pulse, below: self.btnView.layer)
        //
        //        let pulse1 = PauseAnimation(nemberOfPulses: Float.infinity, radius: 20, position: (sender as AnyObject).center)
        //        pulse1.animationDuration = 1.5
        //        pulse1.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        //        self.btnView.layer.insertSublayer(pulse1, below: self.btnView.layer)
        
        isCancelAPI = false
        
        if !isCallAPI && player.items().count == 0 {
            if !isSpeech {
                speechLabel.text = ""
                
                if SFSpeechRecognizer.authorizationStatus() == .notDetermined {
                    SFSpeechRecognizer.requestAuthorization { status in
                        if status == .authorized {
                            self.startRecording()
                            
                        } else {
                            print("ปฏิเสธการใช้ไมค์")
                        }
                    }
                }
                
                if SFSpeechRecognizer.authorizationStatus() == .authorized {
                    startRecording()
                }//อนุญาตแล้ว
                
            } else {
                stopRecording()
                searchText(text: speechLabel.text!)
            }
        } else {
            touchCancel(self)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.touchSpeech(self)
            }
        }
    }
    
    @IBAction func touchPlayAgain(_ sender: Any) {
        if realWords.count > 0 && player.items().count == 0 {
            currentVideoIndex = 0
            
            prepareResultVideo(texts: realWords)
            playResultVideo()
            highlighttWord(index: currentVideoIndex)
        }
    }
    
    @IBAction func touchKeyboard(_ sender: Any) {
        if !isCallAPI && player.items().count == 0 {
            searchTextField.text = cutWords.joined(separator: "")
        } else {
            searchTextField.text = ""
        }
        
        fakeTextField.becomeFirstResponder()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.searchTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func touchCancel(_ sender: Any) {
        //
        if adView.isHidden || !playAgainBtn.isHidden {
            stopRecording()
            
            loadingView.isHidden = true
            
            isCancelAPI = true
            isCallAPI = false // ไม่เรียก API
            
            //ยกเลิกการเล่นวีดีโอภาษามือ
            NotificationCenter.default.removeObserver(self)
            player.pause()
            player.removeAllItems()
            
            speechLabel.text = ". . ." //
            cutWords.removeAll()
            realWords.removeAll()
            
            adView.isHidden = true
            playAgainBtn.isHidden = true
        }
    }
    
    func startRecording() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, options: AVAudioSession.CategoryOptions.mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { }
        
        isSpeech = true
        speechBtn.setBackgroundImage(UIImage(named: "record"), for: .normal)
        
        audioInputNode = audioEngine.inputNode //รับไมโครโฟน
        let recordingFormat = audioInputNode?.outputFormat(forBus: 0)//
        
        audioInputNode?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()//เช็คปัญหาไมโครโฟน
        } catch {
            print(error)
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let error = error  {
                print(error)
            }
            
            if let text = result?.bestTranscription {
                self.speechLabel.text = text.formattedString
            }//bestTranscription
            
        })
    }
    
    func stopRecording() {
        audioInputNode?.removeTap(onBus: 0)
        audioEngine.stop()
        request.endAudio()
        recognitionTask?.cancel()
        
        isSpeech = false
        speechBtn.setBackgroundImage(UIImage(named: "microphonBtn"), for: .normal)
    }
    
    func resetCallAPI() {
        
    }//ยกเลิกการเรียก API ทั้งหมด
    
    //ส่งข้อความที่รับจากเสียงหรือคีย์บอร์ดไปตัดคำ
    func searchText(text: String) {
        isCancelAPI = false //ยกเลิก การยกเลิก API
        isCallAPI = true // กำลังเรียก API
        currentVideoIndex = 0
        
        loadingView.isHidden = false
        loadingView.loadGif(name: "loading")
        
        let url = "http://ec2-3-17-128-156.us-east-2.compute.amazonaws.com:5000/cut?word=\(text)"
        let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        //encodedUrl การเข้ารหัส เหมือนการซิปไฟล์ก่อนที่จะส่งไฟล์ไป
        Alamofire.request(encodedUrl!).response { response in
            let decoder = JSONDecoder()
            do {
                // ตัดคำ
                let data = try decoder.decode(WordCut.self, from: response.data!)
                self.speechLabel.text = data.cut.joined(separator: " ")
                self.cutWords = data.cut
                
                if !self.isCancelAPI {
                    
                    //หา tag
                    self.db.collection("words").getDocuments { query, error in
                        
                        if !self.isCancelAPI {
                            
                            if let error = error {
                                print(error)
                            } else {
                                self.realWords = []
                                
                                for cutWord in self.cutWords {
                                    var found: Bool = false
                                    
                                    for word in query!.documents {
                                        let data = word.data()
                                        
                                        for tag in data["tags"] as! NSArray {
                                            if tag as! String == cutWord {
                                                self.realWords.append(data["text"] as! String)
                                                found = true
                                                break
                                            }
                                        }
                                    }
                                    
                                    if !found {
                                        self.realWords.append(cutWord)
                                    }
                                }
                                
                                self.loadingView.isHidden = true
                                self.prepareResultVideo(texts: self.realWords)
                                self.playResultVideo()
                                self.highlighttWord(index: self.currentVideoIndex)
                            }
                        }// self.isCancelAPI
                        
                    }
                }//isCancelAPI
                
            } catch {
                print(error)
            }
        }
    }
    
    func resetCurrentVideo() {
        
    }
    
    func prepareResultVideo(texts: [String]) {
        var items: [AVPlayerItem] = []
        for text in texts {
            let bundlePath = Bundle.main.path(forResource: text, ofType: "mov")
            guard let _bundlePath = bundlePath else {
                let url = URL(fileURLWithPath: Bundle.main.path(forResource: "warning", ofType: "mov")!)
                let item = AVPlayerItem(url: url)
                items.append(item)
                
                self.player.insert(item, after: nil)
                
                continue
            }
            
            let url = URL(fileURLWithPath: _bundlePath)
            let item = AVPlayerItem(url: url)
            items.append(item)
            
            self.player.insert(item, after: nil)
        }
    }
    
    func playResultVideo() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.didVideoEnd(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.items().first)
        player.play()
        
        playAgainBtn.isHidden = true
        adView.isHidden = true // ซ่อน ad เมื่อ ad จบ
        isCallAPI = false
    }
    
    @objc func didVideoEnd(note: NSNotification) {
        NotificationCenter.default.removeObserver(self)
        
        currentVideoIndex += 1
        if player.items().count > 1 {
            NotificationCenter.default.addObserver(self, selector: #selector(self.didVideoEnd(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.items()[1])
            
            highlighttWord(index: currentVideoIndex)
            
        } else if player.items().count > 0 {
            NotificationCenter.default.addObserver(self, selector: #selector(self.didVideoEnd(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.items()[0])
            
            let att = NSMutableAttributedString(string: speechLabel.text!)
            speechLabel.attributedText = att
            
            NotificationCenter.default.addObserver(self, selector: #selector(didAdEnd(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: adPlayer.currentItem)
            adView.isHidden = false // แสดง ad
            adPlayer.play()
            
            db.collection("ad-views").addDocument(data: ["view": Date()])
        }
    }
    
    @objc func didAdEnd(note: NSNotification) {
        playAgainBtn.isHidden = false
    }
    
    func highlighttWord(index: Int) {
        let s = speechLabel.text! as NSString
        let att = NSMutableAttributedString(string: speechLabel.text!)
        
        let r = s.range(of: cutWords[index], options: .caseInsensitive)
        let color = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        att.addAttribute(.foregroundColor, value: color, range: r)
        
        speechLabel.attributedText = att
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // เช็ควีดีโอจบหรือยัง
        if !isCallAPI && player.items().count == 0 {
            touchCancel(self)
            
            searchText(text: searchTextField.text!)
        } else {
            touchCancel(self)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.searchText(text: self.searchTextField.text!)
            }
        }
        
        hideKeyboard()
        
        return true
    }
}
