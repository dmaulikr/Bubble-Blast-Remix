//
//  GameGridViewController.swift
//  Bubble Blast Saga
//
//  Created by Jingrong (: on 10/2/15.
//  Copyright (c) 2015 Lim Jing Rong. All rights reserved.
//

import UIKit
import AVFoundation

class GameGridViewController: UICollectionViewController {
    // Cell data representation for save/load
    private var indexingBubbles = [NSIndexPath : String]()
    private var gameGridBubbleContents: GameGridBubbleContents!
    var isAnimating = Bool()
    private var queue = Queue<CGPoint>()
    var gameDidEnd = Bool()
    private var bubbleBurstImages = [UIImage]()
    private var bubbleBombImages = [UIImage]()
    private var lightningImages = [UIImage]()
    
    // sound effects
    var starPlayer: AVAudioPlayer!
    var lightningPlayer: AVAudioPlayer!
    var bombPlayer: AVAudioPlayer!
    var popPlayer: AVAudioPlayer!
    
    /*
    Score is implemented:
    Drop: 5 + 10 + 15... up to 25 each
    Bomb: No points
    Pop: 10 per bubble
    */
    var score = Int();
    
    // Custom init
    init(viewFrame: CGRect, collectionViewLayout: UICollectionViewLayout){
        super.init(collectionViewLayout: UICollectionViewLayout())
        indexingBubbles = [NSIndexPath : String] ()
        gameGridBubbleContents = GameGridBubbleContents()
        score = 0;
        gameDidEnd = false
        
        // Max 12 items per section.
        let maxBubblesPerRow = 12
        let cellSize = viewFrame.width/CGFloat(maxBubblesPerRow)
        
        // Initialise the collection view
        let layout = GameGridViewLayout()
        layout.setItemSize(Double(cellSize))
        self.collectionView = UICollectionView(frame: viewFrame, collectionViewLayout: layout)
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        self.collectionView?.backgroundColor = UIColor.clearColor()
        self.collectionView?.registerClass(GameCircularCell.self, forCellWithReuseIdentifier: "bubbleCell")
        self.collectionView?.frame = viewFrame
        
        let maxColumn = 18
        let maxRow = 12
        for column in 0...maxColumn-1 {
            gameGridBubbleContents.arrayOfBubbles.append(Array(count:maxRow-(column%2), repeatedValue:GameCircularCell(frame: CGRect())))
        }
        
        // Load special bubble sound effects
        loadSoundEffects()
        
        // Prepare visual animations
        loadAnimations()
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
        let maxBubblesPerRow = 12
        return (section % 2 == 0) ? maxBubblesPerRow : (maxBubblesPerRow - 1)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> GameCircularCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("bubbleCell", forIndexPath: indexPath) as GameCircularCell
        return cell
    }
    
    /*********************************** Gameplay (PS4) ************************************/
    
    private func loadSoundEffects() {
        // Sound effect for star bubble
        let starPath = NSBundle.mainBundle().pathForResource("starPowerup", ofType: "wav")!
        let starURL = NSURL(fileURLWithPath: starPath)
        starPlayer = AVAudioPlayer(contentsOfURL: starURL, error: nil)
        starPlayer.prepareToPlay()
        
        // Sound effect for lightning bubble
        let lightningPath = NSBundle.mainBundle().pathForResource("lightningPowerup", ofType: "mp3")!
        let lightningURL = NSURL(fileURLWithPath: lightningPath)
        lightningPlayer = AVAudioPlayer(contentsOfURL: lightningURL, error: nil)
        lightningPlayer.volume = 0.3
        lightningPlayer.prepareToPlay()
        
        // Sound effects for bomb bubble
        let bombPath = NSBundle.mainBundle().pathForResource("bombPowerup", ofType: "wav")!
        let bombURL = NSURL(fileURLWithPath: bombPath)
        bombPlayer = AVAudioPlayer(contentsOfURL: bombURL, error: nil)
        bombPlayer.volume = 0.3
        bombPlayer.prepareToPlay()
        
        // Sound effects for pop bubble
        let popPath = NSBundle.mainBundle().pathForResource("bubblePop", ofType: "mp3")!
        let popURL = NSURL(fileURLWithPath: popPath)
        popPlayer = AVAudioPlayer(contentsOfURL: popURL, error: nil)
        popPlayer.prepareToPlay()
    }
    
