//
//  GameScene.swift
//  PENDREAM
//
//  Created by ukn on 12/4/14.
//  Copyright (c) 2014 ukn. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let isDev = true
    
    // MARK: Property
    
    // propety of penguin
    let 🐧 = SKSpriteNode()
    var radian: Double = 0
    var overCounter = CGFloat(0)
    
    let penguinCloseTex1 = SKTexture(imageNamed: "penguin_close1")
    let penguinCloseTex2 = SKTexture(imageNamed: "penguin_close2")
    let penguinOpenTex1 = SKTexture(imageNamed: "penguin_open1")
    let penguinOpenTex2 = SKTexture(imageNamed: "penguin_open2")
    
    // property of Obstacle
    let 🐱s = [SKSpriteNode(), SKSpriteNode(), SKSpriteNode(), SKSpriteNode()]
    let obstacleNameArray = ["st_pen_l", "st_pen_r", "st_erasor_l", "st_erasor_r","st_scale_l", "st_scale_r", "st_scessor_l", "st_scessor_r", "fd_banana_l", "fd_banana_r", "fd_bread_l", "fd_bread_r", "fd_chocolate_l", "fd_chocolate_r", "fd_pasta_l", "fd_pasta_r", "an_ant_l", "an_ant_r", "an_cat_l", "an_cat_r", "an_cow_l", "an_cow_r", "an_whale_l", "an_whale_r", "sa_daibutsu_l", "sa_daibutsu_r", "sa_moai_l", "sa_moai_r", "sa_sphinx_l", "sa_sphinx_r", "sa_venus_l", "sa_venus_r", "tw_eiffel_l", "tw_eiffel_r", "tw_empire_l", "tw_empire_r", "tw_sagrada_l", "tw_sagrada_r", "tw_touhoh_l", "tw_touhoh_r"]
    var previousObstacleY = CGFloat(0)
    let speedObstacle = CGFloat(3)
    var acceration = CGFloat(1)
    let maxAcceration = CGFloat(6)
    let background = SKSpriteNode(imageNamed: "background")
    let background2 = SKSpriteNode(imageNamed: "background")
    
    // the framerate of stop motion animetion is 12 frames in a second
    let animationRate = 20
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
    let boardTex1 = SKTexture(imageNamed: "board1")
    let boardTex2 = SKTexture(imageNamed: "board2")
    let gameoverTex1 = SKTexture(imageNamed: "gameover1")
    let gameoverTex2 = SKTexture(imageNamed: "gameover2")
    let startButtonTex1 = SKTexture(imageNamed: "button_start1")
    let startButtonTex2 = SKTexture(imageNamed: "button_start2")
    let rankingButtonTex1 = SKTexture(imageNamed: "button_ranking1")
    let rankingButtonTex2 = SKTexture(imageNamed: "button_ranking2")
    
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
    var touchable = true
    
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "enableTouch:", name: "enableTouch", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "disableTouch:", name: "disableTouch", object: nil)
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
                if acceration < maxAcceration {
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
            
            
            background.position.y += speedObstacle * acceration * 0.94
            background2.position.y += speedObstacle * acceration * 0.94
            
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
        
        //alternateTexture(Sprite: 🐧, ImageName1: "penguin_open1", ImageName2: "penguin_open2")
        
        🐧.removeActionForKey("penguin")
        🐧.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([penguinOpenTex1, penguinOpenTex2], timePerFrame: 0.1)), withKey: "penguin")
        🐧.size = penguinOpenTex1.size()
        
        🐧.name = "penguin_open"
        
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
        
        if score < 7 {
            rand = Int(arc4random_uniform(UInt32(8)))
        } else if score < 17 {
            rand = Int(arc4random_uniform(UInt32(8))) + 8
        } else if score < 27 {
            rand = Int(arc4random_uniform(UInt32(8))) + 16
        } else if score < 37 {
            rand = Int(arc4random_uniform(UInt32(8))) + 24
        } else if score < 47 {
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
        
        var difficulty: CGFloat = 1.0
        if score < 1 {
            difficulty = 2
        } else if score < 3 {
            difficulty = 1.3
        } else if score < 7 {
            difficulty = 1.2
        } else if score < 20 {
            difficulty = 1.1
        } else if score < 40 {
            difficulty = 1
        } else {
            difficulty = 0.9
        }
        
        if rand%2 == 0 {
            🐱.position = CGPoint(x:0, y:previousObstacleY - 🐱.size.height - 🐧.size.height * difficulty)
            🐱.anchorPoint = CGPoint(x:0, y:0)
        } else {
            🐱.position = CGPoint(x:CGRectGetMaxX(self.frame), y:previousObstacleY - 🐱.size.height - 🐧.size.height * difficulty)
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
        //alternateTexture(Sprite: board, ImageName1: "board1", ImageName2: "board2")
        board.size = boardTex1.size()
        board.removeActionForKey("board")
        board.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([boardTex1, boardTex2], timePerFrame: 0.1)), withKey: "board")
        board.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)*1.25 + goY)
        board.zPosition = 2
        self.addChild(board)
        
        // Title of GAMEOVER
        //alternateTexture(Sprite: gameoverTitle, ImageName1: "gameover1", ImageName2: "gameover2")
        gameoverTitle.size = gameoverTex1.size()
        gameoverTitle.removeActionForKey("gameover")
        gameoverTitle.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([gameoverTex1, gameoverTex2], timePerFrame: 0.1)), withKey: "gameover")
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
        //alternateTexture(Sprite: startButton, ImageName1: "button_start1", ImageName2: "button_start2")
        startButton.removeActionForKey("startButton")
        startButton.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([startButtonTex1, startButtonTex2], timePerFrame: 0.1)), withKey: "startButton")
        
        startButton.size = startButtonTex1.size()
        startButton.position = CGPoint(x: board.position.x, y: board.position.y - board.size.height * 11/10)
        if CGRectGetHeight(UIScreen.mainScreen().bounds) < 568 && !isPurchased{
            startButton.position.y = board.position.y - board.size.height*19/20
        }
        startButton.zPosition = 2
        startButton.name = "start_button"
        self.addChild(startButton)
        
        // Ranking Button
        //alternateTexture(Sprite: rankingButton, ImageName1: "button_ranking1", ImageName2: "button_ranking2")
        
        rankingButton.removeActionForKey("rankingButton")
        rankingButton.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([rankingButtonTex1, rankingButtonTex2], timePerFrame: 0.1)), withKey: "rankingButton")
        
        rankingButton.size = rankingButtonTex1.size()
        
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
            
            🐧.name = "penguin_close"
            🐧.removeActionForKey("penguin")
            //alternateTexture(Sprite: 🐧, ImageName1: "penguin_close1", ImageName2: "penguin_close2")
            🐧.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([penguinCloseTex1, penguinCloseTex2], timePerFrame: 0.1)), withKey: "penguin")
            🐧.physicsBody = SKPhysicsBody(polygonFromPath: drawPath(Sprite: 🐧))
            🐧.physicsBody?.affectedByGravity = false
            🐧.physicsBody?.categoryBitMask = obstacleCategory
            🐧.physicsBody?.contactTestBitMask = penguinCategory
        } else if (gameState == GAME_OVER && touchable) {
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
            
            🐧.name = "penguin_open"
            🐧.removeActionForKey("penguin")
            🐧.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([penguinOpenTex1, penguinOpenTex2], timePerFrame: 0.1)), withKey: "penguin")
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
                        #if RELEASE
                        Flurry.logEvent("TapStartInGameScene")
                        #endif
                    } else if (touchButtonName == "ranking_button") {
                        showScore()
                        #if RELEASE
                        Flurry.logEvent("TapRankingInGameScene")
                        #endif
                    } else if (touchButtonName == "twitter_button") {
                        shareSNS("twitter")
                        #if RELEASE
                        Flurry.logEvent("TapTwitterInGameScene")
                        #endif
                    } else if (touchButtonName == "facebook_button") {
                        shareSNS("facebook")
                        #if RELEASE
                        Flurry.logEvent("TapFacebookInGameScene")
                        #endif
                    } else if (touchButtonName == "back_button") {
                        let reveal = SKTransition.fadeWithColor(UIColor.whiteColor(), duration: 0.5)
                        let scene = StartScene()
                        scene.size = self.frame.size
                        scene.scaleMode = .AspectFill
                        self.view?.presentScene(scene, transition: reveal)
                        #if RELEASE
                        Flurry.logEvent("TapBackInGameScene")
                        #endif
                    } else if (touchButtonName == "noad_button") {
                        println(touchButtonName)
                        touchable = false
                        NSNotificationCenter.defaultCenter().postNotificationName("noAds", object: nil, userInfo: nil)
                        #if RELEASE
                        Flurry.logEvent("TapNoadsInGameScene")
                        #endif
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
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            
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
            #if RELEASE
            var scoreDictionary: [String: Int] = ["playTime": userDefaults.integerForKey("playTimes"), "score": score, "bestScore": bestScore]
            Flurry.logEvent("gameOver", withParameters: scoreDictionary, timed: true)
            #endif
            
            for num in counterSmallSpriteArray {
                num.texture = nil
            }
            
            resetScore(spriteArray: scoreSpriteArray, left: false, score: score)
            resetScore(spriteArray: bestSpriteArray, left: false, score: bestScore)
            
            NSNotificationCenter.defaultCenter().postNotificationName("getOver", object: nil, userInfo: nil)
            
            if (userDefaults.integerForKey("playTimes")%100 == 0){
                NSNotificationCenter.defaultCenter().postNotificationName("Rate", object: nil, userInfo: nil)
            }
            
            isHit = true
        }
    }
    
    
    func shareSNS(sns:String){
        
        var message = String()
        if sns == "twitter" {
            message = "(-o-) < You got \(score) points in #PENDREAM. http://pen-dream.com @penpendream"
        } else {
            message = "(-o-) < You got \(score) points in #PENDREAM. http://pen-dream.com"
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
        #if RELEASE
            let userDefaults = NSUserDefaults.standardUserDefaults()
            var scoreDictionary: [String: Int] = ["playTime": userDefaults.integerForKey("playTimes"), "score": score, "bestScore": bestScore]
            Flurry.logEvent("purchased", withParameters: scoreDictionary, timed: true)
        #endif
    }
    
    func enableTouch(notification: NSNotification) {
        println("enableTouch")
        touchable = true
    }
    
    func disableTouch(notification: NSNotification) {
        println("disableTouch")
        touchable = false
    }
    
    
   // MARK: StopMotionAnimation
    
    // alternate Texture of a Sprite for stop motion animation
    
    func alternateTexture(Sprite sprite: SKSpriteNode, ImageName1 imageName1: String, ImageName2 imageName2: String) {
        let tex1 = SKTexture(imageNamed: imageName1)
        let tex2 = SKTexture(imageNamed: imageName2)
        let texArray = [tex1, tex2]
        sprite.size = tex1.size()
        sprite.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(texArray, timePerFrame: 0.1)), withKey: "penguin")
    }
    
    
}
