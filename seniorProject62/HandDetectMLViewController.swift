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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSession()
    }
    
    @IBAction func CameraTapped(_ sender: Any) {

    }
    
    func setupSession() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        let session = AVCaptureSession()
        session.sessionPreset = .hd4K3840x2160
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.frame
        detectView.layer.addSublayer(previewLayer)
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        
        // Sets the input of the AVCaptureSession to the device's camera input
        session.addInput(input)
        session.addOutput(output)
        
        
        // Starts the capture session
        session.startRunning()
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
                if mostConfidenceResult.confidence >= 0.99 {
                    let confidenceText = "\n\(Int(mostConfidenceResult.confidence * 100.0))% confidence"
                    
                    switch mostConfidenceResult.identifier {
                    case "A":
                        self.textTranslateLabel.text = "A \(confidenceText)"
                    case "B":
                        self.textTranslateLabel.text = "B \(confidenceText)"
                    case "C":
                        self.textTranslateLabel.text = "C \(confidenceText)"
                    case "D":
                        self.textTranslateLabel.text = "D \(confidenceText)"
                    case "E":
                        self.textTranslateLabel.text = "E \(confidenceText)"
                    case "F":
                        self.textTranslateLabel.text = "F \(confidenceText)"
                    case "G":
                        self.textTranslateLabel.text = "G \(confidenceText)"
                    case "H":
                        self.textTranslateLabel.text = "H \(confidenceText)"
                    case "I":
                        self.textTranslateLabel.text = "I \(confidenceText)"
                    case "J":
                        self.textTranslateLabel.text = "J \(confidenceText)"
                    case "K":
                        self.textTranslateLabel.text = "K \(confidenceText)"
                    case "L":
                        self.textTranslateLabel.text = "L \(confidenceText)"
                    case "M":
                        self.textTranslateLabel.text = "M \(confidenceText)"
                    case "N":
                        self.textTranslateLabel.text = "N \(confidenceText)"
                    case "O":
                        self.textTranslateLabel.text = "O \(confidenceText)"
                    case "P":
                        self.textTranslateLabel.text = "P \(confidenceText)"
                    case "Q":
                        self.textTranslateLabel.text = "Q \(confidenceText)"
                    case "R":
                        self.textTranslateLabel.text = "R \(confidenceText)"
                    case "S":
                        self.textTranslateLabel.text = "S \(confidenceText)"
                    case "T":
                        self.textTranslateLabel.text = "T \(confidenceText)"
                    case "U":
                        self.textTranslateLabel.text = "U \(confidenceText)"
                    case "V":
                        self.textTranslateLabel.text = "V \(confidenceText)"
                    case "W":
                        self.textTranslateLabel.text = "W \(confidenceText)"
                    case "X":
                        self.textTranslateLabel.text = "X \(confidenceText)"
                    case "Y":
                        self.textTranslateLabel.text = "Y \(confidenceText)"
                    case "Z":
                        self.textTranslateLabel.text = "Z \(confidenceText)"
                    default:
                        return
                    }
                } else {
                    self.textTranslateLabel.text = "กำลังประมวลผล!"
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
