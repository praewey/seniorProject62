//
//  HandDetectMLViewController.swift
//  seniorProject62
//
//  Created by Praewey Spokkokkak on 10/1/2563 BE.
//  Copyright © 2563 Praewey Spokkokkak. All rights reserved.
//

import UIKit
import AVKit
import Vision
import AVFoundation

class HandDetectMLViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    
    var captureSession = AVCaptureSession()
    let synth = AVSpeechSynthesizer()
    var cameraPos = AVCaptureDevice.Position.front
    var captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: AVCaptureDevice.Position.back)
    var def_bright = UIScreen.main.brightness // Default screen brightness
    var old_char = ""
    var model = try? VNCoreMLModel(for: NumberImageClassifier().model)
    
    var lastResult = ""
    var duplicateResultCount = 0
    
    
    @IBOutlet weak var touchTranstationView: UIView!
    @IBOutlet weak var textTranslationView: UIView!
    @IBOutlet weak var detectView: UIView!
    @IBOutlet var predictLabel: UILabel!
    @IBOutlet weak var guidelineImageView: UIImageView!
    
    @IBOutlet weak var underline2View: UIView!
    @IBOutlet weak var underlineView: UIView!
    var underlineConstraints: [AnyObject]!
    @IBOutlet weak var textTranslationBtn: UIButton!
    
    
    @IBAction func stop_captureSession(_ sender: UIButton) {
        captureSession.stopRunning()
        synth.stopSpeaking(at: AVSpeechBoundary.immediate)
        UIApplication.shared.isIdleTimerDisabled = false
        UIScreen.main.brightness = def_bright
        let maintabbarViewController = self.storyboard?.instantiateViewController (identifier:Constants.Storyboard.MaintabbarViewController) as? MaintabbarViewController
        maintabbarViewController?.selectedIndex = 1
        self.view.window?.rootViewController = maintabbarViewController
        self.view.window?.resignKey()
    }
    
    @IBAction func change_camera(_ sender: Any) {
        captureSession.stopRunning()
        synth.stopSpeaking(at: AVSpeechBoundary.immediate)
        if cameraPos == AVCaptureDevice.Position.back{
            cameraPos = AVCaptureDevice.Position.front
        }else{
            if UIScreen.main.brightness != def_bright{
                UIScreen.main.brightness = def_bright
            }
            cameraPos = AVCaptureDevice.Position.back
        }
        if lightSwitch.isOn{
            lightSwitch.setOn(false, animated: true)
        }
        captureSession = AVCaptureSession()
        detectView.layer.sublayers?[0].removeFromSuperlayer()
        old_char = ""
        self.viewDidLoad()
    }
    @IBOutlet var lightSwitch: UISwitch!
    @IBAction func change_light(_ sender: UISwitch) {
        if cameraPos == AVCaptureDevice.Position.back{
            try? captureDevice?.lockForConfiguration()
            if sender.isOn{
                try? captureDevice?.setTorchModeOn(level: 1.0)
            }else{
                captureDevice?.torchMode = .off
            }
            captureDevice?.unlockForConfiguration()
        }else{
            if sender.isOn{
                def_bright = UIScreen.main.brightness
                UIScreen.main.brightness = CGFloat(1)
            }else{
                UIScreen.main.brightness = def_bright
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        UIApplication.shared.isIdleTimerDisabled = true // Deactivate sleep mode
        guidelineImageView.isHidden = false
        underline2View.isHidden = true
        
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        captureSession.sessionPreset = .photo
        
        captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPos)
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice!) else {return}
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        detectView.layer.insertSublayer(previewLayer, at: 0)
        previewLayer.frame = detectView.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        textTranslationView.layer.cornerRadius = 15
        textTranslationView.clipsToBounds = true
        
        //        touchTranstationView.layer.cornerRadius = 15
        //        touchTranstationView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        //        touchTranstationView.clipsToBounds = true
        
        
        //        let touchTranstationView = UIView(frame: CGRect(x: 30, y: 676, width: 354, height: 60))
        touchTranstationView.backgroundColor = .white
        touchTranstationView.layer.shadowPath = UIBezierPath(rect: touchTranstationView.bounds).cgPath
        touchTranstationView.layer.shadowColor = UIColor.black.cgColor
        touchTranstationView.layer.shadowOpacity = 0.1
        touchTranstationView.layer.shadowOffset = .zero
        touchTranstationView.layer.shadowRadius = 10
        
        //
        //        view.addSubview(touchTranstationView)
        
        //.layerMinXMinYCorner = Top left corner
        //.layerMaxXMinYCorner = Top right corner
        //.layerMinXMaxYCorner = Bottom left corner
        //.layerMaxXMaxYCorder = Bottom right corner
        
    }
    
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
        NotificationCenter.default.removeObserver(self)
        
    }
    
    
    @IBAction func touchTextBtn(_ sender: Any) {
        model = try? VNCoreMLModel(for: NumberImageClassifier().model)
        underlineView.isHidden = false
        underline2View.isHidden = true
        
        predictLabel.text = ""
    }
    
    @IBAction func touchAlphabetBtn(_ sender: Any) {
        model = try? VNCoreMLModel(for: ASLImageClassifierAE30().model)
        underlineView.isHidden = true
        underline2View.isHidden = false
        
        predictLabel.text = ""
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        
        connection.videoOrientation = AVCaptureVideoOrientation.portrait
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        
        
        let request = VNCoreMLRequest(model: model!){ (fineshedReq, err) in
            
            guard let results = fineshedReq.results as? [VNClassificationObservation] else {return}
            guard let firstObservation = results.first else {return}
            
            // print(firstObservation.identifier, firstObservation.confidence)
            DispatchQueue.main.async {
                if firstObservation.confidence < 0.9 {
                    
                    // For secondary vocalization
                    self.old_char = ""
                    
                    if self.underline2View.isHidden {
                        self.predictLabel.text = ""
                    }
                    
                    
                    //                    DispatchQueue.main.asyncAfter(deadline: .now() + 5 ) {
                    //                        self.guidelineImageView.isHidden = false
                    //                    }
                    //                    self.guidelineImageView.isHidden = true
                    
                } else if self.old_char != String(firstObservation.identifier) && firstObservation.confidence > 0.9 {
                    self.guidelineImageView.isHidden = true
                    
                    print(String(firstObservation.identifier) + " " + String(firstObservation.confidence) + " \(self.duplicateResultCount)")
                    
                    if String(firstObservation.identifier) == self.lastResult {
                        self.duplicateResultCount += 1
                        
                        if self.duplicateResultCount >= 5 {
                            if self.underline2View.isHidden {
                                self.predictLabel.text = String(firstObservation.identifier)
                            } else {
                                self.predictLabel.text! += String(firstObservation.identifier)
                            }
                            
                            let utterance = AVSpeechUtterance(string: String(firstObservation.identifier))
                            utterance.voice = AVSpeechSynthesisVoice(language: "th-TH")
                            
                            self.synth.stopSpeaking(at: AVSpeechBoundary.immediate) // For mute the previous speak.
                            self.synth.speak(utterance)
                            self.old_char = String(firstObservation.identifier)
                            
                            self.lastResult = ""
                            self.duplicateResultCount = 0
                        }
                    } else {
                        self.lastResult = String(firstObservation.identifier)
                        self.duplicateResultCount = 0
                    }
                    //utterance.voice = AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())
                }
            }
            
        }
        
        request.imageCropAndScaleOption = .centerCrop
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

