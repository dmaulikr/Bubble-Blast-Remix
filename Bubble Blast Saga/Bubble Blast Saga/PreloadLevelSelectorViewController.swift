//
//  PreloadLevelSelectorViewController.swift
//  Bubble Blast Saga
//
//  Created by Jingrong (: on 27/2/15.
//  Copyright (c) 2015 Lim Jing Rong. All rights reserved.
//

import UIKit

class PreloadLevelSelectorViewController: UIViewController {
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "preloadLevel1") {
            // Pass current bubble grid information to game screen
            var gameController = segue.destinationViewController as GameViewController;
            let fileName = "Preload-1"
            let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "plist")!
            if let toLoad = NSArray(contentsOfFile: path) as [[String]]?{
                gameController.sectionArr = toLoad
                gameController.bubblesAmount = 25
            }
            
        } else if (segue.identifier == "preloadLevel2") {
            // Pass current bubble grid information to game screen
            var gameController = segue.destinationViewController as GameViewController;
            let fileName = "Preload-2"
            let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "plist")!
            if let toLoad = NSArray(contentsOfFile: path) as [[String]]?{
                gameController.sectionArr = toLoad
                gameController.bubblesAmount = 25
            }
            
        } else if (segue.identifier == "preloadLevel3") {
            // Pass current bubble grid information to game screen
            var gameController = segue.destinationViewController as GameViewController;
            let fileName = "Preload-3"
            let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "plist")!
            if let toLoad = NSArray(contentsOfFile: path) as [[String]]?{
                gameController.sectionArr = toLoad
                gameController.bubblesAmount = 25
            }
            
        } else if (segue.identifier == "preloadLevel4") {
            // Pass current bubble grid information to game screen
            var gameController = segue.destinationViewController as GameViewController;
            let fileName = "Preload-4"
            let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "plist")!
            if let toLoad = NSArray(contentsOfFile: path) as [[String]]?{
                gameController.sectionArr = toLoad
                gameController.bubblesAmount = 25
            }
            
        }



    }
}
