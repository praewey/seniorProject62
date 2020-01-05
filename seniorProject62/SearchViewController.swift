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

class SearchViewController: UIViewController,UISearchBarDelegate {
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var speechTextField: UITextField!
    @IBOutlet weak var speechBtn: UIButton!
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    var isSpeech: Bool = false
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "th-TH"))//แปลงเสียงเป็น text
    let request = SFSpeechAudioBufferRecognitionRequest() //แปลง buffer เป็นเสียง
    var recognitionTask: SFSpeechRecognitionTask?//ตัวจัดการการแปลงเสียงเป็น text
    var audioInputNode: AVAudioInputNode?
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.endEditing(true) //keyboard
        
        player = AVPlayer()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill //ขนาดคลิป
        
        videoView.layer.addSublayer(playerLayer)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        player.play()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = videoView.bounds
    }
    

    //
    @IBAction func touchSpeech(_ sender: Any) {
        if !isSpeech {
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
            searchText(text: speechTextField.text!)
        }
        
    }
    
    @IBAction func touchSearch(_ sender: Any) {
        searchText(text: speechTextField.text!)
    }
    
    @IBAction func touchCancel(_ sender: Any) {
        stopRecording()
        speechTextField.text = ""
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
                self.speechTextField.text = text.formattedString
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
    
    func searchText(text: String) {
        db.collection("words").getDocuments { query, error in
            if let error = error {
                print(error)
            } else {
                var _text = text
                
                for word in query!.documents {
                    let data = word.data()
                    
                    for tag in data["tags"] as! NSArray {
                        if tag as! String == text {
                            _text = data["text"] as! String
                            break
                        }
                    }
                }
                
                let bundlePath = Bundle.main.path(forResource: _text, ofType: "mov")
                guard let _bundlePath = bundlePath else {
                        print("ไม่เจอ")
                        return
                }
                
                let url = URL(fileURLWithPath: _bundlePath)
                let item = AVPlayerItem(url: url)
                self.player.replaceCurrentItem(with: item)
                self.player.play()
            }
        }
        

    }
    
}
