//
//  StartScene.swift
//  PENDREAM
//
//  Created by ukn on 12/10/14.
//  Copyright (c) 2014 ukn. All rights reserved.
//

import SpriteKit


class StartScene: SKScene {
    
    let startButtonSprite = SKSpriteNode()
    let rankingButtonSprite = SKSpriteNode()
    var touchButtonName: String? = nil
    
    let tapSound = Sound()
    let foldpaper = Sound()
    
    // MARK: Start
    
    override func didMoveToView(view: SKView) {
        
        // setup background
        let background = SKSpriteNode()
        alternateTexture(Sprite: background, ImageName1: "top", ImageName2: "top2")
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.zPosition = 0
        self.addChild(background)
        
        // Start Button
        alternateTexture(Sprite: startButtonSprite, ImageName1: "button_start1", ImageName2: "button_start2")
        startButtonSprite.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)/2)
        startButtonSprite.name = "start_button"
        startButtonSprite.zPosition = 2
        self.addChild(startButtonSprite)
        
        // Ranking Button
        alternateTexture(Sprite: rankingButtonSprite, ImageName1: "button_ranking1", ImageName2: "button_ranking2")
        rankingButtonSprite.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)/4)
        rankingButtonSprite.name = "ranking_button"
        rankingButtonSprite.zPosition = 2
        self.addChild(rankingButtonSprite)
        
        if CGRectGetHeight(UIScreen.mainScreen().bounds) < 568 {
            startButtonSprite.position.y = CGRectGetMidY(self.frame)*2/3
        }
        if CGRectGetHeight(UIScreen.mainScreen().bounds) < 568 {
            rankingButtonSprite.position.y = CGRectGetMidY(self.frame)*9/20
        }
        
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