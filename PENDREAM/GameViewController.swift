//
//  GameViewController.swift
//  PENDREAM
//
//  Created by ukn on 12/4/14.
//  Copyright (c) 2014 ukn. All rights reserved.
//

import UIKit
import SpriteKit
import Social
import GameKit
import iAd
import StoreKit


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

class GameViewController: UIViewController, GKGameCenterControllerDelegate, ADBannerViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    let banner = ADBannerView(frame: CGRectZero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showSNSSheet:", name: "sns", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendScore:", name: "sendScore", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showScore:", name: "showScore", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getOver:", name: "getOver", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getPlay:", name: "getPlay", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startInAppPurchase:", name: "noAds", object: nil)
        
        authenticateLocalPlayer()
        
        if let scene = StartScene.unarchiveFromFile("GameScene") as? StartScene {
            // Configure the view.
            let skView = self.view as SKView
            //skView.showsFPS = true
            //skView.showsNodeCount = true
            //skView.showsPhysics = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            println("scene.width = \(scene.frame.width)")
            println("scene.height = \(scene.frame.height)")
            skView.presentScene(scene)
        }

        let userDefaults = NSUserDefaults.standardUserDefaults()
        let isPurchased: Bool = userDefaults.boolForKey("isPurchased")
        if !isPurchased {
            banner.frame.origin.y = CGRectGetHeight(self.view.frame)
            banner.delegate = self
            banner.sizeToFit()
            banner.hidden = true
            self.view.addSubview(banner)
        }
        
        println("check in app purchase = \(checkInAppPurchase())")

        /*
        let view = UIView()
        view.frame = self.view.frame
        view.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(view)
        let interstitial = ADInterstitialAd()
        interstitial.delegate = self
        interstitial.presentInView(view)
        println(interstitial.loaded)
*/
    }
    
    func checkInAppPurchase() -> Bool {
        if !SKPaymentQueue.canMakePayments() {
            
            let alert = UIAlertView(title: "Error", message: "You can not use in-app-billing", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            return false
        }
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    func startInAppPurchase(notification: NSNotification) {
        println("startInAppPurchase")
        let set = NSSet(objects: adProductId)
        let productsRequest = SKProductsRequest(productIdentifiers: set)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        
        println("response.invalidProductIdentifiers.count=\(response.invalidProductIdentifiers.count)")
        if response.invalidProductIdentifiers.count > 0 {
            let alert = UIAlertView(title: "Error", message: "\(response.invalidProductIdentifiers[0]) is invalid", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        
        println("product request response.products")
        for product in response.products {
            println("product.title=\(product.localizedTitle)")
            let payment = SKPayment(product: product as SKProduct)
            SKPaymentQueue.defaultQueue().addPayment(payment)
            println("payment Queue")
        }

    }
    
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        println("transactions count == \(transactions.count)")
        for transaction in transactions {
            println("transactionIdentifier = \(transaction.transactionIdentifier)")
            if transaction.transactionState == SKPaymentTransactionState.Purchased {
                println("purchased")
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setBool(true, forKey: "isPurchased")
                banner.removeFromSuperview()
                NSNotificationCenter.defaultCenter().postNotificationName("purchased", object: nil, userInfo: nil)
                queue.finishTransaction(transaction as SKPaymentTransaction)
            } else if transaction.transactionState == SKPaymentTransactionState.Purchasing {
                println("purchasing")
            } else if transaction.transactionState == SKPaymentTransactionState.Failed {
                println("failed")
                queue.finishTransaction(transaction as SKPaymentTransaction)
            } else if transaction.transactionState == SKPaymentTransactionState.Restored {
                println("restored")
                queue.finishTransaction(transaction as SKPaymentTransaction)
            } else {
                println("else")
                queue.finishTransaction(transaction as SKPaymentTransaction)
            }
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue!, restoreCompletedTransactionsFailedWithError error: NSError!) {
        println("failed Restore")
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue!) {
        println("complete every Restore")
    }
    
    func paymentQueue(queue: SKPaymentQueue!, removedTransactions transactions: [AnyObject]!) {
        println("removedTransactions")
        SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
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
        banner.frame.origin.y = CGRectGetHeight(self.view.frame)
    }
    
    func getOver(notification: NSNotification) {
        
        UIView.beginAnimations("animateAdBannerOn", context: nil)
        UIView.setAnimationDuration(0.3)
        banner.frame.origin.y = CGRectGetHeight(self.view.frame) - CGRectGetHeight(banner.frame)
        UIView.commitAnimations()
    }
    
    func getPlay(notification: NSNotification) {
        
        banner.frame.origin.y = CGRectGetHeight(self.view.frame)
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
