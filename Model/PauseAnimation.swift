//
//  PauseAnimation.swift
//  seniorProject62
//
//  Created by Praewey Spokkokkak on 16/1/2563 BE.
//  Copyright © 2563 Praewey Spokkokkak. All rights reserved.
//

import Foundation
import UIKit

class PauseAnimation: CALayer {
    var animationGroup = CAAnimationGroup()
    var animationDuration: TimeInterval = 1.5
    var radius :CGFloat = 50
    var nemberOfPulses: Float = 5
    
    override init(layer: Any){
        super.init(layer: layer)
    }
    
    required init?(coder aDecolor: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(nemberOfPulses: Float = 10, radius: CGFloat, position: CGPoint) {
        super.init()
        self.backgroundColor = UIColor.black.cgColor
        self.contentsScale = UIScreen.main.scale
        self.opacity = 0
        self.radius = radius
        self.nemberOfPulses = nemberOfPulses
        self.position = position
        
        self.bounds = CGRect(x: 0, y: 0, width: radius*2, height: radius*2)
        self.cornerRadius = radius
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            self.setupAnimationGroup()
            DispatchQueue.main.sync {
                self.add(self.animationGroup, forKey: "pulse")
            }
        }
    }
    
    func scaleAnimation() -> CABasicAnimation {
        let scaleAnimation = CABasicAnimation(keyPath: "tranfrom.scale.xy")
        scaleAnimation.fromValue = NSNumber(value: 0)
        scaleAnimation.toValue = NSNumber(value: 1)
        scaleAnimation.duration = animationDuration
        return scaleAnimation
    }
    
    func createOpacityAnimation() -> CAKeyframeAnimation{
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.duration = animationDuration
        opacityAnimation.keyTimes = [0.2, 0.3, 0]
        opacityAnimation.values = [0.4, 0.8, 0.5]
//        opacityAnimation.isRemovedOnCompletion = false
        return opacityAnimation
    }
    
    func setupAnimationGroup() {
        self.animationGroup.duration = animationDuration
        self.animationGroup.repeatCount = nemberOfPulses
        let defaultCure = CAMediaTimingFunction(name: .default)
        self.animationGroup.timingFunction = defaultCure
        self.animationGroup.animations = [scaleAnimation(), createOpacityAnimation()]
    }
}

