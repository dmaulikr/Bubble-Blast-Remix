//
//  GameBubble.swift
//  LevelDesigner
//
//  Created by Jingrong (: on 3/2/15.
//  Copyright (c) 2015 NUS CS3217. All rights reserved.
//


class GameBubble {
    
    private var currentSelection: String = ""
    
    init() {
        currentSelection = ""
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
}