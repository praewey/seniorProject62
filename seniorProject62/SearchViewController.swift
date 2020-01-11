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
    
    @IBOutlet weak var videoView: UIView!
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
    
    var isCallAPI: Bool = false
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.videoView.backgroundColor = UIColor(patternImage: UIImage(named: "bgfuncSpeech2.jpg")!)
        
        player = AVQueuePlayer()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill //ขนาดคลิป
        
        videoView.layer.addSublayer(playerLayer)
        
        fakeTextField.inputAccessoryView = searchTextField
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        videoView.addGestureRecognizer(tap)
        
        searchTextField.delegate = self
        
        playAgainBtn.isHidden = true
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
    }
    
    
    //
    @IBAction func touchSpeech(_ sender: Any) {
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
        }
    }
    
    @IBAction func touchReplay(_ sender: Any) {
        if realWords.count > 0 && player.items().count == 0 {
            currentVideoIndex = 0
            
            prepareResultVideo(texts: realWords)
            playResultVideo()
            highlighttWord(index: currentVideoIndex)
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
            
            fakeTextField.becomeFirstResponder()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.searchTextField.becomeFirstResponder()
            }
        }
    }
    
    func startRecording() {
        isSpeech = true
        speechBtn.setBackgroundImage(UIImage(named: "micselect"), for: .normal)
        
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
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, _ in
            if let text = result?.bestTranscription {
                self.speechLabel.text = text.formattedString
            }
            
        })
    }
    
    func stopRecording() {
        audioInputNode?.removeTap(onBus: 0)
        audioEngine.stop()
        request.endAudio()
        recognitionTask?.cancel()
        
        isSpeech = false
        speechBtn.setBackgroundImage(UIImage(named: "mic"), for: .normal)
        
    }
    
    func resetCallAPI() {
        
    }//ยกเลิกการเรียก API ทั้งหมด
    
    func searchText(text: String) {
        isCallAPI = true
        currentVideoIndex = 0
        
        let url = "http://ec2-3-17-128-156.us-east-2.compute.amazonaws.com:5000/cut?word=\(text)"
        let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        Alamofire.request(encodedUrl!).response { response in
            let decoder = JSONDecoder()
            do {
                let data = try decoder.decode(WordCut.self, from: response.data!)
                self.speechLabel.text = data.cut.joined(separator: " ")
                self.cutWords = data.cut
                
//  APIcancel
                
                self.db.collection("words").getDocuments { query, error in
                    
                    //  APIcancel
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
                        
                        self.prepareResultVideo(texts: self.realWords)
                        self.playResultVideo()
                        self.highlighttWord(index: self.currentVideoIndex)
                        
                        //  APIcancel
                    }
                }
                
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
        isCallAPI = false
    }
    
    @objc func didVideoEnd(note: NSNotification) {
        NotificationCenter.default.removeObserver(self)
        
        currentVideoIndex += 1
        if player.items().count > 1 {
            NotificationCenter.default.addObserver(self, selector: #selector(self.didVideoEnd(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.items()[1])
            
            highlighttWord(index: currentVideoIndex)
            
        } else if player.items().count > 0 {
            NotificationCenter.default.addObserver(self, selector: #selector(self.didVideoEnd(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.items()[0])
            
            let att = NSMutableAttributedString(string: speechLabel.text!)
            speechLabel.attributedText = att
            
            playAgainBtn.isHidden = false
        }
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
        searchText(text: searchTextField.text!)
        
        hideKeyboard()
        
        return true
    }
}
