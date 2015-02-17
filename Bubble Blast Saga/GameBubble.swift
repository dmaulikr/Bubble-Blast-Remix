//
//  GameBubble.swift
//  LevelDesigner
//
//  Created by Jingrong (: on 3/2/15.
//  Copyright (c) 2015 NUS CS3217. All rights reserved.
//

import Foundation

class GameBubble {
    
    private var currentSelection: String = ""
    
    init() {
        currentSelection = ""
    }
    
    init(color : String) {
        currentSelection = color
    }
    
    // Setter function to store current selection
    func setSelection(userSelected: String) {
        // Either bubbles or eraser
        self.currentSelection = userSelected
    }
    
    // Getter func to get current selection
    func getSelection() -> String {
        return self.currentSelection
    }
    
    // Generate random bubble
    func getRandom() -> GameBubble {
        switch Int(arc4random_uniform(4)) {
            // Generate random shape subclass.
        case 0:
            return GameBubble(color: "redBubble")
        case 1:
            return GameBubble(color: "blueBubble")
        case 2:
            return GameBubble(color: "greenBubble")
        default:
            return GameBubble(color: "orangeBubble")
        }
    }

}