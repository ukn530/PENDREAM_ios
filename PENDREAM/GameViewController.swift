//
//  GameViewController.swift
//  PENDREAM
//
//  Created by ukn on 12/4/14.
//  Copyright (c) 2014 ukn. All rights reserved.
//

//import UIKit
import SpriteKit
import Social
import GameKit
import iAd


extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as StartScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController, GKGameCenterControllerDelegate, ADBannerViewDelegate {
    
    let banner = ADBannerView(frame: CGRectZero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showSNSSheet:", name: "sns", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendScore:", name: "sendScore", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showScore:", name: "showScore", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getOver:", name: "getOver", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getPlay:", name: "getPlay", object: nil)
        
        authenticateLocalPlayer()
        
        if let scene = StartScene.unarchiveFromFile("StartScene") as? StartScene {
            // Configure the view.
            let skView = self.originalContentView as SKView
            //skView.showsFPS = true
            //skView.showsNodeCount = true
            skView.showsPhysics = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
        }
        
        banner.frame.origin.y = -CGRectGetHeight(banner.frame)
        banner.delegate = self
        banner.sizeToFit()
        banner.hidden = true
        self.view.addSubview(banner)
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        println("loaded ad")
        banner.hidden = false
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        println(error)
        banner.frame.origin.y = -CGRectGetHeight(banner.frame)
    }
    
    func getOver(notification: NSNotification) {
        
        UIView.beginAnimations("animateAdBannerOn", context: nil)
        UIView.setAnimationDuration(0.3)
        banner.frame.origin.y = 0
        UIView.commitAnimations()
    }
    
    func getPlay(notification: NSNotification) {
        
        banner.frame.origin.y = -CGRectGetHeight(banner.frame)
    }
    
    func showSNSSheet(notification: NSNotification) {
        println("sns come")
        
        let userInfo:Dictionary<String,NSData!> = notification.userInfo as Dictionary<String,NSData!>
        let image: NSData? = userInfo["image"]
        let message = NSString(data: userInfo["message"]!, encoding: UInt())
        let sns = NSString(data: userInfo["sns"]!, encoding: UInt())
        var type = String()
        if sns == "twitter" {
            type = SLServiceTypeTwitter
        } else if sns == "facebook" {
            type = SLServiceTypeFacebook
        }
        
        var snsSheet = SLComposeViewController(forServiceType: type)
        snsSheet.setInitialText(message)
        
        snsSheet.addImage(UIImage(data: image!))
        
        snsSheet.completionHandler = {
            (result:SLComposeViewControllerResult) -> () in
            switch (result) {
            case SLComposeViewControllerResult.Done:
                println("SLComposeViewControllerResult.Done")
            case SLComposeViewControllerResult.Cancelled:
                println("SLComposeViewControllerResult.Cancelled")
            }
        }
        self.presentViewController(snsSheet, animated: true, completion: nil)
    }
    
    func authenticateLocalPlayer(){
        
        let player = GKLocalPlayer.localPlayer()
        player.authenticateHandler = {
            (vc:UIViewController!, error:NSError!) -> () in
            
            if vc != nil {
                // if player does not login, this show modal of login
                self.presentViewController(vc, animated: true, completion: nil)
                
            } else {
                println("Game Center Auth Error = \(error)")
            }
        }
    }
    
    func sendScore(notification: NSNotification) {
        
        let userInfo:Dictionary<String, Int> = notification.userInfo as Dictionary<String, Int>
        let scoreValue = userInfo["score"]
        println(scoreValue)
        
        let player = GKLocalPlayer.localPlayer()
        if player.authenticated {
            let score = GKScore(leaderboardIdentifier: "bestScore")
            score.value = Int64(scoreValue!)
            GKScore.reportScores([score], withCompletionHandler: nil)
        }
    }
    
    func showScore(notification: NSNotification) {
        let gcView = GKGameCenterViewController()
        gcView.gameCenterDelegate = self
        gcView.viewState = GKGameCenterViewControllerState.Leaderboards
        gcView.leaderboardIdentifier = "bestScore"
        self.presentViewController(gcView, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!){
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil);
    }
}
