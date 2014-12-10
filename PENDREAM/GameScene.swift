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
            self.addChild(num)
            x++
        }
        resetScore(spriteArray: counterSmallSpriteArray, left: true, score: 0)
        
        // setup gameover
        goY = -CGRectGetMaxY(self.frame)
        setupGameover()
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
        
        🐧.physicsBody = SKPhysicsBody(rectangleOfSize: 🐧.size)
        🐧.physicsBody?.affectedByGravity = false
        🐧.physicsBody?.dynamic = false
        🐧.physicsBody?.categoryBitMask = penguinCategory
        🐧.physicsBody?.contactTestBitMask = obstacleCategory

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
                
                gameoverTitle.position.y = CGRectGetMidY(self.frame) * 5 / 3 + goY
                board.position.y = CGRectGetMidY(self.frame)*1.2 + goY
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
                backButton.position.y = 0 + goY
                noadButton.position.y = 0 + goY
                
                goY /= 1.2
            }
        }
    }
    
    func animateStart() {
        
        if goY >= -CGRectGetMaxY(self.frame) {
            println("ss")
            
            gameoverTitle.position.y = CGRectGetMidY(self.frame) * 5 / 3 + goY
            board.position.y = CGRectGetMidY(self.frame)*1.2 + goY
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
            backButton.position.y = 0 + goY
            noadButton.position.y = 0 + goY
            
            goY -= 100
        }

    }
    
    
    // MARK: setting
    
    // reset 🐧's texture and position
    func resetPenguin() {
        
        alternateTexture(Sprite: 🐧, ImageName1: "penguin_open1", ImageName2: "penguin_open2")
        🐧.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame) * 3 / 2)
        🐧.zRotation = 0
    }
    
    // reset 🐱's texture and position
    
    func resetObstacle(Sprite 🐱: SKSpriteNode) {
        
        var rand = Int(arc4random_uniform(UInt32(40)))
        var tex = SKTexture(imageNamed: obstacleNameArray[rand])
        🐱.texture = tex
        🐱.size = tex.size()
        🐱.zRotation = 0
        🐱.physicsBody = SKPhysicsBody(rectangleOfSize: 🐱.size)
        🐱.physicsBody?.affectedByGravity = false
        🐱.physicsBody?.categoryBitMask = obstacleCategory
        🐱.physicsBody?.contactTestBitMask = penguinCategory
        
        if rand%2 == 0 {
            🐱.position = CGPoint(x:0, y:previousObstacleY - 🐱.size.height - 🐧.size.height)
            🐱.anchorPoint = CGPoint(x:0, y:0)
        } else {
            🐱.position = CGPoint(x:CGRectGetMaxX(self.frame), y:previousObstacleY - 🐱.size.height - 🐧.size.height)
            🐱.anchorPoint = CGPoint(x:1.0, y:0)
        }
    }
    
    func resetScore(spriteArray sArray: [SKSpriteNode], left isLeft: Bool, score sc: Int) {
        
        if sc < 10 {
            if isLeft {
                sArray[0].texture = SKTexture(imageNamed: "num\(sc)s")
            } else {
                sArray[3].texture = SKTexture(imageNamed: "num\(sc)s")
            }
        } else if sc < 100 {
            var p1 = Int(sc/10)
            var p10 = sc - p1 * 10
            
            if isLeft {
                sArray[0].texture = SKTexture(imageNamed: "num\(p1)s")
                sArray[1].texture = SKTexture(imageNamed: "num\(p10)s")
            } else {
                sArray[2].texture = SKTexture(imageNamed: "num\(p1)s")
                sArray[3].texture = SKTexture(imageNamed: "num\(p10)s")
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
                sArray[1].texture = SKTexture(imageNamed: "num\(p1)s")
                sArray[2].texture = SKTexture(imageNamed: "num\(p10)s")
                sArray[3].texture = SKTexture(imageNamed: "num\(p100)s")
            }
            
        } else if sc < 10000 {
            var p1 = Int(sc/1000)
            var p10 = Int((sc - p1 * 1000)/100)
            var p100 = Int((sc - p1 * 1000 - p10 * 100)/10)
            var p1000 = sc - p1 * 1000 - p10 * 100 - p100 * 10
            sArray[0].texture = SKTexture(imageNamed: "num\(p1)s")
            sArray[1].texture = SKTexture(imageNamed: "num\(p10)s")
            sArray[2].texture = SKTexture(imageNamed: "num\(p100)s")
            sArray[3].texture = SKTexture(imageNamed: "num\(p1000)s")
        }
    }
    
    
    func setupGameover() {
        
        // Title of GAMEOVER
        alternateTexture(Sprite: gameoverTitle, ImageName1: "gameover1", ImageName2: "gameover2")
        gameoverTitle.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame) * 5 / 3 + goY)
        self.addChild(gameoverTitle)
        
        // Board of Score
        alternateTexture(Sprite: board, ImageName1: "board1", ImageName2: "board2")
        board.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame)*1.2 + goY)
        board.zPosition = 1
        self.addChild(board)
        
        // Score on Board
        scoreText.anchorPoint = CGPoint(x: 0, y: 0)
        scoreText.position = CGPoint(x: board.position.x / 3, y: board.position.y + board.size.height/16)
        scoreText.zPosition = 2
        self.addChild(scoreText)
        
        bestText.anchorPoint = CGPoint(x: 0, y: 0)
        bestText.position = CGPoint(x: board.position.x / 3, y: board.position.y - board.size.height/3)
        bestText.zPosition = 2
        self.addChild(bestText)
        
        var i = 0
        for num in scoreSpriteArray {
            let tex = SKTexture(imageNamed: "num0")
            num.position = CGPoint(x: board.position.x + tex.size().width * CGFloat(i), y: scoreText.position.y)
            num.size = tex.size()
            num.anchorPoint = CGPoint(x:0, y:0)
            num.zPosition = 2
            self.addChild(num)
            i++
        }
        
        var j = 0
        for num in bestSpriteArray {
            let tex = SKTexture(imageNamed: "num0")
            num.position = CGPoint(x: board.position.x + tex.size().width * CGFloat(j), y: bestText.position.y)
            num.size = tex.size()
            num.anchorPoint = CGPoint(x:0, y:0)
            num.zPosition = 2
            self.addChild(num)
            j++
        }
        
        // Twitter Button
        twButton.position = CGPoint(x: board.position.x * 3 / 4, y: board.position.y - board.size.height * 8/11)
        twButton.zPosition = 2
        twButton.name = "twitter_button"
        self.addChild(twButton)
        
        // Facebook Button
        fbButton.position = CGPoint(x: board.position.x * 5 / 4, y: board.position.y - board.size.height * 8/11)
        fbButton.zPosition = 2
        fbButton.name = "facebook_button"
        self.addChild(fbButton)
        
        // Start Button
        alternateTexture(Sprite: startButton, ImageName1: "button_start1", ImageName2: "button_start2")
        startButton.position = CGPoint(x: board.position.x, y: board.position.y - board.size.height * 11/10)
        startButton.zPosition = 2
        startButton.name = "start_button"
        self.addChild(startButton)
        
        // Ranking Button
        alternateTexture(Sprite: rankingButton, ImageName1: "button_ranking1", ImageName2: "button_ranking2")
        rankingButton.position = CGPoint(x: board.position.x, y: board.position.y - board.size.height * 15/10)
        rankingButton.zPosition = 2
        rankingButton.name = "ranking_button"
        self.addChild(rankingButton)
        
        // Back Button
        backButton.anchorPoint = CGPoint(x: 0, y: 0)
        backButton.position = CGPoint(x: 0, y: 0 + goY)
        backButton.zPosition = 2
        backButton.name = "back_button"
        self.addChild(backButton)
        
        // NoAd Button
        noadButton.anchorPoint = CGPoint(x: 1, y: 0)
        noadButton.position = CGPoint(x:CGRectGetMaxX(self.frame), y: 0 + goY)
        noadButton.zPosition = 2
        noadButton.name = "noad_button"
        self.addChild(noadButton)
    }
    
    
    // MARK: Event
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if gameState == GAME_PLAY {
            alternateTexture(Sprite: 🐧, ImageName1: "penguin_close1", ImageName2: "penguin_close2")
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
                }
            }
        }
        
        isOpenUmbrella = false
    }
    
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if gameState == GAME_PLAY {
            alternateTexture(Sprite: 🐧, ImageName1: "penguin_open1", ImageName2: "penguin_open2")
        } else if (gameState == GAME_OVER) {
            
            for touch: AnyObject in touches {
                let location = touch.locationInNode(self)
                if touchButtonName == nodeAtPoint(location).name {
                    if touchButtonName == "start_button" {
                        println(touchButtonName)
                        resetGame()
                        
                    } else if (touchButtonName == "ranking_button") {
                        println(touchButtonName)
                    } else if (touchButtonName == "twitter_button") {
                        println(touchButtonName)
                    } else if (touchButtonName == "facebook_button") {
                        println(touchButtonName)
                    } else if (touchButtonName == "back_button") {
                        println(touchButtonName)
                    } else if (touchButtonName == "noad_button") {
                        println(touchButtonName)
                    }
                }
            }
            
            alternateTexture(Sprite: startButton, ImageName1: "button_start1", ImageName2: "button_start2")
            alternateTexture(Sprite: rankingButton, ImageName1: "button_ranking1", ImageName2: "button_ranking2")
            twButton.texture = SKTexture(imageNamed: "button_twitter")
            fbButton.texture = SKTexture(imageNamed: "button_facebook")
            
            touchButtonName = nil
        }
        
        isOpenUmbrella = true
    }
    
    
    func didBeginContact(contact: SKPhysicsContact!) {
        
        gameState = GAME_OVER
        
        for 🐱 in 🐱s {
            🐱.physicsBody = nil
        }
        
        for num in counterSmallSpriteArray {
            num.hidden = true
        }
        
        resetScore(spriteArray: scoreSpriteArray, left: false, score: score)
        resetScore(spriteArray: bestSpriteArray, left: false, score: bestScore)
    }
    
    func resetGame() {
        
        gameState = GAME_PLAY
        // setup 🐧
        resetPenguin()
        
        // setup 🐱
        previousObstacleY = 0
        for 🐱 in 🐱s {
            resetObstacle(Sprite: 🐱)
            previousObstacleY = 🐱.position.y
        }
        
        // reset Score
        resetScore(spriteArray: counterSmallSpriteArray, left: true, score: 0)
        
        
        // animateStart
        animateStart()
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
