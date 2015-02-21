//
//  GameEngine.swift
//  Bubble Blast Saga
//
//  Created by Jingrong (: on 13/2/15.
//  Copyright (c) 2015 Lim Jing Rong. All rights reserved.
//


import UIKit

class GameEngine: NSObject {
    
    var movableGameBubble = MovableGameBubble()
    var currentMovingCell = GameCircularCell(frame: CGRect())
    var iPadView = UIView()
    var gameState = Bool()
    var toUpdate = CGPoint()
    var gameGridBubbleContents: GameGridBubbleContents!
    
    override init () {
        super.init()
        movableGameBubble = MovableGameBubble()
        currentMovingCell = GameCircularCell(frame: CGRect())
        iPadView = UIView()
        gameState = false
    }
    
    func setiPadView(originalView : UIView) {
        self.iPadView = originalView
    }
    
    func setGridContents (newContent: GameGridBubbleContents) {
        self.gameGridBubbleContents = newContent
    }
    
    func launchBubble(toLaunch: GameCircularCell, direction: CGPoint) {
        
        var xDisplacement = direction.x
        var yDisplacement = direction.y
        movableGameBubble.velocity = (CGPoint(x: xDisplacement, y: yDisplacement))
        movableGameBubble.setSelection(toLaunch.getImage())
        currentMovingCell = toLaunch
    }
    
    
    func update() {
        self.gameState = false
        
        if (movableGameBubble.velocity.x != 0.0 && movableGameBubble.velocity.y != 0.0){
            if (!hitTopWall() && !hitOtherBubble()){
                // continue moving
                var currentX = currentMovingCell.center.x
                var currentY = currentMovingCell.center.y
                
                var toDisplaceX = movableGameBubble.velocity.x
                var toDisplaceY = movableGameBubble.velocity.y
                var newX = currentX + toDisplaceX
                var newY = currentY + toDisplaceY 
                if (!toDisplaceX.isNaN && !toDisplaceY.isNaN){
                    currentMovingCell.center = CGPoint(x: newX, y: newY)
                }
                if hitSideWall() {
                    movableGameBubble.velocity = (CGPoint(x: toDisplaceX * -1.0, y: toDisplaceY))
                }
                
            } else {
                // Time to snap it into grid, and update grid of popping/dropping
                toUpdate = currentMovingCell.center
                movableGameBubble.reset()
                
                // Welcome new bubble
                self.gameState = true
            }
        }
        
    }
    
    func bubbleJob() -> Bool {
        // Game state to disable further gesture actions while bubble is travelling
        return self.gameState
    }
    
    // Gives the bubble position to 'snap' into the collection view
    func updateBubbleAtCollectionView() -> CGPoint {
        return self.toUpdate
    }
    
    /**************************************** Methods to check collisions ****************************************/
    
    private func hitSideWall() -> Bool {
        if (currentMovingCell.frame.width == 0){
            // there is no movng cell now
            return false
        }
        let iPadWidth = iPadView.frame.width
        if (currentMovingCell.center.x + CGFloat(currentMovingCell.frame.width/2.0) > iPadWidth){
            return true
        } else if (currentMovingCell.center.x - CGFloat(currentMovingCell.frame.width/2.0) <= 0){
            return true
        }
        return false
    }
    
    private func hitTopWall() -> Bool {
        if (currentMovingCell.center.y - CGFloat(currentMovingCell.frame.width/2.0)) <= 0{
            return true
        }
        return false
    }
    
    private func hitOtherBubble() -> Bool {
        for i in 0...gameGridBubbleContents.arrayOfBubbles.count - 1 {
            for j in 0...gameGridBubbleContents.arrayOfBubbles[i].count - 1 {
                if let currentCheck = gameGridBubbleContents.arrayOfBubbles[i][j] as GameCircularCell?{
                    let xDist = currentMovingCell.center.x - currentCheck.center.x
                    let yDist = currentMovingCell.center.y - currentCheck.center.y
                    if ( sqrt((xDist * xDist) + (yDist * yDist)) <= currentMovingCell.frame.width ) {
                        return true
                    }
                }
            }
        }
        return false
    }
}