    private func loadAnimations() {
        
        // Bubble burst animation
        // 4 images in 640 x 160
        let horizontalCount = 4
        let verticalCount = 1
        let bubbleBurstImageHeight = (160.0 / CGFloat(verticalCount)) as CGFloat
        let bubbleBurstImageWidth = (640.0 / CGFloat(horizontalCount)) as CGFloat
        var bubbleBurstImageToSplit = UIImage(named: "bubble-burst.png")?.CGImage
        // Loading all sprites of cannons into array
        for i in 0...verticalCount - 1 {
            for j in 0...horizontalCount - 1 {
                var yValue = CGFloat(i) * bubbleBurstImageHeight
                var xValue = CGFloat(j) * bubbleBurstImageWidth
                var partOfImageAsCG = CGImageCreateWithImageInRect(bubbleBurstImageToSplit, CGRectMake(xValue, yValue, bubbleBurstImageWidth, bubbleBurstImageHeight)) as CGImageRef
                bubbleBurstImages.append(UIImage(CGImage: partOfImageAsCG)!)
            }
        }
        
        // Bubble explode animation
        // 5*5 image in 320 by 320
        let bombHorizontalCount = 5
        let bombVerticalCount = 5
        let bombImageHeight = (320.0 / CGFloat(bombVerticalCount)) as CGFloat
        let bombImageWidth = (320.0 / CGFloat(bombHorizontalCount)) as CGFloat
        var bombImageToSplit = UIImage(named: "bubbleExplode.png")?.CGImage
        // Loading all sprites
        for i in 0...bombVerticalCount - 1 {
            for j in 0...bombHorizontalCount - 1 {
                var yValue = CGFloat(i) * bombImageHeight
                var xValue = CGFloat(j) * bombImageWidth
                var partOfImageAsCG = CGImageCreateWithImageInRect(bombImageToSplit, CGRectMake(xValue, yValue, bombImageWidth, bombImageHeight)) as CGImageRef
                bubbleBombImages.append(UIImage(CGImage: partOfImageAsCG)!)
            }
        }
        
        // Bubble explode animation
        // 8 image in 1024 * 512
        let lightningHorizontalCount = 8
        let lightningVerticalCount = 1
        let lightningImageHeight = (512.0 / CGFloat(lightningVerticalCount)) as CGFloat
        let lightningImageWidth = (1024.0 / CGFloat(lightningHorizontalCount)) as CGFloat
        var lightningImageToSplit = UIImage(named: "lightningSprite.png")?.CGImage
        // Loading all sprites
        for i in 0...lightningVerticalCount - 1 {
            for j in 0...lightningHorizontalCount - 1 {
                var yValue = CGFloat(i) * lightningImageHeight
                var xValue = CGFloat(j) * lightningImageWidth
                var partOfImageAsCG = CGImageCreateWithImageInRect(lightningImageToSplit, CGRectMake(xValue, yValue, lightningImageWidth, lightningImageHeight)) as CGImageRef
                lightningImages.append(UIImage(CGImage: partOfImageAsCG)!)
            }
        }
    }
    
