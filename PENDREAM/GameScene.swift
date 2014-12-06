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
    
    // propety of penguin
    let 🐧 = SKSpriteNode()
    var radian: Double = 0
    
    // property of substacle
    let 🐱s = [SKSpriteNode(), SKSpriteNode(), SKSpriteNode(), SKSpriteNode()]
    let substacleNameArray = ["st_pen_l", "st_pen_r", "st_erasor_l", "st_erasor_r","st_scale_l", "st_scale_r", "st_scessor_l", "st_scessor_r"]
    
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
        
        for 🐱 in 🐱s {
            🐱.position = CGPoint(x:0, y:CGRectGetMaxY(self.frame))
            let tex = SKTexture(imageNamed: substacleNameArray[0])
            🐱.texture = tex
            🐱.size = tex.size()
            🐱.anchorPoint = CGPoint(x:0, y:0)
            self.addChild(🐱)
        }
        
        println("🐱s[0]x = \(🐱s[0].position.x)")
        println("🐱s[0]width = \(🐱s[0].size.width)")
        println("🐱s[0]height = \(🐱s[0].size.height)")
        println("🐱s[0]anchorX = \(🐱s[0].anchorPoint.x)")
        
        println("CGRectGetMidX = \(CGRectGetMidX(self.frame))")
        println("CGRectGetMidY = \(CGRectGetMidY(self.frame))")
        println("CGRectGetMaxX = \(CGRectGetMaxX(self.frame))")
        println("CGRectGetMaxY = \(CGRectGetMaxY(self.frame))")
        println("CGRectGetWidth = \(CGRectGetWidth(self.frame))")
        println("CGRectGetHeight = \(CGRectGetHeight(self.frame))")
    }
    
    
    // MARK: Loop
    
    override func update(currentTime: CFTimeInterval) {
        
        for i in 0...🐱s.count-1 {
            🐱s[i].position.y -= CGRectGetHeight(self.frame) * 0.01
            
            if 🐱s[i].position.y < -🐱s[i].size.height {
                var rand = Int(arc4random_uniform(UInt32(8)))
                var tex = SKTexture(imageNamed: substacleNameArray[rand])
                🐱s[i].texture = tex
                🐱s[i].size = tex.size()
                
                if i != 0 {
                    if rand % 2 == 0 {
                        🐱s[i].position = CGPoint(x:0, y:🐱s[i-1].position.y + 🐱s[i-1].size.height + 🐧.size.height * 1.2)
                        🐱s[i].anchorPoint = CGPoint(x:0, y:0)
                    } else {
                        🐱s[i].position = CGPoint(x:CGRectGetMaxX(self.frame), y:🐱s[i-1].position.y + 🐱s[i-1].size.height + 🐧.size.height * 1.2)
                        🐱s[i].anchorPoint = CGPoint(x:1.0, y:0)
                    }
                } else {
                    if rand & 2 == 0 {
                        🐱s[i].position = CGPoint(x:0, y:🐱s[i+🐱s.count-1].position.y + 🐱s[i+🐱s.count-1].size.height + 🐧.size.height * 1.2)
                        🐱s[i].anchorPoint = CGPoint(x:0, y:0)
                    } else {
                        🐱s[i].position = CGPoint(x:CGRectGetMaxX(self.frame), y:🐱s[i+🐱s.count-1].position.y + 🐱s[i+🐱s.count-1].size.height + 🐧.size.height * 1.2)
                        🐱s[i].anchorPoint = CGPoint(x:1.0, y:0)
                    }
                    
                }
                
            }
        }
        
        

        //animation of Penguin including stopmotion and swing
        animatePenguin()
    }
    
    
    //🐧🐧🐧🐧🐧🐧🐧🐧🐧🐧
    
    func animatePenguin() {
        
        // swing 🐧
        🐧.zRotation = CGFloat(sin(radian) * M_PI / 20)
        🐧.position = CGPoint(x:CGRectGetMidX(self.frame) + CGFloat(sin(radian)) * CGRectGetMidX(self.frame)/3, y:🐧.position.y)
        
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
