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
    var bubbleGridBubbleContents: BubbleGridBubbleContents!
    
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
    
    func setGridContents (newContent: BubbleGridBubbleContents) {
        self.bubbleGridBubbleContents = newContent
    }
    
    func launchBubble(toLaunch: GameCircularCell, direction: CGPoint) {
        
        var xDisplacement = direction.x
        var yDisplacement = direction.y
        movableGameBubble.setVelocity(CGPoint(x: xDisplacement, y: yDisplacement))
        movableGameBubble.setSelection(toLaunch.getImage())
        currentMovingCell = toLaunch
    }
    
    
    func update() {
        self.gameState = false
        
        if (movableGameBubble.getVelocity().x != 0.0 && movableGameBubble.getVelocity().y != 0.0){
            if (!hitTopWall() && !hitOtherBubble()){
                // continue moving
                var currentX = currentMovingCell.center.x
                var currentY = currentMovingCell.center.y
                
                var toDisplaceX = movableGameBubble.getVelocity().x
                var toDisplaceY = movableGameBubble.getVelocity().y
                var newX = currentX + toDisplaceX
                var newY = currentY + toDisplaceY 
                if (!toDisplaceX.isNaN && !toDisplaceY.isNaN){
                    currentMovingCell.center = CGPoint(x: newX, y: newY)
                }
                if hitSideWall() {
                    movableGameBubble.setVelocity(CGPoint(x: toDisplaceX * -1.0, y: toDisplaceY))
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
        return self.gameState
    }
    
    func updateBubbleAtCollectionView() -> CGPoint {
        return self.toUpdate
    }
    
    func hitSideWall() -> Bool {
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
        for i in 0...bubbleGridBubbleContents.arrayOfBubbles.count - 1 {
            for j in 0...bubbleGridBubbleContents.arrayOfBubbles[i].count - 1 {
                if let currentCheck = bubbleGridBubbleContents.arrayOfBubbles[i][j] as GameCircularCell?{
                    var xDist = currentMovingCell.center.x - currentCheck.center.x
                    var yDist = currentMovingCell.center.y - currentCheck.center.y
                    if ( sqrt((xDist * xDist) + (yDist * yDist)) <= currentMovingCell.frame.width ) {
                        return true
                    }
                }
            }
        }
        return false
    }
}