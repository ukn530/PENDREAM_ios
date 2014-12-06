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
    
    // property of Obstacle
    let 🐱s = [SKSpriteNode(), SKSpriteNode(), SKSpriteNode(), SKSpriteNode()]
    let obstacleNameArray = ["st_pen_l", "st_pen_r", "st_erasor_l", "st_erasor_r","st_scale_l", "st_scale_r", "st_scessor_l", "st_scessor_r"]
    var previousObstacleY = CGFloat(0)
    let speedObstacle = CGFloat(4)
    
    // the framerate of stop motion animetion is 12 frames in a second
    let animationRate = 10
    var animeCounter = 0
    var animeState = 0
    
    var isOpenUmbrella = true
    
    
    // MARK: Setup
    
    override func didMoveToView(view: SKView) {
        
        // setup background
        let background = SKSpriteNode(imageNamed: "background")
        background.anchorPoint = CGPoint(x: 0, y: 0)
        self.addChild(background)
        
        // setup 🐧
        resetPenguin()
        self.addChild(🐧)
        
        // setup 🐱
        for 🐱 in 🐱s {
            resetObstacle(Sprite: 🐱)
            previousObstacleY = 🐱.position.y
            self.addChild(🐱)
        }
    }
    
    
    // MARK: Loop
    
    override func update(currentTime: CFTimeInterval) {
        
        // animation of Penguin including stopmotion and swing
        animatePenguin()
        
        // animation of Obstacle
        animateObstacle()
    }
    
    
    // 🐧🐧🐧🐧🐧🐧🐧🐧🐧🐧
    
    func animatePenguin() {
        
        // swing 🐧
        🐧.zRotation = CGFloat(sin(radian) * M_PI / 20)
        🐧.position = CGPoint(x: CGRectGetMidX(self.frame) + CGFloat(sin(radian)) * CGRectGetMidX(self.frame) * 4 / 5, y: 🐧.position.y)
        
        if isOpenUmbrella {
            radian += M_PI / 50
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
    
    
    // 🐱🐱🐱🐱🐱🐱🐱🐱🐱🐱
    
    func animateObstacle() {
        
        for i in 0...🐱s.count-1 {
            
            // move to bottom from top
            if isOpenUmbrella {
                🐱s[i].position.y += speedObstacle
            } else {
                🐱s[i].position.y += speedObstacle * 2
            }
            
            // when gone from view
            if 🐱s[i].position.y > CGRectGetHeight(self.frame) {
                
                if i > 0 {
                    previousObstacleY = 🐱s[i-1].position.y
                } else {
                    previousObstacleY = 🐱s[i+🐱s.count-1].position.y
                }
                resetObstacle(Sprite: 🐱s[i])
            }
        }
    }
    
    
    
    // MARK: setting
    
    // reset 🐧's texture and position
    func resetPenguin() {
        
        🐧.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame) * 3 / 2)
        let tex = SKTexture(imageNamed: "penguin_open1")
        🐧.texture = tex
        🐧.size = tex.size()
        🐧.zRotation = 0
    }
    
    // reset 🐱's texture and position
    
    func resetObstacle(Sprite 🐱: SKSpriteNode) {
        
        var rand = Int(arc4random_uniform(UInt32(8)))
        var tex = SKTexture(imageNamed: obstacleNameArray[rand])
        🐱.texture = tex
        🐱.size = tex.size()
        
        if rand%2 == 0 {
            🐱.position = CGPoint(x:0, y:previousObstacleY - 🐱.size.height - 🐧.size.height)
            🐱.anchorPoint = CGPoint(x:0, y:0)
        } else {
            🐱.position = CGPoint(x:CGRectGetMaxX(self.frame), y:previousObstacleY - 🐱.size.height - 🐧.size.height)
            🐱.anchorPoint = CGPoint(x:1.0, y:0)
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