    // Load from design view
    func loadIntoGame(toLoad: [[String]]) {
        let maxCol = 9
        let maxRow = 12
        
        for eachCol in 0...(maxCol - 1) {
            for eachRow in 0...(maxRow - 1 - (eachCol%2)) {
                if let currentColor = toLoad[eachCol][eachRow] as String?{
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
    }
    
    func getGridContents() -> GameGridBubbleContents {
        return self.gameGridBubbleContents
    }
    
    // Adding launched bubble to the grid
    func addBubble(centerPoint: CGPoint, color: String) {
        isAnimating = true
        
        // General case
        if let indexPathOfSelected = self.collectionView?.indexPathForItemAtPoint(centerPoint){
            var selectedCell = self.collectionView?.cellForItemAtIndexPath(indexPathOfSelected) as GameCircularCell
            selectedCell.setImage(color)
            gameGridBubbleContents.appendIntoGrid(selectedCell, x: indexPathOfSelected.row, y: indexPathOfSelected.section)
            bubblesToPop(indexPathOfSelected.row, currentY: indexPathOfSelected.section, currentColor: selectedCell.getImage())
            
        } else {
            // Slight offsets for handling bubbles right in between 2 cells at end grids
            var newPoint = CGPoint(x: centerPoint.x + 3.0, y: centerPoint.y + 3.0)
            if let indexPathOfSelected = self.collectionView?.indexPathForItemAtPoint(newPoint){
                var selectedCell = self.collectionView?.cellForItemAtIndexPath(indexPathOfSelected) as GameCircularCell
                selectedCell.setImage(color)
                gameGridBubbleContents.appendIntoGrid(selectedCell, x: indexPathOfSelected.row, y: indexPathOfSelected.section)
                bubblesToPop(indexPathOfSelected.row, currentY: indexPathOfSelected.section, currentColor: selectedCell.getImage())
                
            } else {
                // Alternative offset.
                var newPoint2 = CGPoint(x: centerPoint.x - 10.0, y: centerPoint.y)
                if let indexPathOfSelected = self.collectionView?.indexPathForItemAtPoint(newPoint2){
                    var selectedCell = self.collectionView?.cellForItemAtIndexPath(indexPathOfSelected) as GameCircularCell
                    selectedCell.setImage(color)
                    gameGridBubbleContents.appendIntoGrid(selectedCell, x: indexPathOfSelected.row, y: indexPathOfSelected.section)
                    bubblesToPop(indexPathOfSelected.row, currentY: indexPathOfSelected.section, currentColor: selectedCell.getImage())
                }
            }
        }
        // Check if game ended
        let endGameSection = 15
        let maxRows = 12
        for row in 0...maxRows{
            if (self.gameGridBubbleContents.arrayOfBubbles[row][endGameSection].getImage() != "") {
                self.endGame()
            }
        }
        
        // Check for bubbles not connected to top row after poppings
        delay(0.1){
            self.bubblesToDrop()
        }
        
        isAnimating = false
        
    }
    
    private func endGame() {
        gameDidEnd = true
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
        var checkForSpecialBubblesNeighbours = [CGPoint]()
        checkForSpecialBubblesNeighbours = getNeighbours(startPoint)
        
        // Use BFS
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
        queue.removeAll()
        // Check if there are bubbles to pop
        if bubblesToPop.count > 2 {
            for eachCell in bubblesToPop {
                popThisBubble(eachCell)
            }
        } else {
            visited = [CGPoint]()
        }
        
        // Check if hit special bubbles
        for neighborNodes in checkForSpecialBubblesNeighbours {
            var sectionNum = Int(neighborNodes.y)
            var rowNum = Int(neighborNodes.x)
            var cell = convertXYintoCell(rowNum, y: sectionNum)
            
            // Check the cell color
            if (cell.getImage() == "lightningBubble"){
                popThisBubble(convertXYintoCell(currentX, y: currentY))
                zapWholeSection(cell)
                bombThisBubble(cell)
            } else if (cell.getImage() == "bombBubble"){
                // Get all neighbors of this cell and pop them
                bombAdjacentCells(cell)
            } else if (cell.getImage() == "starBubble"){
                // Pop everything which is the same color.
                starPlayer.play()
                for row in 0...gameGridBubbleContents.arrayOfBubbles.count-1 {
                    for col in 0...gameGridBubbleContents.arrayOfBubbles[row].count-1{
                        if gameGridBubbleContents.arrayOfBubbles[row][col].getImage() == currentColor{
                            popThisBubble(gameGridBubbleContents.arrayOfBubbles[row][col])
                        }
                    }
                }
                popThisBubble(cell)
            }
        }
        
        // Contains chained
        while (!queue.isEmpty){
            var currentPoint = queue.dequeue()
            var currentCell = convertXYintoCell(Int(currentPoint!.x), y: Int(currentPoint!.y))
            if (currentCell.getImage() == "lightningBubble"){
                zapWholeSection(currentCell)
            } else if (currentCell.getImage() == "bombBubble"){
                // Get all neighbors of this cell and pop them
                self.bombAdjacentCells(currentCell)
            } else if (currentCell.getImage() == "starBubble"){
                starPlayer.play()
                for row in 0...gameGridBubbleContents.arrayOfBubbles.count-1 {
                    for col in 0...gameGridBubbleContents.arrayOfBubbles[row].count-1{
                        if gameGridBubbleContents.arrayOfBubbles[row][col].getImage() == currentColor{
                            popThisBubble(gameGridBubbleContents.arrayOfBubbles[row][col])
                        }
                    }
                }
                popThisBubble(currentCell)
            } else {
                popThisBubble(currentCell)
            }
        }
        queue.removeAll()
        
    }
    
    // Function to handle bombs
    private func bombAdjacentCells(bombCell: GameCircularCell) {
        let bombPoint = convertCellintoXY(bombCell)
        let adjacentPoint = getNeighbours(bombPoint)
        for eachPoint in adjacentPoint {
            var cellToBomb = convertXYintoCell(Int(eachPoint.x), y: Int(eachPoint.y))
            if cellToBomb.getImage() == "lightningBubble" {
                queue.enqueue(eachPoint)
            } else if cellToBomb.getImage() == "bombBubble" {
                queue.enqueue(eachPoint)
            } else if cellToBomb.getImage() == "starBubble" {
                queue.enqueue(eachPoint)
            } else if cellToBomb.getImage() != "" {
                popThisBubble(cellToBomb)
            }
        }
        bombThisBubble(bombCell)
    }
    
    // Function to handle lightning
    private func zapWholeSection(lightningCell: GameCircularCell) {
        zapPoint(lightningCell.center)
        lightningPlayer.play()
        let lightningPoint = convertCellintoXY(lightningCell)
        let col = Int(lightningPoint.y)
        // Remove everything on this row
        for row in 0...(gameGridBubbleContents.arrayOfBubbles.count-1) {
            if gameGridBubbleContents.arrayOfBubbles[row][col].getImage() == "bombBubble" {
                queue.enqueue(convertCellintoXY(gameGridBubbleContents.arrayOfBubbles[row][col]))
            } else if gameGridBubbleContents.arrayOfBubbles[row][col].getImage() == "starBubble" {
                queue.enqueue(convertCellintoXY(gameGridBubbleContents.arrayOfBubbles[row][col]))
            } else if (gameGridBubbleContents.arrayOfBubbles[row][col].getImage() != "") {
                popThisBubble(gameGridBubbleContents.arrayOfBubbles[row][col])
            }
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
        
        var pointToAdd = 5
        
        let totalBubblesAtTop = 12
        for i in 0...(totalBubblesAtTop - 1) {
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
                        
                        // Update score
                        score = score + pointToAdd
                        // Exponential bonus for each drop
                        if (pointToAdd <= 25){
                            pointToAdd = pointToAdd + 5
                        }
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
    
    /*************************************** Animations **************************************/
    // Lightning
    private func zapPoint(targetPoint: CGPoint) {
        let cellDiameter = 64.0 as CGFloat
        var lightningImageView = UIImageView()
        
        // ratio of height to width is 4:1
        let scaleFactor = 2.5 as CGFloat
        lightningImageView.frame = CGRect(x: targetPoint.x - cellDiameter, y: (targetPoint.y - cellDiameter), width: (cellDiameter * scaleFactor), height: cellDiameter * (scaleFactor * 4.0))
        
        
        lightningImageView.animationImages = lightningImages
        lightningImageView.animationDuration = 0.5
        self.collectionView?.insertSubview(lightningImageView as UIImageView, aboveSubview: self.collectionView!)
        lightningImageView.startAnimating()
        delay(0.5) {
            lightningImageView.stopAnimating()
            lightningImageView.removeFromSuperview()
        }
    }
    
    // Bombing
    private func bombThisBubble(toPop: GameCircularCell) {
        if (toPop.getImage() != "lightningBubble"){
            bombPlayer.play()
        }
        var cellPoint = convertCellintoXY(toPop)
        var bubbleToMove = GameCircularCell(frame: toPop.frame)
        bubbleToMove.setImage(toPop.getImage())
        
        let cellDiameter = 64.0 as CGFloat
        // Bomb effect
        var bombImageView = UIImageView()
        // Scale the frame larger
        bombImageView.frame = CGRect(x: toPop.center.x - (cellDiameter * 2.0), y: toPop.center.y - (cellDiameter * 2.0), width: cellDiameter * 4.0, height: cellDiameter * 4.0)
        bombImageView.animationImages = bubbleBombImages
        bombImageView.animationDuration = 0.5
        // Layer animation view on top
        self.collectionView?.insertSubview(bombImageView as UIImageView, aboveSubview: self.collectionView!)
        bombImageView.startAnimating()
        delay(0.5) {
            bombImageView.stopAnimating()
            bombImageView.removeFromSuperview()
        }
        toPop.removeImage()
        toPop.backgroundView!.alpha = 0
        
        gameGridBubbleContents.arrayOfBubbles[Int(cellPoint.x)][Int(cellPoint.y)] = GameCircularCell(frame: CGRect())
        score += 50
    }
    
    // Popping animation
    private func popThisBubble(toPop: GameCircularCell) {
        popPlayer.play()
        if (toPop.getImage() != "indestructibleBubble"){
            var cellPoint = convertCellintoXY(toPop)
            var bubbleToMove = GameCircularCell(frame: toPop.frame)
            bubbleToMove.setImage(toPop.getImage())
            
            // Layer animation view on top
            // Bubble burst effect
            var bubbleBurstImageView = UIImageView()
            bubbleBurstImageView.frame = bubbleToMove.frame
            bubbleBurstImageView.animationImages = bubbleBurstImages
            bubbleBurstImageView.animationDuration = 0.5
            self.collectionView?.insertSubview(bubbleBurstImageView as UIImageView, aboveSubview: self.collectionView!)
            bubbleBurstImageView.startAnimating()
            delay(0.5) {
                bubbleBurstImageView.stopAnimating()
                bubbleBurstImageView.removeFromSuperview()
            }
            
            self.collectionView?.insertSubview(bubbleToMove as UIView, aboveSubview: self.collectionView!)
            UIView.animateWithDuration(NSTimeInterval(0.5), animations: {
                // Fade
                bubbleToMove.alpha = 0.15
                }, completion: { finished in
                    bubbleToMove.removeFromSuperview()
            })
            
            toPop.removeImage()
            toPop.backgroundView!.alpha = 0
            gameGridBubbleContents.arrayOfBubbles[Int(cellPoint.x)][Int(cellPoint.y)] = GameCircularCell(frame: CGRect())
            score += 10
        }
    }
    
    private func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
}
