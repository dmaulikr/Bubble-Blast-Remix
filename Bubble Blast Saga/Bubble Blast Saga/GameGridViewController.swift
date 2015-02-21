//
//  GameGridViewController.swift
//  Bubble Blast Saga
//
//  Created by Jingrong (: on 10/2/15.
//  Copyright (c) 2015 Lim Jing Rong. All rights reserved.
//

import UIKit

class GameGridViewController: UICollectionViewController {
    // Cell data representation for save/load
    private var indexingBubbles = [NSIndexPath : String]()
    private var gameGridBubbleContents: GameGridBubbleContents!
    
    // Custom init
    init(viewFrame: CGRect, collectionViewLayout: UICollectionViewLayout){
        super.init(collectionViewLayout: UICollectionViewLayout())
        indexingBubbles = [NSIndexPath : String] ()
        gameGridBubbleContents = GameGridBubbleContents()
        
        // Max 12 items per section.
        let cellSize = viewFrame.width/CGFloat(12)
        
        // Initialise the collection view
        let layout = GameGridViewLayout()
        layout.setItemSize(Double(cellSize))
        self.collectionView = UICollectionView(frame: viewFrame, collectionViewLayout: layout)
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        self.collectionView?.backgroundColor = UIColor.clearColor()
        self.collectionView?.registerClass(GameCircularCell.self, forCellWithReuseIdentifier: "bubbleCell")
        self.collectionView?.frame = viewFrame
        
        for column in 0...17 {
            gameGridBubbleContents.arrayOfBubbles.append(Array(count:12-(column%2), repeatedValue:GameCircularCell(frame: CGRect())))
        }
    }
    
