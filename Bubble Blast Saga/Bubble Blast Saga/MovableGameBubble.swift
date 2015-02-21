//
//  MovableGameBubble.swift
//  Bubble Blast Saga
//
//  Created by Jingrong (: on 12/2/15.
//  Copyright (c) 2015 Lim Jing Rong. All rights reserved.
//

import Foundation
import UIKit
class MovableGameBubble {
    
    private var currentSelection: String = ""
    var velocity: CGPoint!
    
    init() {
        velocity = CGPoint(x: CGFloat(0.0), y: CGFloat(0.0))
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
    
    func reset() {
        self.velocity = CGPoint(x: CGFloat(0.0), y: CGFloat(0.0))
        self.currentSelection = ""
    }
    
}