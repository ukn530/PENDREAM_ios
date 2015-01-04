//
//  GameScene.swift
//  PENDREAM
//
//  Created by ukn on 12/4/14.
//  Copyright (c) 2014 ukn. All rights reserved.
//

import SpriteKit

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
    let speedObstacle = CGFloat(3.8)
    var acceration = CGFloat(1)
    let background = SKSpriteNode(imageNamed: "background")
    let background2 = SKSpriteNode(imageNamed: "background")
    
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
    var isHit = false
    
    // sound
    let bgmSound = Sound()
    let collisionSound = Sound()
    let fallingSound = Sound()
    let fallingvoiceSound = Sound()
    let foldPaperSound = Sound()
    let tapSound = Sound()
    
    
    // MARK: Setup
    
    override func didMoveToView(view: SKView) {
        
        //sound play
        bgmSound.prepareSound("bgm")
        collisionSound.prepareSound("collision")
        fallingSound.prepareSound("falling")
        fallingvoiceSound.prepareSound("fallingvoice")
        foldPaperSound.prepareSound("foldpaper")
        tapSound.prepareSound("tap")
        
        bgmSound.playSound()
        foldPaperSound.playSound()
        
        // setup background
        
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.zPosition = 0
        self.addChild(background)
        
        background2.anchorPoint = CGPoint(x: 0, y: 0)
        background.zPosition = 0
        background2.position = CGPoint(x: 0, y: -background.size.height)
        self.addChild(background2)
        
        isHit = false
        
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
        🐧.zPosition = 2
        
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
                if acceration < speedObstacle {
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
            
            
            background.position.y += speedObstacle * acceration * 0.999
            background2.position.y += speedObstacle * acceration * 0.999
            
            if background.position.y > background.size.height {
                background.position.y = background2.position.y - background.size.height
            }
            
            if background2.position.y > background2.size.height {
                background2.position.y = background.position.y - background2.size.height
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
        🐱.zPosition = 1
        
        if rand%2 == 0 {
            🐱.position = CGPoint(x:0, y:previousObstacleY - 🐱.size.height - 🐧.size.height)
            🐱.anchorPoint = CGPoint(x:0, y:0)
        } else {
            🐱.position = CGPoint(x:CGRectGetMaxX(self.frame), y:previousObstacleY - 🐱.size.height - 🐧.size.height*0.9)
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
            fallingSound.playSound()
            fallingvoiceSound.playSound()
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
                    tapSound.playSound()
                } else if (touchButtonName == "ranking_button") {
                    alternateTexture(Sprite: rankingButton, ImageName1: "button_ranking_on1", ImageName2: "button_ranking_on2")
                    tapSound.playSound()
                } else if (touchButtonName == "twitter_button") {
                    twButton.texture = SKTexture(imageNamed: "button_twitter_on")
                    tapSound.playSound()
                } else if (touchButtonName == "facebook_button") {
                    fbButton.texture = SKTexture(imageNamed: "button_facebook_on")
                    tapSound.playSound()
                } else if (touchButtonName == "back_button") {
                    backButton.texture = SKTexture(imageNamed: "button_back_on")
                    tapSound.playSound()
                } else if (touchButtonName == "noad_button") {
                    noadButton.texture = SKTexture(imageNamed: "button_noads_on")
                    tapSound.playSound()
                }
            }
        }
    }
    
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        fallingSound.stopSound()
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
                        bgmSound.playSound()
                        isHit = false
                        Flurry.logEvent("TapStartInGameScene")
                    } else if (touchButtonName == "ranking_button") {
                        showScore()
                        Flurry.logEvent("TapRankingInGameScene")
                    } else if (touchButtonName == "twitter_button") {
                        shareSNS("twitter")
                        Flurry.logEvent("TapTwitterInGameScene")
                    } else if (touchButtonName == "facebook_button") {
                        shareSNS("facebook")
                        Flurry.logEvent("TapFacebookInGameScene")
                    } else if (touchButtonName == "back_button") {
                        let reveal = SKTransition.fadeWithColor(UIColor.whiteColor(), duration: 0.5)
                        let scene = StartScene()
                        scene.size = self.frame.size
                        scene.scaleMode = .AspectFill
                        self.view?.presentScene(scene, transition: reveal)
                        Flurry.logEvent("TapBackInGameScene")
                    } else if (touchButtonName == "noad_button") {
                        println(touchButtonName)
                        NSNotificationCenter.defaultCenter().postNotificationName("noAds", object: nil, userInfo: nil)
                        Flurry.logEvent("TapNoadsInGameScene")
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
        if !isHit {
            
            collisionSound.playSound()
            bgmSound.stopSound()
            
            gameState = GAME_OVER
            
            for 🐱 in 🐱s {
                🐱.physicsBody = nil
            }
            🐧.physicsBody = nil
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            var playTimes: Int = userDefaults.integerForKey("playTimes")
            playTimes++
            userDefaults.setObject(playTimes, forKey: "playTimes")
            bestScore = userDefaults.integerForKey("bestScore")
            if bestScore < score {
                userDefaults.setObject(score, forKey: "bestScore")
                bestScore = score
                
                // send score to Game Center
                sendScore()
            }
            println("playTimes = \(playTimes)")
            //Send to Flurry for Analytics
            var scoreDictionary: [String: Int] = ["playTime": userDefaults.integerForKey("playTimes"), "score": score, "bestScore": bestScore]
            Flurry.logEvent("gameOver", withParameters: scoreDictionary, timed: true)
            
            for num in counterSmallSpriteArray {
                num.texture = nil
            }
            
            resetScore(spriteArray: scoreSpriteArray, left: false, score: score)
            resetScore(spriteArray: bestSpriteArray, left: false, score: bestScore)
            
            NSNotificationCenter.defaultCenter().postNotificationName("getOver", object: nil, userInfo: nil)
            
            isHit = true
        }
    }
    
    func shareSNS(sns:String){
        
        var message = String()
        if sns == "twitter" {
            message = "(-o-) < You got \(score) points in PEN DREAM. @PenPenDream"
        } else {
            message = "(-o-) < You got \(score) points in PEN DREAM."
        }
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
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var scoreDictionary: [String: Int] = ["playTime": userDefaults.integerForKey("playTimes"), "score": score, "bestScore": bestScore]
        Flurry.logEvent("purchased", withParameters: scoreDictionary, timed: true)
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
        var adjust: CGFloat = 1
        
        let path = CGPathCreateMutable()
        
        if sprite == 🐧 {
            if isOpenUmbrella {
                CGPathMoveToPoint(path, nil, 32 * adjust - offsetX, 115 * adjust - offsetY)
                CGPathAddLineToPoint(path, nil, 5 * adjust - offsetX, 90 * adjust - offsetY)
                CGPathAddLineToPoint(path, nil, 17 * adjust - offsetX, 94 * adjust - offsetY)
                CGPathAddLineToPoint(path, nil, 33 * adjust - offsetX, 5 * adjust - offsetY)
                CGPathAddLineToPoint(path, nil, 58 * adjust - offsetX, 5 * adjust - offsetY)
                CGPathAddLineToPoint(path, nil, 75 * adjust - offsetX, 20 * adjust - offsetY)
                CGPathAddLineToPoint(path, nil, 75 * adjust - offsetX, 20 * adjust - offsetY)
                CGPathAddLineToPoint(path, nil, 58 * adjust - offsetX, 85 * adjust - offsetY)
            } else {
                CGPathMoveToPoint(path, nil, 32 * adjust - offsetX, 115 * adjust - offsetY)
                CGPathAddLineToPoint(path, nil, 18 * adjust - offsetX, 70 * adjust - offsetY)
                CGPathAddLineToPoint(path, nil, 33 * adjust - offsetX, 5 * adjust - offsetY)
                CGPathAddLineToPoint(path, nil, 58 * adjust - offsetX, 5 * adjust - offsetY)
                CGPathAddLineToPoint(path, nil, 75 * adjust - offsetX, 20 * adjust - offsetY)
                CGPathAddLineToPoint(path, nil, 75 * adjust - offsetX, 20 * adjust - offsetY)
                CGPathAddLineToPoint(path, nil, 58 * adjust - offsetX, 85 * adjust - offsetY)
            }
        }
        
        if sprite.name == "st_pen_l" {
            CGPathMoveToPoint(path, nil, 0 * adjust - offsetX, 97 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 165 * adjust - offsetX, 22 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 187 * adjust - offsetX, 5 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 160 * adjust - offsetX, 8 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 0 * adjust - offsetX, 80 * adjust - offsetY)
        } else if sprite.name == "st_pen_r" {
            CGPathMoveToPoint(path, nil, 178 * adjust - offsetX, 87 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 178 * adjust - offsetX, 71 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 0 * adjust - offsetX, 10 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 23 * adjust - offsetX, 28 * adjust - offsetY)
        } else if sprite.name == "st_erasor_l" {
            CGPathMoveToPoint(path, nil, 0 * adjust - offsetX, 120 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 120 * adjust - offsetX, 68 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 134 * adjust - offsetX, 43 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 100 * adjust - offsetX, 4 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 0 * adjust - offsetX, 37 * adjust - offsetY)
        } else if sprite.name == "st_erasor_r" {
            CGPathMoveToPoint(path, nil, 126 * adjust - offsetX, 120 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 10 * adjust - offsetX, 68 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 6 * adjust - offsetX, 28 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 28 * adjust - offsetX, 5 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 126 * adjust - offsetX, 46 * adjust - offsetY)
        } else if sprite.name == "st_scale_l" {
            CGPathMoveToPoint(path, nil, 0 * adjust - offsetX, 111 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 200 * adjust - offsetX, 46 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 192 * adjust - offsetX, 5 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 0 * adjust - offsetX, 65 * adjust - offsetY)
        } else if sprite.name == "st_scale_r" {
            CGPathMoveToPoint(path, nil, 196 * adjust - offsetX, 108 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 196 * adjust - offsetX, 65 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 18 * adjust - offsetX, 3 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 5 * adjust - offsetX, 44 * adjust - offsetY)
        } else if sprite.name == "st_scessor_l" {
            CGPathMoveToPoint(path, nil, 1 * adjust - offsetX, 181 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 20 * adjust - offsetX, 167 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 25 * adjust - offsetX, 144 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 47 * adjust - offsetX, 99 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 181 * adjust - offsetX, 95 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 187 * adjust - offsetX, 88 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 73 * adjust - offsetX, 80 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 156 * adjust - offsetX, 9 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 151 * adjust - offsetX, 2 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 1 * adjust - offsetX, 56 * adjust - offsetY)
        } else if sprite.name == "st_scessor_r" {
            CGPathMoveToPoint(path, nil, 211 * adjust - offsetX, 190 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 155 * adjust - offsetX, 150 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 135 * adjust - offsetX, 107 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 9 * adjust - offsetX, 95 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 40 * adjust - offsetX, 7 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 40 * adjust - offsetX, 7 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 211 * adjust - offsetX, 60 * adjust - offsetY)
        } else if sprite.name == "fd_banana_l" {
            CGPathMoveToPoint(path, nil, 16 * adjust - offsetX, 174 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 27 * adjust - offsetX, 163 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 21 * adjust - offsetX, 135 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 39 * adjust - offsetX, 95 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 69 * adjust - offsetX, 69 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 120 * adjust - offsetX, 57 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 180 * adjust - offsetX, 65 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 189 * adjust - offsetX, 48 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 170 * adjust - offsetX, 21 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 107 * adjust - offsetX, 5 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 38 * adjust - offsetX, 22 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 1 * adjust - offsetX, 61 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 1 * adjust - offsetX, 136 * adjust - offsetY)
        } else if sprite.name == "fd_banana_r" {
            CGPathMoveToPoint(path, nil, 199 * adjust - offsetX, 125 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 198 * adjust - offsetX, 67 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 87 * adjust - offsetX, 1 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 25 * adjust - offsetX, 16 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 4 * adjust - offsetX, 46 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 4 * adjust - offsetX, 52 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 13 * adjust - offsetX, 62 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 88 * adjust - offsetX, 58 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 122 * adjust - offsetX, 67 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 159 * adjust - offsetX, 103 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 173 * adjust - offsetX, 141 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 166 * adjust - offsetX, 156 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 178 * adjust - offsetX, 174 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 189 * adjust - offsetX, 157 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 198 * adjust - offsetX, 124 * adjust - offsetY)
        } else if sprite.name == "fd_bread_l" {
            CGPathMoveToPoint(path, nil, 0 * adjust - offsetX, 124 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 93 * adjust - offsetX, 94 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 179 * adjust - offsetX, 41 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 181 * adjust - offsetX, 7 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 147 * adjust - offsetX, 2 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 1 * adjust - offsetX, 56 * adjust - offsetY)
        } else if sprite.name == "fd_bread_r" {
            CGPathMoveToPoint(path, nil, 192 * adjust - offsetX, 124 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 16 * adjust - offsetX, 50 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 4 * adjust - offsetX, 19 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 11 * adjust - offsetX, 6 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 42 * adjust - offsetX, 2 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 193 * adjust - offsetX, 60 * adjust - offsetY)
        } else if sprite.name == "fd_chocolate_l" {
            CGPathMoveToPoint(path, nil, 2 * adjust - offsetX, 159 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 182 * adjust - offsetX, 99 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 147 * adjust - offsetX, 3 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 1 * adjust - offsetX, 49 * adjust - offsetY)
        } else if sprite.name == "fd_chocolate_r" {
            CGPathMoveToPoint(path, nil, 187 * adjust - offsetX, 159 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 3 * adjust - offsetX, 96 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 36 * adjust - offsetX, 3 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 186 * adjust - offsetX, 49 * adjust - offsetY)
        } else if sprite.name == "fd_pasta_l" {
            CGPathMoveToPoint(path, nil, 2 * adjust - offsetX, 171 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 169 * adjust - offsetX, 77 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 139 * adjust - offsetX, 28 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 79 * adjust - offsetX, 5 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 2 * adjust - offsetX, 67 * adjust - offsetY)
        } else if sprite.name == "fd_pasta_r" {
            CGPathMoveToPoint(path, nil, 180 * adjust - offsetX, 167 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 162 * adjust - offsetX, 171 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 3 * adjust - offsetX, 78 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 30 * adjust - offsetX, 28 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 91 * adjust - offsetX, 5 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 178 * adjust - offsetX, 71 * adjust - offsetY)
        } else if sprite.name == "an_ant_l" {
            CGPathMoveToPoint(path, nil, 5 * adjust - offsetX, 69 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 108 * adjust - offsetX, 17 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 102 * adjust - offsetX, 7 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 2 * adjust - offsetX, 53 * adjust - offsetY)
        } else if sprite.name == "an_ant_r" {
            CGPathMoveToPoint(path, nil, 109 * adjust - offsetX, 71 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 6 * adjust - offsetX, 19 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 11 * adjust - offsetX, 9 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 111 * adjust - offsetX, 55 * adjust - offsetY)
        } else if sprite.name == "an_cat_l" {
            CGPathMoveToPoint(path, nil, 3 * adjust - offsetX, 106 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 41 * adjust - offsetX, 129 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 87 * adjust - offsetX, 89 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 119 * adjust - offsetX, 46 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 147 * adjust - offsetX, 24 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 153 * adjust - offsetX, 11 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 2 * adjust - offsetX, 6 * adjust - offsetY)
        } else if sprite.name == "an_cat_r" {
            CGPathMoveToPoint(path, nil, 73 * adjust - offsetX, 89 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 109 * adjust - offsetX, 129 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 145 * adjust - offsetX, 122 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 162 * adjust - offsetX, 97 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 163 * adjust - offsetX, 15 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 145 * adjust - offsetX, 3 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 5 * adjust - offsetX, 11 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 5 * adjust - offsetX, 18 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 92 * adjust - offsetX, 116 * adjust - offsetY)
        } else if sprite.name == "an_cow_l" {
            CGPathMoveToPoint(path, nil, 2 * adjust - offsetX, 117 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 144 * adjust - offsetX, 118 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 164 * adjust - offsetX, 107 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 151 * adjust - offsetX, 75 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 131 * adjust - offsetX, 75 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 108 * adjust - offsetX, 5 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 2 * adjust - offsetX, 7 * adjust - offsetY)
        } else if sprite.name == "an_cow_r" {
            CGPathMoveToPoint(path, nil, 169 * adjust - offsetX, 114 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 171 * adjust - offsetX, 5 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 59 * adjust - offsetX, 5 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 60 * adjust - offsetX, 45 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 15 * adjust - offsetX, 76 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 5 * adjust - offsetX, 106 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 28 * adjust - offsetX, 114 * adjust - offsetY)
        } else if sprite.name == "an_whale_l" {
            CGPathMoveToPoint(path, nil, 1 * adjust - offsetX, 125 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 173 * adjust - offsetX, 69 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 223 * adjust - offsetX, 7 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 161 * adjust - offsetX, 3 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 89 * adjust - offsetX, 34 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 59 * adjust - offsetX, 32 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 67 * adjust - offsetX, 48 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 2 * adjust - offsetX, 86 * adjust - offsetY)
        } else if sprite.name == "an_whale_r" {
            CGPathMoveToPoint(path, nil, 214 * adjust - offsetX, 121 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 58 * adjust - offsetX, 73 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 2 * adjust - offsetX, 7 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 7 * adjust - offsetX, 5 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 66 * adjust - offsetX, 5 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 138 * adjust - offsetX, 32 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 169 * adjust - offsetX, 31 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 162 * adjust - offsetX, 44 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 213 * adjust - offsetX, 80 * adjust - offsetY)
        } else if sprite.name == "sa_daibutsu_l" {
            CGPathMoveToPoint(path, nil, 2 * adjust - offsetX, 35 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 28 * adjust - offsetX, 35 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 27 * adjust - offsetX, 88 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 64 * adjust - offsetX, 112 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 64 * adjust - offsetX, 157 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 97 * adjust - offsetX, 157 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 100 * adjust - offsetX, 112 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 134 * adjust - offsetX, 93 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 140 * adjust - offsetX, 36 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 170 * adjust - offsetX, 27 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 174 * adjust - offsetX, 4 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 2 * adjust - offsetX, 3 * adjust - offsetY)
        } else if sprite.name == "sa_daibutsu_r" {
            CGPathMoveToPoint(path, nil, 184 * adjust - offsetX, 31 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 184 * adjust - offsetX, 7 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 7 * adjust - offsetX, 2 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 23 * adjust - offsetX, 35 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 41 * adjust - offsetX, 35 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 45 * adjust - offsetX, 91 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 76 * adjust - offsetX, 112 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 76 * adjust - offsetX, 157 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 115 * adjust - offsetX, 154 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 114 * adjust - offsetX, 113 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 147 * adjust - offsetX, 96 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 155 * adjust - offsetX, 35 * adjust - offsetY)
        } else if sprite.name == "sa_moai_l" {
            CGPathMoveToPoint(path, nil, 1 * adjust - offsetX, 201 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 15 * adjust - offsetX, 212 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 60 * adjust - offsetX, 184 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 76 * adjust - offsetX, 138 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 108 * adjust - offsetX, 3 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 51 * adjust - offsetX, 11 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 1 * adjust - offsetX, 59 * adjust - offsetY)
        } else if sprite.name == "sa_moai_r" {
            CGPathMoveToPoint(path, nil, 111 * adjust - offsetX, 202 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 114 * adjust - offsetX, 60 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 64 * adjust - offsetX, 11 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 3 * adjust - offsetX, 4 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 35 * adjust - offsetX, 138 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 70 * adjust - offsetX, 203 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 101 * adjust - offsetX, 210 * adjust - offsetY)
        } else if sprite.name == "sa_sphinx_l" {
            CGPathMoveToPoint(path, nil, 1 * adjust - offsetX, 77 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 36 * adjust - offsetX, 130 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 54 * adjust - offsetX, 133 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 75 * adjust - offsetX, 107 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 88 * adjust - offsetX, 51 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 176 * adjust - offsetX, 38 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 180 * adjust - offsetX, 20 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 111 * adjust - offsetX, 6 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 2 * adjust - offsetX, 3 * adjust - offsetY)
        } else if sprite.name == "sa_sphinx_r" {
            CGPathMoveToPoint(path, nil, 187 * adjust - offsetX, 74 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 184 * adjust - offsetX, 33 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 114 * adjust - offsetX, 1 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 4 * adjust - offsetX, 16 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 9 * adjust - offsetX, 35 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 93 * adjust - offsetX, 48 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 110 * adjust - offsetX, 102 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 130 * adjust - offsetX, 129 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 149 * adjust - offsetX, 125 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 160 * adjust - offsetX, 110 * adjust - offsetY)
        } else if sprite.name == "sa_venus_l" {
            CGPathMoveToPoint(path, nil, 2 * adjust - offsetX, 84 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 62 * adjust - offsetX, 168 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 76 * adjust - offsetX, 166 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 82 * adjust - offsetX, 183 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 95 * adjust - offsetX, 193 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 105 * adjust - offsetX, 188 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 102 * adjust - offsetX, 146 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 15 * adjust - offsetX, 7 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 1 * adjust - offsetX, 7 * adjust - offsetY)
        } else if sprite.name == "sa_venus_r" {
            CGPathMoveToPoint(path, nil, 101 * adjust - offsetX, 92 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 100 * adjust - offsetX, 5 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 91 * adjust - offsetX, 7 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 5 * adjust - offsetX, 144 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 3 * adjust - offsetX, 180 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 13 * adjust - offsetX, 191 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 28 * adjust - offsetX, 185 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 49 * adjust - offsetX, 163 * adjust - offsetY)
        } else if sprite.name == "tw_eiffel_l" {
            CGPathMoveToPoint(path, nil, 2 * adjust - offsetX, 78 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 57 * adjust - offsetX, 54 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 162 * adjust - offsetX, 47 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 62 * adjust - offsetX, 35 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 3 * adjust - offsetX, 6 * adjust - offsetY)
        } else if sprite.name == "tw_eiffel_r" {
            CGPathMoveToPoint(path, nil, 161 * adjust - offsetX, 77 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 163 * adjust - offsetX, 8 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 102 * adjust - offsetX, 30 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 3 * adjust - offsetX, 37 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 102 * adjust - offsetX, 48 * adjust - offsetY)
        } else if sprite.name == "tw_empire_l" {
            CGPathMoveToPoint(path, nil, 3 * adjust - offsetX, 79 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 46 * adjust - offsetX, 52 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 118 * adjust - offsetX, 51 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 166 * adjust - offsetX, 38 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 115 * adjust - offsetX, 25 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 51 * adjust - offsetX, 27 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 2 * adjust - offsetX, 1 * adjust - offsetY)
        } else if sprite.name == "tw_empire_r" {
            CGPathMoveToPoint(path, nil, 171 * adjust - offsetX, 71 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 169 * adjust - offsetX, 5 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 123 * adjust - offsetX, 24 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 59 * adjust - offsetX, 24 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 4 * adjust - offsetX, 36 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 34 * adjust - offsetX, 38 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 55 * adjust - offsetX, 50 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 113 * adjust - offsetX, 49 * adjust - offsetY)
        } else if sprite.name == "tw_sagrada_l" {
            CGPathMoveToPoint(path, nil, 2 * adjust - offsetX, 146 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 48 * adjust - offsetX, 145 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 48 * adjust - offsetX, 109 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 183 * adjust - offsetX, 99 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 200 * adjust - offsetX, 83 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 196 * adjust - offsetX, 50 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 184 * adjust - offsetX, 41 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 69 * adjust - offsetX, 21 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 68 * adjust - offsetX, 11 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 1 * adjust - offsetX, 5 * adjust - offsetY)
        } else if sprite.name == "tw_sagrada_r" {
            CGPathMoveToPoint(path, nil, 195 * adjust - offsetX, 146 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 139 * adjust - offsetX, 140 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 132 * adjust - offsetX, 118 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 30 * adjust - offsetX, 114 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 3 * adjust - offsetX, 99 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 3 * adjust - offsetX, 70 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 20 * adjust - offsetX, 50 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 154 * adjust - offsetX, 41 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 154 * adjust - offsetX, 9 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 196 * adjust - offsetX, 5 * adjust - offsetY)
        } else if sprite.name == "tw_touhoh_l" {
            CGPathMoveToPoint(path, nil, 2 * adjust - offsetX, 67 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 42 * adjust - offsetX, 46 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 55 * adjust - offsetX, 53 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 74 * adjust - offsetX, 43 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 149 * adjust - offsetX, 48 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 161 * adjust - offsetX, 39 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 204 * adjust - offsetX, 37 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 204 * adjust - offsetX, 33 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 160 * adjust - offsetX, 30 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 149 * adjust - offsetX, 22 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 75 * adjust - offsetX, 22 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 60 * adjust - offsetX, 17 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 4 * adjust - offsetX, 5 * adjust - offsetY)
        } else if sprite.name == "tw_touhoh_r" {
            CGPathMoveToPoint(path, nil, 208 * adjust - offsetX, 67 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 165 * adjust - offsetX, 47 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 150 * adjust - offsetX, 54 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 134 * adjust - offsetX, 43 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 57 * adjust - offsetX, 52 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 44 * adjust - offsetX, 43 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 3 * adjust - offsetX, 39 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 3 * adjust - offsetX, 37 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 45 * adjust - offsetX, 33 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 56 * adjust - offsetX, 24 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 135 * adjust - offsetX, 26 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 149 * adjust - offsetX, 20 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 205 * adjust - offsetX, 3 * adjust - offsetY)
        } else {
            CGPathMoveToPoint(path, nil, 0 * adjust - offsetX, 0 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 0 * adjust - offsetX, 0 * adjust - offsetY)
            CGPathAddLineToPoint(path, nil, 0 * adjust - offsetX, 0 * adjust - offsetY)
        }
        
        CGPathCloseSubpath(path)
        
        return path
    }
}
