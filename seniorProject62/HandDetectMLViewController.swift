//
//  HandDetectMLViewController.swift
//  seniorProject62
//
//  Created by Praewey Spokkokkak on 10/1/2563 BE.
//  Copyright © 2563 Praewey Spokkokkak. All rights reserved.
//

import UIKit
import AVKit
import CoreML
import Vision

class HandDetectMLViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var detectView: UIView!
    @IBOutlet weak var textTranslateLabel: UILabel!
    
    @IBOutlet weak var testTextField: UITextField!
    
    var translateText: String = ""
    var timer: Timer?
    var block: Bool = false
    var isBackCamera: Bool = true
    var session: AVCaptureSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSession()
    }
    
    @IBAction func CameraTapped(_ sender: Any) {
        session.beginConfiguration()
        
        if isBackCamera {
            let currentInput = session.inputs.first!
            session.removeInput(currentInput)
            
            let deviceSession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
            for device in deviceSession.devices {
                if device.position == .front {
                    guard let input = try? AVCaptureDeviceInput(device: device) else { return }
                    
                    session.addInput(input)
                    
                    break
                }
            }
        }
        session.commitConfiguration()
    }
    
    @IBAction func touchDelete(_ sender: Any) {
        testTextField.text = ""
        textTranslateLabel.text = ""
        translateText = ""
    }
    
    @IBAction func testChanged(_ sender: Any) {
        textTranslateLabel.text = translate(input: testTextField.text ?? "")
    }
    
    func translate(input: String) -> String {
        var output = input
        for text in HandToThai.mapC.keys {
            output = output.uppercased().replacingOccurrences(of: text, with: HandToThai.mapC[text]!)
        }
        for text in HandToThai.mapU.keys {
            output = output.uppercased().replacingOccurrences(of: text, with: HandToThai.mapU[text]!)
        }
        for text in HandToThai.mapT.keys {
            output = output.uppercased().replacingOccurrences(of: text, with: HandToThai.mapT[text]!)
        }
        
        return output
    }
    
    func setupSession() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        session = AVCaptureSession()
//        session.sessionPreset = .hd4K3840x2160
        session.sessionPreset = .hd1920x1080
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.frame
        detectView.layer.insertSublayer(previewLayer, at: 0)
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        
        // Sets the input of the AVCaptureSession to the device's camera input
        session.addInput(input)
        session.addOutput(output)
        
        // Starts the capture session
        session.startRunning()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            self.block = false
        })
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let sampleBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        scanImage(buffer: sampleBuffer)
    }
    
    func scanImage(buffer: CVPixelBuffer) {
        guard let model = try? VNCoreMLModel(for: ASLImageClassifier().model) else {return}
        let request = VNCoreMLRequest(model: model) { (data, error) in
            // Checks if the data is in the correct format and assigns it to results
            guard let results = data.results as? [VNClassificationObservation] else { return }
            guard let mostConfidenceResult = results.first else { return }
            
            DispatchQueue.main.sync {
                if mostConfidenceResult.confidence >= 0.80 {
                    let confidenceText = "\n\(Int(mostConfidenceResult.confidence * 100.0))% confidence"
                    
                    if mostConfidenceResult.identifier != "nothing" && !self.block {
                        self.translateText += mostConfidenceResult.identifier
                        self.textTranslateLabel.text = self.translate(input: self.translateText)
                        
                        self.block = true
                    }
                    
                    //                    switch mostConfidenceResult.identifier {
                    //                    case "A":
                    //                        self.translateText = "A \(confidenceText)"
                    //                    case "B":
                    //                        self.translateText = "B \(confidenceText)"
                    //                    case "C":
                    //                        self.translateText = "C \(confidenceText)"
                    //                    case "D":
                    //                        self.translateText = "D \(confidenceText)"
                    //                    case "E":
                    //                        self.translateText = "E \(confidenceText)"
                    //                    case "F":
                    //                        self.translateText = "F \(confidenceText)"
                    //                    case "G":
                    //                        self.translateText = "G \(confidenceText)"
                    //                    case "H":
                    //                        self.translateText = "H \(confidenceText)"
                    //                    case "I":
                    //                        self.translateText = "I \(confidenceText)"
                    //                    case "J":
                    //                        self.translateText = "J \(confidenceText)"
                    //                    case "K":
                    //                        self.translateText = "K \(confidenceText)"
                    //                    case "L":
                    //                        self.translateText = "L \(confidenceText)"
                    //                    case "M":
                    //                        self.translateText = "M \(confidenceText)"
                    //                    case "N":
                    //                        self.translateText = "N \(confidenceText)"
                    //                    case "O":
                    //                        self.translateText = "O \(confidenceText)"
                    //                    case "P":
                    //                        self.translateText = "P \(confidenceText)"
                    //                    case "Q":
                    //                        self.translateText = "Q \(confidenceText)"
                    //                    case "R":
                    //                        self.translateText = "R \(confidenceText)"
                    //                    case "S":
                    //                        self.translateText = "S \(confidenceText)"
                    //                    case "T":
                    //                        self.translateText = "T \(confidenceText)"
                    //                    case "U":
                    //                        self.translateText = "U \(confidenceText)"
                    //                    case "V":
                    //                        self.translateText = "V \(confidenceText)"
                    //                    case "W":
                    //                        self.translateText = "W \(confidenceText)"
                    //                    case "X":
                    //                        self.translateText = "X \(confidenceText)"
                    //                    case "Y":
                    //                        self.translateText = "Y \(confidenceText)"
                    //                    case "Z":
                    //                        self.translateText = "Z \(confidenceText)"
                    //                    default:
                    //                        return
                    //                    }
                } else {
//                    self.textTranslateLabel.text = "กำลังประมวลผล!"
                }
            }
        }
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: buffer, options: [:])
        do {
            try requestHandler.perform([request])
        } catch {
            print(error)
        }
    }
}
