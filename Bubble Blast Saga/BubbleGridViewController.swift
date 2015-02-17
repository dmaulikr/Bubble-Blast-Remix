//
//  BubbleGridViewController.swift
//  LevelDesigner
//
//  Created by Jingrong (: on 2/2/15.
//  Copyright (c) 2015 NUS CS3217. All rights reserved.
//

import UIKit

class BubbleGridViewController: UICollectionViewController {
    
    // Cell data representation for save/load
    private var indexingBubbles = [NSIndexPath : String]()
    private var gameBubble: GameBubble!
    
    // Custom init
    init(viewFrame: CGRect, collectionViewLayout: UICollectionViewLayout){
        super.init(collectionViewLayout: UICollectionViewLayout())
        gameBubble = GameBubble()
        indexingBubbles = [NSIndexPath : String] ()
        
        // Max 12 items per section. Offset additionally for borders
        let cellSize = viewFrame.width/CGFloat(12.34)
        
        // Initialise the collection view
        let layout = BubbleGridViewLayout()
        layout.setItemSize(Double(cellSize))
        self.collectionView = UICollectionView(frame: viewFrame, collectionViewLayout: layout)
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        self.collectionView?.backgroundColor = UIColor.clearColor()
        self.collectionView?.registerClass(CircularCell.self, forCellWithReuseIdentifier: "bubbleCell")
        self.collectionView?.frame = viewFrame
        
        // Gesture recognizers
        let panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(self, action: "handlePan:")
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        self.collectionView?.addGestureRecognizer(panGesture)
        
        let longPressGesture = UILongPressGestureRecognizer()
        longPressGesture.addTarget(self, action: "handleLongPress:")
        longPressGesture.minimumPressDuration = 1
        self.collectionView?.addGestureRecognizer(longPressGesture)
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: "handleTap:")
        self.collectionView?.addGestureRecognizer(tapGesture)
    }
    
    // Bug fixing code as xCode complains ( No idea what this does yet)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*********************** Required overriding functions for Collection Views *****************************/
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // 9 sections
        return 9
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Alternates between 12 and 11 columns
        return (section % 2 == 0) ? 12:11
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("bubbleCell", forIndexPath: indexPath) as UICollectionViewCell
        
        return cell
    }
    
    
    /*********************** Palette button pressing *****************************/
    
    func setGameBubble (gameBubbleFromViewController: GameBubble){
        self.gameBubble = gameBubbleFromViewController
    }
    
    /************************* For saving / loading ******************************/
    
    func wipeColorIndexing() {
        indexingBubbles = [NSIndexPath : String]()
    }
    
    func updateDictionary(updatedLoad: [NSIndexPath: String]) {
        for key in updatedLoad.keys {
            var currentColor = updatedLoad[key]
            indexingBubbles[key] = currentColor
        }
    }
    
    func getBubbleIndexPositions() -> NSDictionary {
        return self.indexingBubbles
    }
    
    func getSectionArr() -> [[String]] {
        // Method indexes section,row -> index path
        var sectionDict = [[String]]()
        // Iterate through the sections and rows
        for column in 0...8 {
            sectionDict.append(Array(count:12-(column%2), repeatedValue:String()))
        }
        
        for key in indexingBubbles.keys {
            var currentColor = indexingBubbles[key]
            var sectionNo = key.section
            var rowNo = key.row
            sectionDict[sectionNo][rowNo] = currentColor!
        }
        return sectionDict
    }
    
    func loadBubbleGrid(loadDictionary: NSDictionary) {
        for indexToLoad in loadDictionary.allKeys {
            var currentIndexPath = indexToLoad as NSIndexPath
            var currentColor: AnyObject? = loadDictionary[currentIndexPath]
            if let selectedCell = self.collectionView?.cellForItemAtIndexPath(currentIndexPath) as? CircularCell {
                selectedCell.setImage(currentColor as String)
            }
        }
    }
    
    /*************************** Gesture methods *********************************/
    
    func handlePan(sender: UIPanGestureRecognizer) {
        var currentPoint = sender.locationInView(self.collectionView)
        if (sender.state == UIGestureRecognizerState.Ended) || sender.state == UIGestureRecognizerState.Changed  {
            if let indexPathOfSelected = self.collectionView?.indexPathForItemAtPoint(currentPoint){
                var selectedCell = self.collectionView?.cellForItemAtIndexPath(indexPathOfSelected) as CircularCell
                if selectedCell.getCurrentColor() != gameBubble.getSelection() {
                    selectedCell.setImage(gameBubble.getSelection())
                    indexingBubbles[indexPathOfSelected] = gameBubble.getSelection()
                }
            }
        }
        
    }
    
    func handleLongPress(sender: UILongPressGestureRecognizer) {
        var currentPoint = sender.locationInView(self.collectionView)
        if let indexPathOfSelected = self.collectionView?.indexPathForItemAtPoint(currentPoint){
            var selectedCell = self.collectionView?.cellForItemAtIndexPath(indexPathOfSelected) as CircularCell
            selectedCell.removeImage()
            indexingBubbles[indexPathOfSelected] = ""
        }
    }
    
    func handleTap(sender: UITapGestureRecognizer){
        var currentPoint = sender.locationInView(self.collectionView)
        if let indexPathOfSelected = self.collectionView?.indexPathForItemAtPoint(currentPoint){
            var selectedCell = self.collectionView?.cellForItemAtIndexPath(indexPathOfSelected) as CircularCell
            selectedCell.toggleImage(selectedCell.getCurrentColor())
            indexingBubbles[indexPathOfSelected] = selectedCell.getCurrentColor()
        }
    }
    
}
