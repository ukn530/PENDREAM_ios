//
//  GameScene.swift
//  PENDREAM
//
//  Created by ukn on 12/4/14.
//  Copyright (c) 2014 ukn. All rights reserved.
//

import SpriteKit
//import GameViewController


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: Property
    
    // propety of penguin
    let 🐧 = SKSpriteNode()
    var radian: Double = 0
    var overCounter = CGFloat(0)
    
    // property of Obstacle
    let 🐱s = [SKSpriteNode(), SKSpriteNode(), SKSpriteNode(), SKSpriteNode()]
    let obstacleNameArray = ["st_pen_l", "st_pen_r", "st_erasor_l", "st_erasor_r","st_scale_l", "st_scale_r", "st_scessor_l", "st_scessor_r", "fd_banana_l", "fd_banana_r", "fd_bread_l", "fd_bread_r", "fd_chocolate_l", "fd_chocolate_r", "fd_pasta_l", "fd_pasta_r", "an_ant_l", "an_ant_r", "an_cat_l", "an_cat_r", "an_cow_l", "an_cow_r", "an_whale_l", "an_whale_r", "sa_daibutsu_l", "sa_daibutsu_r", "sa_moai_l", "sa_moai_r", "sa_sphinx_l", "sa_sphinx_r", "sa_venus_l", "sa_venus_r", "tw_eiffel_l", "tw_eiffel_r", "tw_empire_l", "tw_empire_r", "tw_sagrada_l", "tw_sagrada_r", "tw_touhoh_l", "tw_touhoh_r"]
    var previousObstacleY = CGFloat(0)
    let speedObstacle = CGFloat(4)
    var acceration = CGFloat(1)
    
    // the framerate of stop motion animetion is 12 frames in a second
    let animationRate = 10
    var animeCounter = 0
    var animeState = 0
    
    var isOpenUmbrella = true
    
    // category for collision test
    let penguinCategory: UInt32 = 0x1 << 0
    let obstacleCategory: UInt32 = 0x1 << 1
    
    // property of Score
    let counterSmallSpriteArray = [SKSpriteNode(), SKSpriteNode(), SKSpriteNode(), SKSpriteNode()]
    var isCountable = true
    var score = 0
    var bestScore = 0
    
    let scoreSpriteArray = [SKSpriteNode(), SKSpriteNode(), SKSpriteNode(), SKSpriteNode()]
    let bestSpriteArray = [SKSpriteNode(), SKSpriteNode(), SKSpriteNode(), SKSpriteNode()]
    
    // gameover
    var goY = CGFloat(0)
    let gameoverTitle = SKSpriteNode()
    let board = SKSpriteNode()
    let scoreText = SKSpriteNode(imageNamed: "score")
    let bestText = SKSpriteNode(imageNamed: "best")
    let twButton = SKSpriteNode(imageNamed: "button_twitter")
    let fbButton = SKSpriteNode(imageNamed: "button_facebook")
    let startButton = SKSpriteNode()
    let rankingButton = SKSpriteNode()
    let backButton = SKSpriteNode(imageNamed: "button_back")
    let noadButton = SKSpriteNode(imageNamed: "button_noads")
    
    var touchButtonName: String? = nil
    
    // gameState
    let GAME_PLAY = 0
    let GAME_OVER = 1
    var gameState = 0
    
    var isPurchased: Bool = false
    
    
    // MARK: Setup
    
    override func didMoveToView(view: SKView) {
        
        // setup background
        let background = SKSpriteNode(imageNamed: "background")
        background.anchorPoint = CGPoint(x: 0, y: 0)
        self.addChild(background)
       
        // setup collision
        self.physicsWorld.contactDelegate = self
        
        // setup 🐧
        resetPenguin()
        self.addChild(🐧)
        
        // setup 🐱
        for 🐱 in 🐱s {
            resetObstacle(Sprite: 🐱)
            previousObstacleY = 🐱.position.y
            self.addChild(🐱)
        }
        
        // setup counter
        var x = 0
        for num in counterSmallSpriteArray {
            let tex = SKTexture(imageNamed: "num0s")
            num.position = CGPoint(x: 10 + tex.size().width * CGFloat(x), y: CGRectGetMaxY(self.frame) - 10)
            num.size = tex.size()
            num.anchorPoint = CGPoint(x:0, y:1)
            num.zPosition = 2
            self.addChild(num)
            x++
        }
        resetScore(spriteArray: counterSmallSpriteArray, left: true, score: 0)
        
        // setup gameover
        goY = -CGRectGetMaxY(self.frame)
        setupGameover()
        
        NSNotificationCenter.defaultCenter().postNotificationName("getPlay", object: nil, userInfo: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "purchased:", name: "purchased", object: nil)

    }
    
    
    // MARK: Loop
    
    override func update(currentTime: CFTimeInterval) {
        
        if gameState == GAME_PLAY {
            
            // animation of Penguin including stopmotion and swing
            animatePenguin()
            
            // animation of Obstacle
            animateObstacle()
            
            // remove gameover board
            animateStart()
        } else if gameState == GAME_OVER {
            
            animateOver()
        }

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

    }
    
    
    // 🐱🐱🐱🐱🐱🐱🐱🐱🐱🐱
    
    func animateObstacle() {
        
        for i in 0...🐱s.count-1 {
            
            // move to bottom from top
            if isOpenUmbrella {
                acceration = 1
            } else {
                if acceration < 4 {
                    acceration *= 1.03
                }
            }
            
            🐱s[i].position.y += speedObstacle * acceration
            
            // when gone from view
            if 🐱s[i].position.y > CGRectGetHeight(self.frame) {
                
                if i > 0 {
                    previousObstacleY = 🐱s[i-1].position.y
                } else {
                    previousObstacleY = 🐱s[i+🐱s.count-1].position.y
                }
                resetObstacle(Sprite: 🐱s[i])
                
                isCountable = true
            }
            
            if 🐱s[i].position.y > 🐧.position.y + 🐧.size.height / 2 && isCountable {
                score += 1
                isCountable = false
                resetScore(spriteArray: counterSmallSpriteArray, left: true, score: score)
                println("score = \(score)")
            }
        }
    }
    
    
    func animateOver() {
        if 🐧.position.y > -🐧.size.height {
            🐧.zRotation = 🐧.zRotation + CGFloat(M_PI/30)
            🐧.position.y += 10 - 9.8 * overCounter / 20;
            overCounter++
        } else {
            overCounter = 0
            if goY < -1 {
                
                board.position.y = CGRectGetMidY(self.frame)*1.25 + goY
                gameoverTitle.position.y = board.position.y + board.size.height * 7/10
                scoreText.position.y = board.position.y + board.size.height/16
                bestText.position.y = board.position.y - board.size.height/3
                
                for num in scoreSpriteArray {
                    num.position.y = scoreText.position.y
                }
            
                for num in bestSpriteArray {
                    num.position.y = bestText.position.y
                }
                
                twButton.position.y = board.position.y - board.size.height * 8/11
                fbButton.position.y = board.position.y - board.size.height * 8/11
                startButton.position.y = board.position.y - board.size.height * 11/10
                rankingButton.position.y = board.position.y - board.size.height * 3/2
                
                if CGRectGetHeight(UIScreen.mainScreen().bounds) < 568 && !isPurchased {
                    twButton.position.y = board.position.y - board.size.height * 13/20
                    fbButton.position.y = board.position.y - board.size.height * 13/20
                    startButton.position.y = board.position.y - board.size.height*19/20
                    rankingButton.position.y = board.position.y - board.size.height*13/10
                }
                backButton.position.y = board.position.y - board.size.height * 9/10
                noadButton.position.y = board.position.y - board.size.height * 9/10
                
                goY /= 1.2
            }
        }
    }
    
    func animateStart() {
        
        if goY >= -CGRectGetMaxY(self.frame) {
            
            board.position.y = CGRectGetMidY(self.frame) * 1.25 + goY
            gameoverTitle.position.y = board.position.y + board.size.height * 7/10
            scoreText.position.y = board.position.y + board.size.height/16
            bestText.position.y = board.position.y - board.size.height/3
            
            for num in scoreSpriteArray {
                num.position.y = scoreText.position.y
            }
            
            for num in bestSpriteArray {
                num.position.y = bestText.position.y
            }
            
            twButton.position.y = board.position.y - board.size.height * 8/11
            fbButton.position.y = board.position.y - board.size.height * 8/11
            startButton.position.y = board.position.y - board.size.height * 11/10
            rankingButton.position.y = board.position.y - board.size.height * 3/2
            
            if CGRectGetHeight(UIScreen.mainScreen().bounds) < 568 && !isPurchased {
                twButton.position.y = board.position.y - board.size.height * 13/20
                fbButton.position.y = board.position.y - board.size.height * 13/20
                startButton.position.y = board.position.y - board.size.height*19/20
                rankingButton.position.y = board.position.y - board.size.height*13/10
            }
            
            backButton.position.y = board.position.y - board.size.height * 9/10
            noadButton.position.y = board.position.y - board.size.height * 9/10
            
            goY -= 100
        }

    }
    
    
    // MARK: setting
    
    // reset 🐧's texture and position
    func resetPenguin() {
        
        alternateTexture(Sprite: 🐧, ImageName1: "penguin_open1", ImageName2: "penguin_open2")
        🐧.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame) * 3 / 2)
        
        🐧.zRotation = 0
        🐧.zPosition = 1
        
        🐧.physicsBody = SKPhysicsBody(polygonFromPath: drawPath(Sprite: 🐧))
        🐧.physicsBody?.affectedByGravity = false
        🐧.physicsBody?.categoryBitMask = obstacleCategory
        🐧.physicsBody?.contactTestBitMask = penguinCategory

    }
    
    // reset 🐱's texture and position
    
    func resetObstacle(Sprite 🐱: SKSpriteNode) {
        
        var rand = 0
        
        if score < 10 {
            rand = Int(arc4random_uniform(UInt32(8)))
        } else if score < 20 {
            rand = Int(arc4random_uniform(UInt32(8))) + 8
        } else if score < 30 {
            rand = Int(arc4random_uniform(UInt32(8))) + 16
        } else if score < 40 {
            rand = Int(arc4random_uniform(UInt32(8))) + 24
        } else if score < 50 {
            rand = Int(arc4random_uniform(UInt32(8))) + 32
        } else {
            rand = Int(arc4random_uniform(UInt32(40)))
        }
        
        var name = obstacleNameArray[rand]
        
        var tex = SKTexture(imageNamed: name)
        🐱.texture = tex
        🐱.size = tex.size()
        🐱.zRotation = 0
        🐱.name = name
        🐱.zPosition = 0
        
        if rand%2 == 0 {
            🐱.position = CGPoint(x:0, y:previousObstacleY - 🐱.size.height - 🐧.size.height)
            🐱.anchorPoint = CGPoint(x:0, y:0)
        } else {
            🐱.position = CGPoint(x:CGRectGetMaxX(self.frame), y:previousObstacleY - 🐱.size.height - 🐧.size.height)
            🐱.anchorPoint = CGPoint(x:1.0, y:0)
        }
        
        🐱.physicsBody = SKPhysicsBody(polygonFromPath: drawPath(Sprite: 🐱))
        🐱.physicsBody?.affectedByGravity = false
        🐱.physicsBody?.categoryBitMask = penguinCategory
        🐱.physicsBody?.contactTestBitMask = obstacleCategory
    }
    
    func resetScore(spriteArray sArray: [SKSpriteNode], left isLeft: Bool, score sc: Int) {
        
        for num in sArray {
            num.texture = nil
        }
        
        if sc < 10 {
            if isLeft {
                sArray[0].texture = SKTexture(imageNamed: "num\(sc)s")
            } else {
                sArray[3].texture = SKTexture(imageNamed: "num\(sc)")
            }
        } else if sc < 100 {
            var p1 = Int(sc/10)
            var p10 = sc - p1 * 10
            
            if isLeft {
                sArray[0].texture = SKTexture(imageNamed: "num\(p1)s")
                sArray[1].texture = SKTexture(imageNamed: "num\(p10)s")
            } else {
                sArray[2].texture = SKTexture(imageNamed: "num\(p1)")
                sArray[3].texture = SKTexture(imageNamed: "num\(p10)")
            }
        } else if sc < 1000 {
            var p1 = Int(sc/100)
            var p10 = Int((sc - p1 * 100)/10)
            var p100 = sc - p1 * 100 - p10 * 10
            
            if isLeft {
                sArray[0].texture = SKTexture(imageNamed: "num\(p1)s")
                sArray[1].texture = SKTexture(imageNamed: "num\(p10)s")
                sArray[2].texture = SKTexture(imageNamed: "num\(p100)s")
            } else {
                sArray[1].texture = SKTexture(imageNamed: "num\(p1)")
                sArray[2].texture = SKTexture(imageNamed: "num\(p10)")
                sArray[3].texture = SKTexture(imageNamed: "num\(p100)")
            }
            
        } else if sc < 10000 {
            var p1 = Int(sc/1000)
            var p10 = Int((sc - p1 * 1000)/100)
            var p100 = Int((sc - p1 * 1000 - p10 * 100)/10)
            var p1000 = sc - p1 * 1000 - p10 * 100 - p100 * 10
            
            if isLeft {
                sArray[0].texture = SKTexture(imageNamed: "num\(p1)s")
                sArray[1].texture = SKTexture(imageNamed: "num\(p10)s")
                sArray[2].texture = SKTexture(imageNamed: "num\(p100)s")
                sArray[3].texture = SKTexture(imageNamed: "num\(p1000)s")
            } else {
                sArray[0].texture = SKTexture(imageNamed: "num\(p1)")
                sArray[1].texture = SKTexture(imageNamed: "num\(p10)")
                sArray[2].texture = SKTexture(imageNamed: "num\(p100)")
                sArray[3].texture = SKTexture(imageNamed: "num\(p1000)")
            }
        }
    }
    
    
    func resetGame() {
        
        gameState = GAME_PLAY
        
        // reset Score
        score = 0
        resetScore(spriteArray: counterSmallSpriteArray, left: true, score: score)
        resetScore(spriteArray: scoreSpriteArray, left: false, score: score)
        
        
        // setup 🐧
        resetPenguin()
        isOpenUmbrella = true
        
        // setup 🐱
        previousObstacleY = 0
        for 🐱 in 🐱s {
            resetObstacle(Sprite: 🐱)
            previousObstacleY = 🐱.position.y
        }
        
        // animateStart
        animateStart()
    }
    
    
    func setupGameover() {
        
        // Board of Score
        alternateTexture(Sprite: board, ImageName1: "board1", ImageName2: "board2")
        board.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)*1.25 + goY)
        board.zPosition = 2
        self.addChild(board)
        
        // Title of GAMEOVER
        alternateTexture(Sprite: gameoverTitle, ImageName1: "gameover1", ImageName2: "gameover2")
        gameoverTitle.position = CGPoint(x: CGRectGetMidX(self.frame), y: board.position.y + board.size.height * 7/10)
        gameoverTitle.zPosition = 2
        self.addChild(gameoverTitle)
        
        // Score on Board
        scoreText.anchorPoint = CGPoint(x: 0, y: 0)
        scoreText.position = CGPoint(x: board.position.x / 3, y: board.position.y + board.size.height/16)
        scoreText.zPosition = 3
        self.addChild(scoreText)
        
        bestText.anchorPoint = CGPoint(x: 0, y: 0)
        bestText.position = CGPoint(x: board.position.x / 3, y: board.position.y - board.size.height/3)
        bestText.zPosition = 3
        self.addChild(bestText)
        
        var i = 0
        for num in scoreSpriteArray {
            let tex = SKTexture(imageNamed: "num0")
            num.position = CGPoint(x: board.position.x + tex.size().width * CGFloat(i), y: scoreText.position.y)
            num.size = tex.size()
            num.anchorPoint = CGPoint(x:0, y:0)
            num.zPosition = 3
            self.addChild(num)
            i++
        }
        
        var j = 0
        for num in bestSpriteArray {
            let tex = SKTexture(imageNamed: "num0")
            num.position = CGPoint(x: board.position.x + tex.size().width * CGFloat(j), y: bestText.position.y)
            num.size = tex.size()
            num.anchorPoint = CGPoint(x:0, y:0)
            num.zPosition = 3
            self.addChild(num)
            j++
        }
        
        // Twitter Button
        twButton.position = CGPoint(x: board.position.x * 3 / 4, y: board.position.y - board.size.height * 8/11)
        if CGRectGetHeight(UIScreen.mainScreen().bounds) < 568 && !isPurchased {
            twButton.position.y = board.position.y - board.size.height * 13/20
        }
        twButton.zPosition = 2
        twButton.name = "twitter_button"
        self.addChild(twButton)
        
        // Facebook Button
        fbButton.position = CGPoint(x: board.position.x * 5 / 4, y: board.position.y - board.size.height * 8/11)
        if CGRectGetHeight(UIScreen.mainScreen().bounds) < 568 && !isPurchased {
            fbButton.position.y = board.position.y - board.size.height * 13/20
        }
        fbButton.zPosition = 2
        fbButton.name = "facebook_button"
        self.addChild(fbButton)
        
        // Start Button
        alternateTexture(Sprite: startButton, ImageName1: "button_start1", ImageName2: "button_start2")
        startButton.position = CGPoint(x: board.position.x, y: board.position.y - board.size.height * 11/10)
        if CGRectGetHeight(UIScreen.mainScreen().bounds) < 568 && !isPurchased{
            startButton.position.y = board.position.y - board.size.height*19/20
        }
        startButton.zPosition = 2
        startButton.name = "start_button"
        self.addChild(startButton)
        
        // Ranking Button
        alternateTexture(Sprite: rankingButton, ImageName1: "button_ranking1", ImageName2: "button_ranking2")
        rankingButton.position = CGPoint(x: board.position.x, y: board.position.y - board.size.height * 15/10)
        if CGRectGetHeight(UIScreen.mainScreen().bounds) < 568 && !isPurchased {
            rankingButton.position.y = board.position.y - board.size.height*13/10
        }
        rankingButton.zPosition = 2
        rankingButton.name = "ranking_button"
        self.addChild(rankingButton)
        
        // Back Button
        backButton.anchorPoint = CGPoint(x: 0, y: 0.5)
        backButton.position = CGPoint(x: 0, y: board.position.y - board.size.height * 9/10)
        backButton.zPosition = 2
        backButton.name = "back_button"
        self.addChild(backButton)
        
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        isPurchased = userDefaults.boolForKey("isPurchased")
        if !isPurchased {
            // NoAd Button
            noadButton.anchorPoint = CGPoint(x: 1, y: 0.5)
            noadButton.position = CGPoint(x:CGRectGetMaxX(self.frame), y: board.position.y - board.size.height * 10/11)
            noadButton.zPosition = 2
            noadButton.name = "noad_button"
            self.addChild(noadButton)
        }
    }
    
    
    // MARK: Event
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        if gameState == GAME_PLAY {
            isOpenUmbrella = false
            alternateTexture(Sprite: 🐧, ImageName1: "penguin_close1", ImageName2: "penguin_close2")
            🐧.physicsBody = SKPhysicsBody(polygonFromPath: drawPath(Sprite: 🐧))
            🐧.physicsBody?.affectedByGravity = false
            🐧.physicsBody?.categoryBitMask = obstacleCategory
            🐧.physicsBody?.contactTestBitMask = penguinCategory
        } else if (gameState == GAME_OVER) {
            
            for touch: AnyObject in touches {
                let location = touch.locationInNode(self)
                touchButtonName = nodeAtPoint(location).name
                
                if touchButtonName == "start_button" {
                    alternateTexture(Sprite: startButton, ImageName1: "button_start_on1", ImageName2: "button_start_on2")
                } else if (touchButtonName == "ranking_button") {
                    alternateTexture(Sprite: rankingButton, ImageName1: "button_ranking_on1", ImageName2: "button_ranking_on2")
                } else if (touchButtonName == "twitter_button") {
                    twButton.texture = SKTexture(imageNamed: "button_twitter_on")
                } else if (touchButtonName == "facebook_button") {
                    fbButton.texture = SKTexture(imageNamed: "button_facebook_on")
                } else if (touchButtonName == "back_button") {
                    backButton.texture = SKTexture(imageNamed: "button_back_on")
                } else if (touchButtonName == "noad_button") {
                    noadButton.texture = SKTexture(imageNamed: "button_noads_on")
                }
            }
        }
    }
    
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        if gameState == GAME_PLAY {
            isOpenUmbrella = true
            alternateTexture(Sprite: 🐧, ImageName1: "penguin_open1", ImageName2: "penguin_open2")
            🐧.physicsBody = SKPhysicsBody(polygonFromPath: drawPath(Sprite: 🐧))
            🐧.physicsBody?.affectedByGravity = false
            🐧.physicsBody?.categoryBitMask = obstacleCategory
            🐧.physicsBody?.contactTestBitMask = penguinCategory
        } else if (gameState == GAME_OVER) {
            
            for touch: AnyObject in touches {
                let location = touch.locationInNode(self)
                if touchButtonName == nodeAtPoint(location).name {
                    if touchButtonName == "start_button" {
                        println(touchButtonName)
                        NSNotificationCenter.defaultCenter().postNotificationName("getPlay", object: nil, userInfo: nil)
                        resetGame()
                    } else if (touchButtonName == "ranking_button") {
                        showScore()
                    } else if (touchButtonName == "twitter_button") {
                        shareSNS("twitter")
                    } else if (touchButtonName == "facebook_button") {
                        shareSNS("facebook")
                    } else if (touchButtonName == "back_button") {
                        let reveal = SKTransition.fadeWithColor(UIColor.whiteColor(), duration: 0.5)
                        let scene = StartScene()
                        scene.size = self.frame.size
                        scene.scaleMode = .AspectFill
                        self.view?.presentScene(scene, transition: reveal)
                    } else if (touchButtonName == "noad_button") {
                        println(touchButtonName)
                        NSNotificationCenter.defaultCenter().postNotificationName("noAds", object: nil, userInfo: nil)
                    }
                }
            }
            
            alternateTexture(Sprite: startButton, ImageName1: "button_start1", ImageName2: "button_start2")
            alternateTexture(Sprite: rankingButton, ImageName1: "button_ranking1", ImageName2: "button_ranking2")
            twButton.texture = SKTexture(imageNamed: "button_twitter")
            fbButton.texture = SKTexture(imageNamed: "button_facebook")
            backButton.texture = SKTexture(imageNamed: "button_back")
            noadButton.texture = SKTexture(imageNamed: "button_noads")
            
            touchButtonName = nil
        }
    }
    
    
    func didBeginContact(contact: SKPhysicsContact!) {
        
        gameState = GAME_OVER
        
        for 🐱 in 🐱s {
            🐱.physicsBody = nil
        }
        🐧.physicsBody = nil
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        bestScore = userDefaults.integerForKey("bestScore")
        if bestScore < score {
            userDefaults.setObject(score, forKey: "bestScore")
            bestScore = score
            
            // send score to Game Center
            sendScore()
        }
        
        
        for num in counterSmallSpriteArray {
            num.texture = nil
        }
        
        resetScore(spriteArray: scoreSpriteArray, left: false, score: score)
        resetScore(spriteArray: bestSpriteArray, left: false, score: bestScore)
        
        NSNotificationCenter.defaultCenter().postNotificationName("getOver", object: nil, userInfo: nil)
    }
    
    func shareSNS(sns:String){
        let message = "You got \(score) points in PEN DREAM. (-o-)"
        let userInfo = ["sns": sns.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, "image": captureGameScreen(), "message": message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!]
        
        NSNotificationCenter.defaultCenter().postNotificationName("sns", object: nil, userInfo: userInfo)
    }
    
    func captureGameScreen() -> NSData {
        
        let rect = self.frame
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen().scale)
        self.view?.drawViewHierarchyInRect(rect, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let dataSaveImage = UIImagePNGRepresentation(image)
        
        return dataSaveImage
    }
    
    func sendScore() {
        let userInfo = ["score": score]
        NSNotificationCenter.defaultCenter().postNotificationName("sendScore", object: nil, userInfo: userInfo)
    }
    
    func showScore() {
        NSNotificationCenter.defaultCenter().postNotificationName("showScore", object: nil, userInfo: nil)
    }
    
    func purchased(notification: NSNotification) {
        println("noadButton.removeFromParent()")
        noadButton.removeFromParent()
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
    
    
    
    // MARK: Drawing Path of Sprite
    
    func drawPath(Sprite sprite:SKSpriteNode) -> CGMutablePath? {
        
        let height = sprite.size.height
        let offsetX = sprite.size.width * sprite.anchorPoint.x
        let offsetY = sprite.size.height  * sprite.anchorPoint.y
        
        let path = CGPathCreateMutable()
        
        if sprite == 🐧 {
            if isOpenUmbrella {
                CGPathMoveToPoint(path, nil, 32 - offsetX, 115 - offsetY)
                CGPathAddLineToPoint(path, nil, 5 - offsetX, 90 - offsetY)
                CGPathAddLineToPoint(path, nil, 17 - offsetX, 94 - offsetY)
                CGPathAddLineToPoint(path, nil, 33 - offsetX, 5 - offsetY)
                CGPathAddLineToPoint(path, nil, 58 - offsetX, 5 - offsetY)
                CGPathAddLineToPoint(path, nil, 75 - offsetX, 20 - offsetY)
                CGPathAddLineToPoint(path, nil, 75 - offsetX, 20 - offsetY)
                CGPathAddLineToPoint(path, nil, 58 - offsetX, 85 - offsetY)
            } else {
                CGPathMoveToPoint(path, nil, 32 - offsetX, 115 - offsetY)
                CGPathAddLineToPoint(path, nil, 18 - offsetX, 70 - offsetY)
                CGPathAddLineToPoint(path, nil, 33 - offsetX, 5 - offsetY)
                CGPathAddLineToPoint(path, nil, 58 - offsetX, 5 - offsetY)
                CGPathAddLineToPoint(path, nil, 75 - offsetX, 20 - offsetY)
                CGPathAddLineToPoint(path, nil, 75 - offsetX, 20 - offsetY)
                CGPathAddLineToPoint(path, nil, 58 - offsetX, 85 - offsetY)
            }
        }
        
        if sprite.name == "st_pen_l" {
            CGPathMoveToPoint(path, nil, 0 - offsetX, 97 - offsetY)
            CGPathAddLineToPoint(path, nil, 165 - offsetX, 22 - offsetY)
            CGPathAddLineToPoint(path, nil, 187 - offsetX, 5 - offsetY)
            CGPathAddLineToPoint(path, nil, 160 - offsetX, 8 - offsetY)
            CGPathAddLineToPoint(path, nil, 0 - offsetX, 80 - offsetY)
        } else if sprite.name == "st_pen_r" {
            CGPathMoveToPoint(path, nil, 178 - offsetX, 87 - offsetY)
            CGPathAddLineToPoint(path, nil, 178 - offsetX, 71 - offsetY)
            CGPathAddLineToPoint(path, nil, 0 - offsetX, 10 - offsetY)
            CGPathAddLineToPoint(path, nil, 23 - offsetX, 28 - offsetY)
        } else if sprite.name == "st_erasor_l" {
            CGPathMoveToPoint(path, nil, 0 - offsetX, 120 - offsetY)
            CGPathAddLineToPoint(path, nil, 120 - offsetX, 68 - offsetY)
            CGPathAddLineToPoint(path, nil, 134 - offsetX, 43 - offsetY)
            CGPathAddLineToPoint(path, nil, 100 - offsetX, 4 - offsetY)
            CGPathAddLineToPoint(path, nil, 0 - offsetX, 37 - offsetY)
        } else if sprite.name == "st_erasor_r" {
            CGPathMoveToPoint(path, nil, 126 - offsetX, 120 - offsetY)
            CGPathAddLineToPoint(path, nil, 10 - offsetX, 68 - offsetY)
            CGPathAddLineToPoint(path, nil, 6 - offsetX, 28 - offsetY)
            CGPathAddLineToPoint(path, nil, 28 - offsetX, 5 - offsetY)
            CGPathAddLineToPoint(path, nil, 126 - offsetX, 46 - offsetY)
        } else if sprite.name == "st_scale_l" {
            CGPathMoveToPoint(path, nil, 0 - offsetX, 111 - offsetY)
            CGPathAddLineToPoint(path, nil, 200 - offsetX, 46 - offsetY)
            CGPathAddLineToPoint(path, nil, 192 - offsetX, 5 - offsetY)
            CGPathAddLineToPoint(path, nil, 0 - offsetX, 65 - offsetY)
        } else if sprite.name == "st_scale_r" {
            CGPathMoveToPoint(path, nil, 196 - offsetX, 108 - offsetY)
            CGPathAddLineToPoint(path, nil, 196 - offsetX, 65 - offsetY)
            CGPathAddLineToPoint(path, nil, 18 - offsetX, 3 - offsetY)
            CGPathAddLineToPoint(path, nil, 5 - offsetX, 44 - offsetY)
        } else if sprite.name == "st_scessor_l" {
            CGPathMoveToPoint(path, nil, 1 - offsetX, 181 - offsetY)
            CGPathAddLineToPoint(path, nil, 20 - offsetX, 167 - offsetY)
            CGPathAddLineToPoint(path, nil, 25 - offsetX, 144 - offsetY)
            CGPathAddLineToPoint(path, nil, 47 - offsetX, 99 - offsetY)
            CGPathAddLineToPoint(path, nil, 181 - offsetX, 95 - offsetY)
            CGPathAddLineToPoint(path, nil, 187 - offsetX, 88 - offsetY)
            CGPathAddLineToPoint(path, nil, 73 - offsetX, 80 - offsetY)
            CGPathAddLineToPoint(path, nil, 156 - offsetX, 9 - offsetY)
            CGPathAddLineToPoint(path, nil, 151 - offsetX, 2 - offsetY)
            CGPathAddLineToPoint(path, nil, 1 - offsetX, 56 - offsetY)
        } else if sprite.name == "st_scessor_r" {
            CGPathMoveToPoint(path, nil, 211 - offsetX, 190 - offsetY)
            CGPathAddLineToPoint(path, nil, 155 - offsetX, 150 - offsetY)
            CGPathAddLineToPoint(path, nil, 135 - offsetX, 107 - offsetY)
            CGPathAddLineToPoint(path, nil, 9 - offsetX, 95 - offsetY)
            CGPathAddLineToPoint(path, nil, 40 - offsetX, 7 - offsetY)
            CGPathAddLineToPoint(path, nil, 40 - offsetX, 7 - offsetY)
            CGPathAddLineToPoint(path, nil, 211 - offsetX, 60 - offsetY)
        } else if sprite.name == "fd_banana_l" {
            CGPathMoveToPoint(path, nil, 16 - offsetX, 174 - offsetY)
            CGPathAddLineToPoint(path, nil, 27 - offsetX, 163 - offsetY)
            CGPathAddLineToPoint(path, nil, 21 - offsetX, 135 - offsetY)
            CGPathAddLineToPoint(path, nil, 39 - offsetX, 95 - offsetY)
            CGPathAddLineToPoint(path, nil, 69 - offsetX, 69 - offsetY)
            CGPathAddLineToPoint(path, nil, 120 - offsetX, 57 - offsetY)
            CGPathAddLineToPoint(path, nil, 180 - offsetX, 65 - offsetY)
            CGPathAddLineToPoint(path, nil, 189 - offsetX, 48 - offsetY)
            CGPathAddLineToPoint(path, nil, 170 - offsetX, 21 - offsetY)
            CGPathAddLineToPoint(path, nil, 107 - offsetX, 5 - offsetY)
            CGPathAddLineToPoint(path, nil, 38 - offsetX, 22 - offsetY)
            CGPathAddLineToPoint(path, nil, 1 - offsetX, 61 - offsetY)
            CGPathAddLineToPoint(path, nil, 1 - offsetX, 136 - offsetY)
        } else if sprite.name == "fd_banana_r" {
            CGPathMoveToPoint(path, nil, 199 - offsetX, 125 - offsetY)
            CGPathAddLineToPoint(path, nil, 198 - offsetX, 67 - offsetY)
            CGPathAddLineToPoint(path, nil, 87 - offsetX, 1 - offsetY)
            CGPathAddLineToPoint(path, nil, 25 - offsetX, 16 - offsetY)
            CGPathAddLineToPoint(path, nil, 4 - offsetX, 46 - offsetY)
            CGPathAddLineToPoint(path, nil, 4 - offsetX, 52 - offsetY)
            CGPathAddLineToPoint(path, nil, 13 - offsetX, 62 - offsetY)
            CGPathAddLineToPoint(path, nil, 88 - offsetX, 58 - offsetY)
            CGPathAddLineToPoint(path, nil, 122 - offsetX, 67 - offsetY)
            CGPathAddLineToPoint(path, nil, 159 - offsetX, 103 - offsetY)
            CGPathAddLineToPoint(path, nil, 173 - offsetX, 141 - offsetY)
            CGPathAddLineToPoint(path, nil, 166 - offsetX, 156 - offsetY)
            CGPathAddLineToPoint(path, nil, 178 - offsetX, 174 - offsetY)
            CGPathAddLineToPoint(path, nil, 189 - offsetX, 157 - offsetY)
            CGPathAddLineToPoint(path, nil, 198 - offsetX, 124 - offsetY)
        } else if sprite.name == "fd_bread_l" {
            CGPathMoveToPoint(path, nil, 0 - offsetX, 124 - offsetY)
            CGPathAddLineToPoint(path, nil, 93 - offsetX, 94 - offsetY)
            CGPathAddLineToPoint(path, nil, 179 - offsetX, 41 - offsetY)
            CGPathAddLineToPoint(path, nil, 181 - offsetX, 7 - offsetY)
            CGPathAddLineToPoint(path, nil, 147 - offsetX, 2 - offsetY)
            CGPathAddLineToPoint(path, nil, 1 - offsetX, 56 - offsetY)
        } else if sprite.name == "fd_bread_r" {
            CGPathMoveToPoint(path, nil, 192 - offsetX, 124 - offsetY)
            CGPathAddLineToPoint(path, nil, 16 - offsetX, 50 - offsetY)
            CGPathAddLineToPoint(path, nil, 4 - offsetX, 19 - offsetY)
            CGPathAddLineToPoint(path, nil, 11 - offsetX, 6 - offsetY)
            CGPathAddLineToPoint(path, nil, 42 - offsetX, 2 - offsetY)
            CGPathAddLineToPoint(path, nil, 193 - offsetX, 60 - offsetY)
        } else if sprite.name == "fd_chocolate_l" {
            CGPathMoveToPoint(path, nil, 2 - offsetX, 159 - offsetY)
            CGPathAddLineToPoint(path, nil, 182 - offsetX, 99 - offsetY)
            CGPathAddLineToPoint(path, nil, 147 - offsetX, 3 - offsetY)
            CGPathAddLineToPoint(path, nil, 1 - offsetX, 49 - offsetY)
        } else if sprite.name == "fd_chocolate_r" {
            CGPathMoveToPoint(path, nil, 187 - offsetX, 159 - offsetY)
            CGPathAddLineToPoint(path, nil, 3 - offsetX, 96 - offsetY)
            CGPathAddLineToPoint(path, nil, 36 - offsetX, 3 - offsetY)
            CGPathAddLineToPoint(path, nil, 186 - offsetX, 49 - offsetY)
        } else if sprite.name == "fd_pasta_l" {
            CGPathMoveToPoint(path, nil, 2 - offsetX, 171 - offsetY)
            CGPathAddLineToPoint(path, nil, 169 - offsetX, 77 - offsetY)
            CGPathAddLineToPoint(path, nil, 139 - offsetX, 28 - offsetY)
            CGPathAddLineToPoint(path, nil, 79 - offsetX, 5 - offsetY)
            CGPathAddLineToPoint(path, nil, 2 - offsetX, 67 - offsetY)
        } else if sprite.name == "fd_pasta_r" {
            CGPathMoveToPoint(path, nil, 180 - offsetX, 167 - offsetY)
            CGPathAddLineToPoint(path, nil, 162 - offsetX, 171 - offsetY)
            CGPathAddLineToPoint(path, nil, 3 - offsetX, 78 - offsetY)
            CGPathAddLineToPoint(path, nil, 30 - offsetX, 28 - offsetY)
            CGPathAddLineToPoint(path, nil, 91 - offsetX, 5 - offsetY)
            CGPathAddLineToPoint(path, nil, 178 - offsetX, 71 - offsetY)
        } else if sprite.name == "an_ant_l" {
            CGPathMoveToPoint(path, nil, 5 - offsetX, 69 - offsetY)
            CGPathAddLineToPoint(path, nil, 108 - offsetX, 17 - offsetY)
            CGPathAddLineToPoint(path, nil, 102 - offsetX, 7 - offsetY)
            CGPathAddLineToPoint(path, nil, 2 - offsetX, 53 - offsetY)
        } else if sprite.name == "an_ant_r" {
            CGPathMoveToPoint(path, nil, 109 - offsetX, 71 - offsetY)
            CGPathAddLineToPoint(path, nil, 6 - offsetX, 19 - offsetY)
            CGPathAddLineToPoint(path, nil, 11 - offsetX, 9 - offsetY)
            CGPathAddLineToPoint(path, nil, 111 - offsetX, 55 - offsetY)
        } else if sprite.name == "an_cat_l" {
            CGPathMoveToPoint(path, nil, 3 - offsetX, 106 - offsetY)
            CGPathAddLineToPoint(path, nil, 41 - offsetX, 129 - offsetY)
            CGPathAddLineToPoint(path, nil, 87 - offsetX, 89 - offsetY)
            CGPathAddLineToPoint(path, nil, 119 - offsetX, 46 - offsetY)
            CGPathAddLineToPoint(path, nil, 147 - offsetX, 24 - offsetY)
            CGPathAddLineToPoint(path, nil, 153 - offsetX, 11 - offsetY)
            CGPathAddLineToPoint(path, nil, 2 - offsetX, 6 - offsetY)
        } else if sprite.name == "an_cat_r" {
            CGPathMoveToPoint(path, nil, 73 - offsetX, 89 - offsetY)
            CGPathAddLineToPoint(path, nil, 109 - offsetX, 129 - offsetY)
            CGPathAddLineToPoint(path, nil, 145 - offsetX, 122 - offsetY)
            CGPathAddLineToPoint(path, nil, 162 - offsetX, 97 - offsetY)
            CGPathAddLineToPoint(path, nil, 163 - offsetX, 15 - offsetY)
            CGPathAddLineToPoint(path, nil, 145 - offsetX, 3 - offsetY)
            CGPathAddLineToPoint(path, nil, 5 - offsetX, 11 - offsetY)
            CGPathAddLineToPoint(path, nil, 5 - offsetX, 18 - offsetY)
            CGPathAddLineToPoint(path, nil, 92 - offsetX, 116 - offsetY)
        } else if sprite.name == "an_cow_l" {
            CGPathMoveToPoint(path, nil, 2 - offsetX, 117 - offsetY)
            CGPathAddLineToPoint(path, nil, 144 - offsetX, 118 - offsetY)
            CGPathAddLineToPoint(path, nil, 164 - offsetX, 107 - offsetY)
            CGPathAddLineToPoint(path, nil, 151 - offsetX, 75 - offsetY)
            CGPathAddLineToPoint(path, nil, 131 - offsetX, 75 - offsetY)
            CGPathAddLineToPoint(path, nil, 108 - offsetX, 5 - offsetY)
            CGPathAddLineToPoint(path, nil, 2 - offsetX, 7 - offsetY)
        } else if sprite.name == "an_cow_r" {
            CGPathMoveToPoint(path, nil, 169 - offsetX, 114 - offsetY)
            CGPathAddLineToPoint(path, nil, 171 - offsetX, 5 - offsetY)
            CGPathAddLineToPoint(path, nil, 59 - offsetX, 5 - offsetY)
            CGPathAddLineToPoint(path, nil, 60 - offsetX, 45 - offsetY)
            CGPathAddLineToPoint(path, nil, 15 - offsetX, 76 - offsetY)
            CGPathAddLineToPoint(path, nil, 5 - offsetX, 106 - offsetY)
            CGPathAddLineToPoint(path, nil, 28 - offsetX, 114 - offsetY)
        } else if sprite.name == "an_whale_l" {
            CGPathMoveToPoint(path, nil, 1 - offsetX, 125 - offsetY)
            CGPathAddLineToPoint(path, nil, 173 - offsetX, 69 - offsetY)
            CGPathAddLineToPoint(path, nil, 223 - offsetX, 7 - offsetY)
            CGPathAddLineToPoint(path, nil, 161 - offsetX, 3 - offsetY)
            CGPathAddLineToPoint(path, nil, 89 - offsetX, 34 - offsetY)
            CGPathAddLineToPoint(path, nil, 59 - offsetX, 32 - offsetY)
            CGPathAddLineToPoint(path, nil, 67 - offsetX, 48 - offsetY)
            CGPathAddLineToPoint(path, nil, 2 - offsetX, 86 - offsetY)
        } else if sprite.name == "an_whale_r" {
            CGPathMoveToPoint(path, nil, 214 - offsetX, 121 - offsetY)
            CGPathAddLineToPoint(path, nil, 58 - offsetX, 73 - offsetY)
            CGPathAddLineToPoint(path, nil, 2 - offsetX, 7 - offsetY)
            CGPathAddLineToPoint(path, nil, 7 - offsetX, 5 - offsetY)
            CGPathAddLineToPoint(path, nil, 66 - offsetX, 5 - offsetY)
            CGPathAddLineToPoint(path, nil, 138 - offsetX, 32 - offsetY)
            CGPathAddLineToPoint(path, nil, 169 - offsetX, 31 - offsetY)
            CGPathAddLineToPoint(path, nil, 162 - offsetX, 44 - offsetY)
            CGPathAddLineToPoint(path, nil, 213 - offsetX, 80 - offsetY)
        } else if sprite.name == "sa_daibutsu_l" {
            CGPathMoveToPoint(path, nil, 2 - offsetX, 35 - offsetY)
            CGPathAddLineToPoint(path, nil, 28 - offsetX, 35 - offsetY)
            CGPathAddLineToPoint(path, nil, 27 - offsetX, 88 - offsetY)
            CGPathAddLineToPoint(path, nil, 64 - offsetX, 112 - offsetY)
            CGPathAddLineToPoint(path, nil, 64 - offsetX, 157 - offsetY)
            CGPathAddLineToPoint(path, nil, 97 - offsetX, 157 - offsetY)
            CGPathAddLineToPoint(path, nil, 100 - offsetX, 112 - offsetY)
            CGPathAddLineToPoint(path, nil, 134 - offsetX, 93 - offsetY)
            CGPathAddLineToPoint(path, nil, 140 - offsetX, 36 - offsetY)
            CGPathAddLineToPoint(path, nil, 170 - offsetX, 27 - offsetY)
            CGPathAddLineToPoint(path, nil, 174 - offsetX, 4 - offsetY)
            CGPathAddLineToPoint(path, nil, 2 - offsetX, 3 - offsetY)
        } else if sprite.name == "sa_daibutsu_r" {
            CGPathMoveToPoint(path, nil, 184 - offsetX, 31 - offsetY)
            CGPathAddLineToPoint(path, nil, 184 - offsetX, 7 - offsetY)
            CGPathAddLineToPoint(path, nil, 7 - offsetX, 2 - offsetY)
            CGPathAddLineToPoint(path, nil, 23 - offsetX, 35 - offsetY)
            CGPathAddLineToPoint(path, nil, 41 - offsetX, 35 - offsetY)
            CGPathAddLineToPoint(path, nil, 45 - offsetX, 91 - offsetY)
            CGPathAddLineToPoint(path, nil, 76 - offsetX, 112 - offsetY)
            CGPathAddLineToPoint(path, nil, 76 - offsetX, 157 - offsetY)
            CGPathAddLineToPoint(path, nil, 115 - offsetX, 154 - offsetY)
            CGPathAddLineToPoint(path, nil, 114 - offsetX, 113 - offsetY)
            CGPathAddLineToPoint(path, nil, 147 - offsetX, 96 - offsetY)
            CGPathAddLineToPoint(path, nil, 155 - offsetX, 35 - offsetY)
        } else if sprite.name == "sa_moai_l" {
            CGPathMoveToPoint(path, nil, 1 - offsetX, 201 - offsetY)
            CGPathAddLineToPoint(path, nil, 15 - offsetX, 212 - offsetY)
            CGPathAddLineToPoint(path, nil, 60 - offsetX, 184 - offsetY)
            CGPathAddLineToPoint(path, nil, 76 - offsetX, 138 - offsetY)
            CGPathAddLineToPoint(path, nil, 108 - offsetX, 3 - offsetY)
            CGPathAddLineToPoint(path, nil, 51 - offsetX, 11 - offsetY)
            CGPathAddLineToPoint(path, nil, 1 - offsetX, 59 - offsetY)
        } else if sprite.name == "sa_moai_r" {
            CGPathMoveToPoint(path, nil, 111 - offsetX, 202 - offsetY)
            CGPathAddLineToPoint(path, nil, 114 - offsetX, 60 - offsetY)
            CGPathAddLineToPoint(path, nil, 64 - offsetX, 11 - offsetY)
            CGPathAddLineToPoint(path, nil, 3 - offsetX, 4 - offsetY)
            CGPathAddLineToPoint(path, nil, 35 - offsetX, 138 - offsetY)
            CGPathAddLineToPoint(path, nil, 70 - offsetX, 203 - offsetY)
            CGPathAddLineToPoint(path, nil, 101 - offsetX, 210 - offsetY)
        } else if sprite.name == "sa_sphinx_l" {
            CGPathMoveToPoint(path, nil, 1 - offsetX, 77 - offsetY)
            CGPathAddLineToPoint(path, nil, 36 - offsetX, 130 - offsetY)
            CGPathAddLineToPoint(path, nil, 54 - offsetX, 133 - offsetY)
            CGPathAddLineToPoint(path, nil, 75 - offsetX, 107 - offsetY)
            CGPathAddLineToPoint(path, nil, 88 - offsetX, 51 - offsetY)
            CGPathAddLineToPoint(path, nil, 176 - offsetX, 38 - offsetY)
            CGPathAddLineToPoint(path, nil, 180 - offsetX, 20 - offsetY)
            CGPathAddLineToPoint(path, nil, 111 - offsetX, 6 - offsetY)
            CGPathAddLineToPoint(path, nil, 2 - offsetX, 3 - offsetY)
        } else if sprite.name == "sa_sphinx_r" {
            CGPathMoveToPoint(path, nil, 187 - offsetX, 74 - offsetY)
            CGPathAddLineToPoint(path, nil, 184 - offsetX, 33 - offsetY)
            CGPathAddLineToPoint(path, nil, 114 - offsetX, 1 - offsetY)
            CGPathAddLineToPoint(path, nil, 4 - offsetX, 16 - offsetY)
            CGPathAddLineToPoint(path, nil, 9 - offsetX, 35 - offsetY)
            CGPathAddLineToPoint(path, nil, 93 - offsetX, 48 - offsetY)
            CGPathAddLineToPoint(path, nil, 110 - offsetX, 102 - offsetY)
            CGPathAddLineToPoint(path, nil, 130 - offsetX, 129 - offsetY)
            CGPathAddLineToPoint(path, nil, 149 - offsetX, 125 - offsetY)
            CGPathAddLineToPoint(path, nil, 160 - offsetX, 110 - offsetY)
        } else if sprite.name == "sa_venus_l" {
            CGPathMoveToPoint(path, nil, 2 - offsetX, 84 - offsetY)
            CGPathAddLineToPoint(path, nil, 62 - offsetX, 168 - offsetY)
            CGPathAddLineToPoint(path, nil, 76 - offsetX, 166 - offsetY)
            CGPathAddLineToPoint(path, nil, 82 - offsetX, 183 - offsetY)
            CGPathAddLineToPoint(path, nil, 95 - offsetX, 193 - offsetY)
            CGPathAddLineToPoint(path, nil, 105 - offsetX, 188 - offsetY)
            CGPathAddLineToPoint(path, nil, 102 - offsetX, 146 - offsetY)
            CGPathAddLineToPoint(path, nil, 15 - offsetX, 7 - offsetY)
            CGPathAddLineToPoint(path, nil, 1 - offsetX, 7 - offsetY)
        } else if sprite.name == "sa_venus_r" {
            CGPathMoveToPoint(path, nil, 101 - offsetX, 92 - offsetY)
            CGPathAddLineToPoint(path, nil, 100 - offsetX, 5 - offsetY)
            CGPathAddLineToPoint(path, nil, 91 - offsetX, 7 - offsetY)
            CGPathAddLineToPoint(path, nil, 5 - offsetX, 144 - offsetY)
            CGPathAddLineToPoint(path, nil, 3 - offsetX, 180 - offsetY)
            CGPathAddLineToPoint(path, nil, 13 - offsetX, 191 - offsetY)
            CGPathAddLineToPoint(path, nil, 28 - offsetX, 185 - offsetY)
            CGPathAddLineToPoint(path, nil, 49 - offsetX, 163 - offsetY)
        } else if sprite.name == "tw_eiffel_l" {
            CGPathMoveToPoint(path, nil, 2 - offsetX, 78 - offsetY)
            CGPathAddLineToPoint(path, nil, 57 - offsetX, 54 - offsetY)
            CGPathAddLineToPoint(path, nil, 162 - offsetX, 47 - offsetY)
            CGPathAddLineToPoint(path, nil, 62 - offsetX, 35 - offsetY)
            CGPathAddLineToPoint(path, nil, 3 - offsetX, 6 - offsetY)
        } else if sprite.name == "tw_eiffel_r" {
            CGPathMoveToPoint(path, nil, 161 - offsetX, 77 - offsetY)
            CGPathAddLineToPoint(path, nil, 163 - offsetX, 8 - offsetY)
            CGPathAddLineToPoint(path, nil, 102 - offsetX, 30 - offsetY)
            CGPathAddLineToPoint(path, nil, 3 - offsetX, 37 - offsetY)
            CGPathAddLineToPoint(path, nil, 102 - offsetX, 48 - offsetY)
        } else if sprite.name == "tw_empire_l" {
            CGPathMoveToPoint(path, nil, 3 - offsetX, 79 - offsetY)
            CGPathAddLineToPoint(path, nil, 46 - offsetX, 52 - offsetY)
            CGPathAddLineToPoint(path, nil, 118 - offsetX, 51 - offsetY)
            CGPathAddLineToPoint(path, nil, 166 - offsetX, 38 - offsetY)
            CGPathAddLineToPoint(path, nil, 115 - offsetX, 25 - offsetY)
            CGPathAddLineToPoint(path, nil, 51 - offsetX, 27 - offsetY)
            CGPathAddLineToPoint(path, nil, 2 - offsetX, 1 - offsetY)
        } else if sprite.name == "tw_empire_r" {
            CGPathMoveToPoint(path, nil, 171 - offsetX, 71 - offsetY)
            CGPathAddLineToPoint(path, nil, 169 - offsetX, 5 - offsetY)
            CGPathAddLineToPoint(path, nil, 123 - offsetX, 24 - offsetY)
            CGPathAddLineToPoint(path, nil, 59 - offsetX, 24 - offsetY)
            CGPathAddLineToPoint(path, nil, 4 - offsetX, 36 - offsetY)
            CGPathAddLineToPoint(path, nil, 34 - offsetX, 38 - offsetY)
            CGPathAddLineToPoint(path, nil, 55 - offsetX, 50 - offsetY)
            CGPathAddLineToPoint(path, nil, 113 - offsetX, 49 - offsetY)
        } else if sprite.name == "tw_sagrada_l" {
            CGPathMoveToPoint(path, nil, 2 - offsetX, 146 - offsetY)
            CGPathAddLineToPoint(path, nil, 48 - offsetX, 145 - offsetY)
            CGPathAddLineToPoint(path, nil, 48 - offsetX, 109 - offsetY)
            CGPathAddLineToPoint(path, nil, 183 - offsetX, 99 - offsetY)
            CGPathAddLineToPoint(path, nil, 200 - offsetX, 83 - offsetY)
            CGPathAddLineToPoint(path, nil, 196 - offsetX, 50 - offsetY)
            CGPathAddLineToPoint(path, nil, 184 - offsetX, 41 - offsetY)
            CGPathAddLineToPoint(path, nil, 69 - offsetX, 21 - offsetY)
            CGPathAddLineToPoint(path, nil, 68 - offsetX, 11 - offsetY)
            CGPathAddLineToPoint(path, nil, 1 - offsetX, 5 - offsetY)
        } else if sprite.name == "tw_sagrada_r" {
            CGPathMoveToPoint(path, nil, 195 - offsetX, 146 - offsetY)
            CGPathAddLineToPoint(path, nil, 139 - offsetX, 140 - offsetY)
            CGPathAddLineToPoint(path, nil, 132 - offsetX, 118 - offsetY)
            CGPathAddLineToPoint(path, nil, 30 - offsetX, 114 - offsetY)
            CGPathAddLineToPoint(path, nil, 3 - offsetX, 99 - offsetY)
            CGPathAddLineToPoint(path, nil, 3 - offsetX, 70 - offsetY)
            CGPathAddLineToPoint(path, nil, 20 - offsetX, 50 - offsetY)
            CGPathAddLineToPoint(path, nil, 154 - offsetX, 41 - offsetY)
            CGPathAddLineToPoint(path, nil, 154 - offsetX, 9 - offsetY)
            CGPathAddLineToPoint(path, nil, 196 - offsetX, 5 - offsetY)
        } else if sprite.name == "tw_touhoh_l" {
            CGPathMoveToPoint(path, nil, 2 - offsetX, 67 - offsetY)
            CGPathAddLineToPoint(path, nil, 42 - offsetX, 46 - offsetY)
            CGPathAddLineToPoint(path, nil, 55 - offsetX, 53 - offsetY)
            CGPathAddLineToPoint(path, nil, 74 - offsetX, 43 - offsetY)
            CGPathAddLineToPoint(path, nil, 149 - offsetX, 48 - offsetY)
            CGPathAddLineToPoint(path, nil, 161 - offsetX, 39 - offsetY)
            CGPathAddLineToPoint(path, nil, 204 - offsetX, 37 - offsetY)
            CGPathAddLineToPoint(path, nil, 204 - offsetX, 33 - offsetY)
            CGPathAddLineToPoint(path, nil, 160 - offsetX, 30 - offsetY)
            CGPathAddLineToPoint(path, nil, 149 - offsetX, 22 - offsetY)
            CGPathAddLineToPoint(path, nil, 75 - offsetX, 22 - offsetY)
            CGPathAddLineToPoint(path, nil, 60 - offsetX, 17 - offsetY)
            CGPathAddLineToPoint(path, nil, 4 - offsetX, 5 - offsetY)
        } else if sprite.name == "tw_touhoh_r" {
            CGPathMoveToPoint(path, nil, 208 - offsetX, 67 - offsetY)
            CGPathAddLineToPoint(path, nil, 165 - offsetX, 47 - offsetY)
            CGPathAddLineToPoint(path, nil, 150 - offsetX, 54 - offsetY)
            CGPathAddLineToPoint(path, nil, 134 - offsetX, 43 - offsetY)
            CGPathAddLineToPoint(path, nil, 57 - offsetX, 52 - offsetY)
            CGPathAddLineToPoint(path, nil, 44 - offsetX, 43 - offsetY)
            CGPathAddLineToPoint(path, nil, 3 - offsetX, 39 - offsetY)
            CGPathAddLineToPoint(path, nil, 3 - offsetX, 37 - offsetY)
            CGPathAddLineToPoint(path, nil, 45 - offsetX, 33 - offsetY)
            CGPathAddLineToPoint(path, nil, 56 - offsetX, 24 - offsetY)
            CGPathAddLineToPoint(path, nil, 135 - offsetX, 26 - offsetY)
            CGPathAddLineToPoint(path, nil, 149 - offsetX, 20 - offsetY)
            CGPathAddLineToPoint(path, nil, 205 - offsetX, 3 - offsetY)
        } else {
            CGPathMoveToPoint(path, nil, 0 - offsetX, 0 - offsetY)
            CGPathAddLineToPoint(path, nil, 0 - offsetX, 0 - offsetY)
            CGPathAddLineToPoint(path, nil, 0 - offsetX, 0 - offsetY)
        }
        
        CGPathCloseSubpath(path)
        
        return path
    }
}
