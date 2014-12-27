//
//  Sound.swift
//  PENDREAM
//
//  Created by ukn on 12/27/14.
//  Copyright (c) 2014 ukn. All rights reserved.
//

import AVFoundation

class Sound {
    
    var soundPlayer = AVAudioPlayer()
    var isPrepareSound = false
    
    func prepareSound(fileName:String) {
        var sound_data = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(fileName, ofType: "mp3")!)
        soundPlayer = AVAudioPlayer(contentsOfURL: sound_data, error: nil)
        if fileName == "bgm" {
            soundPlayer.numberOfLoops = -1
        }
        soundPlayer.prepareToPlay()
    }
    
    func playSound() {
        if soundPlayer.playing {
            soundPlayer.stop()
        }
        soundPlayer.currentTime = 0
        soundPlayer.play()
    }
    
    func stopSound() {
        soundPlayer.stop()
    }
}