//
//  GameScene.swift
//  PENDREAM
//
//  Created by ukn on 12/4/14.
//  Copyright (c) 2014 ukn. All rights reserved.
//

import SpriteKit


class GameScene: SKScene {
    
    // MARK: Property
    
    let 🐧 = SKSpriteNode()
    var radian: Double = 0
    
    // the framerate of stop motion animetion is 12 frames in a second
    let animationRate = 10
    var animeCounter = 0
    var animeState = 0
    
    
    var isOpenUmbrella = true
    
    
    // MARK: Setup
    
    override func didMoveToView(view: SKView) {
        
        🐧.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame) * 3 / 2)
        🐧.zRotation = 0
        self.addChild(🐧)
    }
    
    
    // MARK: Loop
    
    override func update(currentTime: CFTimeInterval) {
        
        //animation of Penguin including stopmotion and swing
        animatePenguin()
    }
    
    
    //🐧🐧🐧🐧🐧🐧🐧🐧🐧🐧
    
    func animatePenguin() {
        
        // swing 🐧
        🐧.zRotation = CGFloat(sin(radian) * M_PI / 20)
        🐧.position = CGPoint(x:CGRectGetMidX(self.frame) + CGFloat(sin(radian)) * CGRectGetMidX(self.frame)/3, y:🐧.position.y)
        println(CGFloat(sin(radian)))
        
        if isOpenUmbrella {
            radian += M_PI / 60
        }
        if radian > M_PI * 2 {
            radian = 0
        }
        
        // alternate Texture of 🐧 for stop motion Animation
        if isOpenUmbrella {
            alternateSpriteTexture(Sprite: 🐧, ImageName1: "penguin_open1", ImageName2: "penguin_open2")
        } else {
            alternateSpriteTexture(Sprite: 🐧, ImageName1: "penguin_close1", ImageName2: "penguin_close2")
        }
    }
    
    
    // MARK: Touch Event
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        isOpenUmbrella = false
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        isOpenUmbrella = true
    }
    
    
    // MARK: StopMotionAnimation
    
    // alternate Texture of a Sprite for stop motion animation
    
    func alternateSpriteTexture(Sprite sprite: SKSpriteNode, ImageName1 imageName1: String, ImageName2 imageName2: String) {
        
        if animeState < 1 {
            let tex1 = SKTexture(imageNamed: imageName1)
            sprite.texture = tex1
            sprite.size = tex1.size()
        } else {
            let tex2 = SKTexture(imageNamed: imageName2)
            sprite.texture = tex2
            sprite.size = tex2.size()
        }
        
        // alternate animeState by framerate
        calculateFrameAnimation()
    }
    
    // alternate animeState by framerate
    
    func calculateFrameAnimation() {
        
        if animeCounter < animationRate / 2 {
            animeState = 0
        } else if animeCounter < animationRate {
            animeState = 1
        } else {
            animeCounter = 0
        }
        
        animeCounter++
    }
}
