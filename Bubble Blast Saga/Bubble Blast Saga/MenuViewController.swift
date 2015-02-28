//
//  MenuViewController.swift
//  Bubble Blast Saga
//
//  Created by Jingrong (: on 28/2/15.
//  Copyright (c) 2015 Lim Jing Rong. All rights reserved.
//

import UIKit
import AVFoundation

class MenuViewController: UIViewController {
    var BGMPlayer: AVAudioPlayer!
    var isPlaying: Bool = false
    
    override func viewDidLoad() {
        
        if (isPlaying == false) {
            // Play BGM
            // Sound effect for losing the level
            let bgmPath = NSBundle.mainBundle().pathForResource("gameplay", ofType: "mp3")!
            let bgmURL = NSURL(fileURLWithPath: bgmPath)
            BGMPlayer = AVAudioPlayer(contentsOfURL: bgmURL, error: nil)
            BGMPlayer.prepareToPlay()
            // BGM loops infinitely
            BGMPlayer.numberOfLoops = -1
            BGMPlayer.volume = 0.1
            BGMPlayer.play()
            isPlaying = true
        }
        
    }
}
