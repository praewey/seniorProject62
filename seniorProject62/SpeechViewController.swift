//
//  SpeechViewController.swift
//  seniorProject62
//
//  Created by Praewey Spokkokkak on 20/12/2562 BE.
//  Copyright © 2562 Praewey Spokkokkak. All rights reserved.
//

import UIKit
import AVKit

class SpeechViewController: UIViewController {
    
    
    var videoPlayer : AVPlayer?
    var videoPlayerLayer : AVPlayerLayer?
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupVideo()
    }
    
    func setupVideo() {
        
        //get path in bundlePath
        let bundlePath = Bundle.main.path(forResource: "deaf", ofType: "mp4")
        guard bundlePath != nil
            else {
                return
        }
        
        //create url from it
        let url = URL(fileURLWithPath: bundlePath!)
        
        //create video item
        let item = AVPlayerItem(url:url)
        
        //create player
        videoPlayer = AVPlayer (playerItem: item)
        
        //create layer
        videoPlayerLayer = AVPlayerLayer (player: videoPlayer!)
        
        //adjust size and frame
        videoPlayerLayer?.frame = CGRect(x:0, y:0,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height)
        view.layer.insertSublayer(videoPlayerLayer!, at: 0)
        
        
        //add to the view and play it
        videoPlayer?.playImmediately(atRate: 1)
        
        
    }

}
