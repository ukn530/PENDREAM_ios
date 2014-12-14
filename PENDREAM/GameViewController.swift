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

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showSNSSheet:", name: "sns", object: nil)
        

        if let scene = StartScene.unarchiveFromFile("StartScene") as? StartScene {
            // Configure the view.
            let skView = self.view as SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.showsPhysics = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
        }
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
}
