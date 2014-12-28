//
//  StartScene.swift
//  PENDREAM
//
//  Created by ukn on 12/10/14.
//  Copyright (c) 2014 ukn. All rights reserved.
//

import SpriteKit


class StartScene: SKScene {
    
    let titleSprite = SKSpriteNode()
    let startButtonSprite = SKSpriteNode()
    let rankingButtonSprite = SKSpriteNode()
    var touchButtonName: String? = nil
    
    let tapSound = Sound()
    let foldpaper = Sound()
    
    // MARK: Start
    
    override func didMoveToView(view: SKView) {
        
        // setup background
        let background = SKSpriteNode(imageNamed: "background")
        background.anchorPoint = CGPoint(x: 0, y: 0)
        self.addChild(background)
        
        
        // scessor
        let scessorSprite = SKSpriteNode(imageNamed: "st_scessor_l")
        scessorSprite.position = CGPoint(x: 0, y: CGRectGetMaxY(self.frame))
        scessorSprite.anchorPoint = CGPoint(x: 0, y: 0.6)
        self.addChild(scessorSprite)
        
        // scale
        let scaleSprite = SKSpriteNode(imageNamed: "st_scale_r")
        scaleSprite.position = CGPoint(x: CGRectGetMaxX(self.frame), y: CGRectGetMaxY(self.frame))
        scaleSprite.anchorPoint = CGPoint(x: 0.7, y: 1)
        self.addChild(scaleSprite)
        
        // pen
        let penSprite = SKSpriteNode(imageNamed: "st_pen_l")
        penSprite.position = CGPoint(x: 0, y: CGRectGetMidY(self.frame))
        penSprite.anchorPoint = CGPoint(x: 0.1, y: 0.65)
        self.addChild(penSprite)
        
        // erasorSprite
        let erasorSprite = SKSpriteNode(imageNamed: "st_erasor_r")
        erasorSprite.position = CGPoint(x: CGRectGetMaxX(self.frame), y: CGRectGetMidY(self.frame))
        erasorSprite.anchorPoint = CGPoint(x: 0.9, y: 0.65)
        self.addChild(erasorSprite)
        
        // logo
        alternateTexture(Sprite: titleSprite, ImageName1: "logo1", ImageName2: "logo2")
        titleSprite.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame) * 1.32)
        self.addChild(titleSprite)
        
        // Start Button
        alternateTexture(Sprite: startButtonSprite, ImageName1: "button_start1", ImageName2: "button_start2")
        startButtonSprite.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)*13/20)
        startButtonSprite.name = "start_button"
        startButtonSprite.zPosition = 2
        self.addChild(startButtonSprite)
        
        // Ranking Button
        alternateTexture(Sprite: rankingButtonSprite, ImageName1: "button_ranking1", ImageName2: "button_ranking2")
        rankingButtonSprite.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)*2/5)
        rankingButtonSprite.name = "ranking_button"
        startButtonSprite.zPosition = 2
        self.addChild(rankingButtonSprite)
        
        tapSound.prepareSound("tap")
    }
    
    
    // MARK: Loop
    
    override func update(currentTime: CFTimeInterval) {
        
    }
    
    
    
    // MARK: Event
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            touchButtonName = nodeAtPoint(location).name
            
            if touchButtonName == "start_button" {
                alternateTexture(Sprite: startButtonSprite, ImageName1: "button_start_on1", ImageName2: "button_start_on2")
                tapSound.playSound()
            } else if (touchButtonName == "ranking_button") {
                alternateTexture(Sprite: rankingButtonSprite, ImageName1: "button_ranking_on1", ImageName2: "button_ranking_on2")
                tapSound.playSound()
            }
        }
    }
    
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if touchButtonName == nodeAtPoint(location).name {
                
                if touchButtonName == "start_button" {
                    
                    let reveal = SKTransition.fadeWithColor(UIColor.whiteColor(), duration: 0.5)
                    let scene = GameScene()
                    scene.size = self.frame.size
                    scene.scaleMode = .AspectFill
                    self.view?.presentScene(scene, transition: reveal)
                    Flurry.logEvent("TapStartInStartScene")
                } else if (touchButtonName == "ranking_button") {
                    showScore()
                    Flurry.logEvent("TapRankingInStartScene")
                }
            }
        }
        
        alternateTexture(Sprite: startButtonSprite, ImageName1: "button_start1", ImageName2: "button_start2")
        alternateTexture(Sprite: rankingButtonSprite, ImageName1: "button_ranking1", ImageName2: "button_ranking2")
        
        touchButtonName = nil
    }
    
    
    func showScore() {
        NSNotificationCenter.defaultCenter().postNotificationName("showScore", object: nil, userInfo: nil)
    }
    
    // MARK: StopMotionAnimation
    
    // alternate Texture of a Sprite for stop motion animation
    
    func alternateTexture(Sprite sprite: SKSpriteNode, ImageName1 imageName1: String, ImageName2 imageName2: String) {
        let tex1 = SKTexture(imageNamed: imageName1)
        let tex2 = SKTexture(imageNamed: imageName2)
        let texArray = [tex1, tex2]
        sprite.size = tex1.size()
        sprite.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(texArray, timePerFrame: 0.1)))
    }
}