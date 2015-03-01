//
//  BubbleGridBubbleContents.swift
//  Bubble Blast Saga
//
//  Created by Jingrong (: on 14/2/15.
//  Copyright (c) 2015 Lim Jing Rong. All rights reserved.
//

import Foundation
import UIKit

class GameGridBubbleContents {
    private var gameCell: GameCircularCell!
    var arrayOfBubbles = [[GameCircularCell]]()
    
    init() {
        gameCell = GameCircularCell(frame: CGRect())
        // Iterate through the sections and rows
        let maxRow = 12
        let maxCol = 18
        
        for row in 0...maxRow {
            arrayOfBubbles.append(Array(count:maxCol, repeatedValue:gameCell))
        }
    }
    
    func appendIntoGrid(newBubble: GameCircularCell, x : Int, y: Int) {
        arrayOfBubbles[x][y] = newBubble
    }
    
}