    // Bug fixing code as xCode complains ( No idea what this does yet)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*********************** Required overriding functions for Collection Views *****************************/
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        let totalSectionsForScreen = 18
        return totalSectionsForScreen
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Alternates between 12 and 11 columns
        return (section % 2 == 0) ? 12:11
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> GameCircularCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("bubbleCell", forIndexPath: indexPath) as GameCircularCell
        return cell
    }
    
    /*********************************** Gameplay (PS4) ************************************/
    
    // Load from design view
    func loadIntoGame(toLoad: [[String]]) {
        for eachCol in 0...8 {
            for eachRow in 0...(11-(eachCol%2)) {
                var currentColor = toLoad[eachCol][eachRow]
                if currentColor != "" {
                    var indexPath = NSIndexPath(forRow: eachRow, inSection: eachCol)
                    if let selectedCell = self.collectionView?.cellForItemAtIndexPath(indexPath) as GameCircularCell?{
                        selectedCell.setImage(currentColor)
                        gameGridBubbleContents.appendIntoGrid(selectedCell, x: eachRow, y: eachCol)
                    }
                    
                }
            }
        }
    }
    
    
    func getGridContents() -> GameGridBubbleContents {
        return self.gameGridBubbleContents
    }
    
    // Adding bubble to the grid
    func addBubble(centerPoint: CGPoint, color: String) {
        let maxSection = 17
        
        // General case
        if let indexPathOfSelected = self.collectionView?.indexPathForItemAtPoint(centerPoint){
            // Check if it got appended to the last grid
            if (indexPathOfSelected.section >= maxSection) {
                endGame()
            } else {
                var selectedCell = self.collectionView?.cellForItemAtIndexPath(indexPathOfSelected) as GameCircularCell
                selectedCell.setImage(color)
                gameGridBubbleContents.appendIntoGrid(selectedCell, x: indexPathOfSelected.row, y: indexPathOfSelected.section)
                bubblesToPop(indexPathOfSelected.row, currentY: indexPathOfSelected.section, currentColor: selectedCell.getImage())
            }
            
        } else {
            // Slight offsets for handling bubbles right in between 2 cells at end grids
            var newPoint = CGPoint(x: centerPoint.x + 3.0, y: centerPoint.y + 3.0)
            if let indexPathOfSelected = self.collectionView?.indexPathForItemAtPoint(newPoint){
                // Check if it got appended to the last grid
                if (indexPathOfSelected.section >= maxSection) {
                    endGame()
                } else {
                    var selectedCell = self.collectionView?.cellForItemAtIndexPath(indexPathOfSelected) as GameCircularCell
                    selectedCell.setImage(color)
                    gameGridBubbleContents.appendIntoGrid(selectedCell, x: indexPathOfSelected.row, y: indexPathOfSelected.section)
                    bubblesToPop(indexPathOfSelected.row, currentY: indexPathOfSelected.section, currentColor: selectedCell.getImage())
                }
                
            } else {
                // Alternative offset.
                var newPoint2 = CGPoint(x: centerPoint.x - 10.0, y: centerPoint.y)
                if let indexPathOfSelected = self.collectionView?.indexPathForItemAtPoint(newPoint2){
                    // Check if it got appended to the last grid
                    if (indexPathOfSelected.section >= maxSection) {
                        endGame()
                    } else {
                        var selectedCell = self.collectionView?.cellForItemAtIndexPath(indexPathOfSelected) as GameCircularCell
                        selectedCell.setImage(color)
                        gameGridBubbleContents.appendIntoGrid(selectedCell, x: indexPathOfSelected.row, y: indexPathOfSelected.section)
                        bubblesToPop(indexPathOfSelected.row, currentY: indexPathOfSelected.section, currentColor: selectedCell.getImage())
                    }
                }
            }
        }
        // Check for bubbles not connected to top row after poppings
        bubblesToDrop()
        
    }
    
    private func endGame() {
        let loadPrompt = UIAlertController(title: "Game over!", message: "Try again on new grid?", preferredStyle: UIAlertControllerStyle.Alert)
        loadPrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            // Reset the grid
            var allCells = self.collectionView?.visibleCells() as [GameCircularCell]
            for cell in allCells {
                cell.removeImage()
                cell.backgroundView = UIView()
            }
        }))
        presentViewController(loadPrompt, animated: true, completion: nil)
        self.gameGridBubbleContents = GameGridBubbleContents()
    }
    
    
    // Check if newly snapped on bubble pops anything
    func bubblesToPop(currentX: Int, currentY: Int, currentColor: String) {
        // Uses CGPoint as a convenience to store x / y
        var bubblesToPop = [GameCircularCell]()
        bubblesToPop.append(convertXYintoCell(currentX, y: currentY))
        var visited = [CGPoint]()
        // array to count number of elements
        var startPoint = CGPoint(x: currentX, y: currentY)
        var neighbors = [CGPoint]()
        
        // Use BFS
        var queue = Queue<CGPoint>()
        queue.enqueue(startPoint)
        visited.append(startPoint)
        
        
        while (!queue.isEmpty){
            var currentNode = queue.dequeue()
            // Appending neighbors for this node
            neighbors = getNeighbours(currentNode!)
            
            // Iterate through all neighbors
            for neighborNodes in neighbors {
                if !contains(visited, neighborNodes) {
                    visited.append(neighborNodes)
                    // CHECK IF COLOR SAME, enqueue only if
                    var sectionNum = Int(neighborNodes.y)
                    var rowNum = Int(neighborNodes.x)
                    var cell = convertXYintoCell(rowNum, y: sectionNum)
                    var colorOfNeighborNode = cell.getImage()
                    if (currentColor == colorOfNeighborNode){
                        bubblesToPop.append(cell)
                        queue.enqueue(neighborNodes)
                    }
                }
            }
            neighbors = [CGPoint]()
        }
        // Check if there are bubbles to pop
        if bubblesToPop.count > 2 {
            for eachCell in bubblesToPop {
                var cellPoint = convertCellintoXY(eachCell)
                var bubbleToMove = GameCircularCell(frame: eachCell.frame)
                bubbleToMove.setImage(eachCell.getImage())
                // Layer animation view on top
                self.collectionView?.insertSubview(bubbleToMove as UIView, aboveSubview: self.collectionView!)
                UIView.animateWithDuration(NSTimeInterval(1.0), animations: {
                    // Pseudo-Zoom for dramatic effect
                    bubbleToMove.frame = CGRect(x: eachCell.center.x, y: eachCell.center.y, width: 150, height: 150)
                    // Fade
                    bubbleToMove.alpha = 0.15
                    }, completion: { finished in
                        bubbleToMove.removeFromSuperview()
                })
                
                
                // remove the bubbleToMove view?
                eachCell.removeImage()
                eachCell.backgroundView!.alpha = 0
                gameGridBubbleContents.arrayOfBubbles[Int(cellPoint.x)][Int(cellPoint.y)] = GameCircularCell(frame: CGRect())
            }
        } else {
            visited = [CGPoint]()
        }
    }
    
    // Check if there's any bubbles which needs to be dropped as it's no longer connected
    func bubblesToDrop() {
        var bubblesToDrop = [GameCircularCell]()
        // Run bfs on each cell fromt top row and check which cells are not visited.
        var queue = Queue<CGPoint>()
        var visited = [CGPoint]()
        var neighbors = [CGPoint]()
        var startNode = CGPoint()
        
        // 12 grids at the top
        for i in 0...11 {
            startNode.x = CGFloat(i)
            startNode.y = CGFloat(0) // Always from top
            var startCell = convertXYintoCell(i, y: 0)
            if startCell.getImage() != "" {
                visited.append(startNode)
                queue.enqueue(startNode)
            }
            
            while (!queue.isEmpty) {
                var currentNode = queue.dequeue()
                neighbors = getNeighbours(currentNode!)
                for neighborNodes in neighbors {
                    if !contains(visited, neighborNodes) {
                        var cell = convertXYintoCell(Int(neighborNodes.x), y: Int(neighborNodes.y))
                        if (cell.getImage() != ""){
                            visited.append(neighborNodes)
                            queue.enqueue(neighborNodes)
                        }
                    }
                }
                neighbors = [CGPoint]()
            }
        }
        
        // Remove all 'unvisited cells', which are not connected to top row
        for i in 0...(gameGridBubbleContents.arrayOfBubbles.count - 1){
            for j in 0...(gameGridBubbleContents.arrayOfBubbles[i].count - 1) {
                var checkPoint = CGPoint(x: i, y: j)
                if !(contains(visited, checkPoint)){
                    if gameGridBubbleContents.arrayOfBubbles[i][j].getImage() != "" {
                        
                        var cell = self.gameGridBubbleContents.arrayOfBubbles[i][j]
                        
                        // Active drop bubble
                        var bubbleToMove = GameCircularCell(frame: cell.frame)
                        bubbleToMove.setImage(cell.getImage())
                        
                        // Layer it on top
                        self.collectionView?.insertSubview(bubbleToMove as UIView, aboveSubview: self.collectionView!)
                        
                        UIView.animateWithDuration(NSTimeInterval(2.5), animations: {
                            // Dropping animation
                            bubbleToMove.frame = CGRectMake( bubbleToMove.center.x , 1100.0, bubbleToMove.frame.width, bubbleToMove.frame.height)
                            bubbleToMove.backgroundView!.alpha = 0
                            }, completion: { finished in
                                bubbleToMove.removeFromSuperview()
                        })
                        
                        // Remove the grid's view & update data structure
                        gameGridBubbleContents.arrayOfBubbles[i][j].backgroundView!.alpha = 0
                        gameGridBubbleContents.arrayOfBubbles[i][j].removeImage()
                        gameGridBubbleContents.arrayOfBubbles[i][j] = GameCircularCell(frame: CGRect())
                    }
                }
            }
        }
        visited = [CGPoint]()
    }
    
    func reset() {
        for i in 0...(gameGridBubbleContents.arrayOfBubbles.count - 1){
            for j in 0...(gameGridBubbleContents.arrayOfBubbles[i].count - 1) {
                // Remove the grid's view & update data structure
                if gameGridBubbleContents.arrayOfBubbles[i][j].getImage() != "" {
                    gameGridBubbleContents.arrayOfBubbles[i][j].backgroundView!.alpha = 0
                    gameGridBubbleContents.arrayOfBubbles[i][j].removeImage()
                    gameGridBubbleContents.arrayOfBubbles[i][j] = GameCircularCell(frame: CGRect())
                }
                
            }
        }
        
    }
    
    // Helper functions for ease of conversion
    private func convertCellintoXY(cell: GameCircularCell) -> CGPoint {
        var cellIndexPath = self.collectionView?.indexPathForCell(cell) as NSIndexPath?
        var newPoint = CGPoint(x: cellIndexPath!.row, y: cellIndexPath!.section)
        return newPoint
    }
    
    private func convertXYintoCell(x: Int, y: Int) -> GameCircularCell {
        var cellIndexPath = NSIndexPath(forRow: x, inSection: y)
        if let cell = self.collectionView?.cellForItemAtIndexPath(cellIndexPath) as GameCircularCell? {
            return cell
        }
        return GameCircularCell(frame: CGRect())
    }
    
    // Returns array of CGPoint for neighbors of a node
    private func getNeighbours(currentNode: CGPoint) -> [CGPoint] {
        var arr = [CGPoint]()
        let maxSectionNumber = CGFloat(18)
        // Even
        if (currentNode.y % 2 == 0) {
            let maxRowNumber = CGFloat(13)
            // Horizontal
            if (currentNode.x > 0) {
                arr.append(CGPoint(x: currentNode.x - 1, y: currentNode.y))
            }
            if (currentNode.x < maxRowNumber) {
                arr.append(CGPoint(x: currentNode.x + 1, y: currentNode.y))
            }
            // Diagonal
            if (currentNode.y > 0) {
                if (currentNode.x < maxRowNumber){
                    arr.append(CGPoint(x: currentNode.x , y: currentNode.y - 1))
                }
                if (currentNode.x > 0) {
                    arr.append(CGPoint(x: currentNode.x - 1, y: currentNode.y - 1))
                }
            }
            if (currentNode.y < maxSectionNumber) {
                if (currentNode.x < maxRowNumber){
                    arr.append(CGPoint(x: currentNode.x , y: currentNode.y + 1))
                }
                if (currentNode.x > 0) {
                    arr.append(CGPoint(x: currentNode.x - 1, y: currentNode.y + 1))
                }
            }
        } else {
            // Odd row
            // Horizontal
            let maxRowNumber = CGFloat(12)
            if (currentNode.x > 0) {
                arr.append(CGPoint(x: currentNode.x - 1, y: currentNode.y))
            }
            if (currentNode.x < maxRowNumber) {
                arr.append(CGPoint(x: currentNode.x + 1, y: currentNode.y))
            }
            // Diagonal
            if (currentNode.y > 0){
                if (currentNode.x < maxRowNumber) {
                    arr.append(CGPoint(x: currentNode.x + 1 , y: currentNode.y - 1))
                }
                if (currentNode.x >= 0) {
                    arr.append(CGPoint(x: currentNode.x , y: currentNode.y - 1))
                }
            }
            if (currentNode.y < maxSectionNumber) {
                if (currentNode.x < maxRowNumber) {
                    arr.append(CGPoint(x: currentNode.x + 1 , y: currentNode.y + 1))
                }
                if (currentNode.x >= 0) {
                    arr.append(CGPoint(x: currentNode.x , y: currentNode.y + 1))
                }
            }
        }
        
        return arr
    }
    
}
