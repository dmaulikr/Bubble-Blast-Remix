//
//  GameViewController.swift
//  Bubble Blast Saga
//
//  Created by Jingrong (: on 10/2/15.
//  Copyright (c) 2015 Lim Jing Rong. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    // Importing stuff from level designer to play
    var sectionArr = [[String]]()
    var bubbleGridIndexes = [[NSIndexPath]]()
    var bubblesAmount = Int()
    var storedBubblesAmount = Int()
    
    // Timer 
    private var timer: NSTimer!
    
    // Game Bubble Model
    private var gameBubble: MovableGameBubble!
    var bubbleGridViewController: GameGridViewController!
    private var gameEngine: GameEngine!
    
    private var allowGesture: Bool!
    private var fileList = [String]()
    private var directoryPath = String()
    private var currentSavedPath = String()
    @IBOutlet weak var gameArea: UIView!
    @IBOutlet weak var bubblesLeft: UILabel!
    
    // Loadout

    @IBOutlet weak var launchBubbleView: GameCircularCell!
    @IBOutlet weak var previewBubbleView: GameCircularCell!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var cannonBase: UIView!
    @IBOutlet weak var cannonShaft: UIView!
    // Default launch position from view controller
    private let launchPad = CGPoint(x: 334.0, y: 951.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        gameEngine = GameEngine()
        loadBackground()
        loadBubbleGrid()
        gameBubble = MovableGameBubble()
        currentSavedPath = "Level_XXX"
        
        loadRandomBubbleIntoPreview()
        loadRandomBubbleToLaunch()
        loadCannonBase()
        
        storedBubblesAmount = bubblesAmount
        bubblesLeft.text = String(bubblesAmount)

        // Gesture recognizers
        /*
        let panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(self, action: "launchBubblePan:")
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        self.view.addGestureRecognizer(panGesture)
        */
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: "launchBubbleTap:")
        self.view.addGestureRecognizer(tapGesture)
        
        // Timer
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0/60 , target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        
        // Load design
        // Requires mini buffer for NSIndexPaths in collection view to be updated appropriately.
        delay(1.0/60){
            self.bubbleGridViewController.loadIntoGame(self.sectionArr)
            self.delay(0.1){
                self.bubbleGridViewController.bubblesToDrop()
                self.allowGesture = true
            }
            
        }

    }
    // Function to load Cannon
    private func loadCannonBase() {
        
        let cannonShaftImage = UIImage(named: "cannon-single.png")
        let cannonShaftImageView = UIImageView(image: cannonShaftImage)
        let cannonShaftViewHeight = cannonShaft.frame.size.height
        let cannonShaftViewWidth = cannonShaft.frame.size.width
        let cannonBaseImage = UIImage(named: "cannon-base.png")
        let cannonBaseImageView = UIImageView(image: cannonBaseImage)
        let cannonViewHeight = cannonBase.frame.size.height
        let cannonViewWidth = cannonBase.frame.size.width
        
        cannonShaftImageView.frame = CGRectMake(launchPad.x - 15.0, launchPad.y - 115.0 - cannonViewHeight, cannonShaftViewWidth, cannonShaftViewHeight)
        cannonShaftImageView.alpha = 0.8
        //self.view.addSubview(cannonShaftImageView)
        
        
        cannonBaseImageView.frame = CGRectMake(launchPad.x, launchPad.y - 10.0, cannonViewWidth, cannonViewHeight)
        cannonBaseImageView.alpha = 0.8
        self.view.addSubview(cannonBaseImageView)

    }
    
    // Function to load background view
    private func loadBackground() {
        let backgroundImage = UIImage(named: "background.png")
        let background = UIImageView(image: backgroundImage)
        let gameViewHeight = gameArea.frame.size.height
        let gameViewWidth = gameArea.frame.size.width
        background.frame = CGRectMake(0, 0, gameViewWidth, gameViewHeight)
        self.gameArea.addSubview(background)
        gameEngine.setiPadView(self.view)
    }
    
    // Function to load grid layout using collection view
    private func loadBubbleGrid() {
        let gridWidth = gameArea.frame.size.width
        let gridHeight = gameArea.frame.size.height
        let frame = CGRect(origin: CGPoint(x:0, y:0), size: CGSize(width: gridWidth, height: gridHeight))
        bubbleGridViewController = GameGridViewController(viewFrame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        self.addChildViewController(bubbleGridViewController)
        self.gameArea.addSubview(bubbleGridViewController.collectionView!)
        self.gameArea.bringSubviewToFront(bubbleGridViewController.collectionView!)
        
    }
    
    // Replay game level
    @IBAction func resetGameLevel(sender: AnyObject) {
        if (allowGesture == true) {
            allowGesture = false
            let resetPrompt = UIAlertController(title: "Reset level", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.Alert)
            resetPrompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
            resetPrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.bubbleGridViewController.reset()
                self.bubbleGridViewController.loadIntoGame(self.sectionArr)
                self.bubbleGridViewController.bubblesToDrop()
                self.previewBubbleView.alpha = 1
                self.delay(0.1){
                    self.allowGesture = true
                }
            }))
            presentViewController(resetPrompt, animated: true, completion: nil)
        }
        
    }
    
    /***************************** Pallette (PS4) **********************************/
    
    private func loadRandomBubbleIntoPreview() {
        // Update bubbles left
        bubblesAmount -= 1
        if (bubblesAmount >= 0) {
            bubblesLeft.text = String(bubblesAmount)
        }
        var nextBubble = gameBubble.getRandom()
        previewBubbleView.setImage(nextBubble.getSelection())
    }
    
    private func loadRandomBubbleToLaunch() {
        var nextBubble = gameBubble.getRandom()
        launchBubbleView.setImage(nextBubble.getSelection())
        gameEngine.setGridContents(bubbleGridViewController.getGridContents())
    }
    /************************** Game Engine (PS4) *************************************/
    
    // Panning disabled temporarily
    /*
    func launchBubblePan(sender: UIPanGestureRecognizer) {
        var velocity = CGPoint()
        velocity = sender.translationInView(self.view)
        
        //gameEngine.launchBubble(launchBubbleView, direction: velocity)
    }
    */
    
    func launchBubbleTap(sender: UITapGestureRecognizer) {
        if (allowGesture == true){
            var tapPoint = sender.locationInView(self.view)
            var displacement = CGPoint(x: tapPoint.x - launchBubbleView.center.x, y: tapPoint.y - launchBubbleView.center.y)
            var velocity = CGPoint()
            
            var angle = atan(CGFloat((displacement.y) / (displacement.x) ))
            let constantVelocity = CGFloat(15.0)
            velocity.x = constantVelocity * cos(angle) * (displacement.x / abs(displacement.x))
            velocity.y = -1.0 *  abs(constantVelocity * sin(angle))
            
            // Threshold value to prevent very 'slow' progression upwards
            if velocity.y > -1.5 {
                velocity.y = -1.5
            }
            gameEngine.launchBubble(launchBubbleView, direction: velocity)
            
            
            allowGesture = false
        }
    }
    
    func update() {
        if (gameEngine.gameState == true && self.bubbleGridViewController.isAnimating == false) {
            self.bubbleGridViewController.addBubble(gameEngine.updateBubbleAtCollectionView(), color: launchBubbleView.getImage())
            if (checkWin() == true) {
                winGame()
            }
            movePreviewIntoLaunch()
        }
        gameEngine.update()
        if (self.bubbleGridViewController.gameDidEnd == true){
            self.endGame()
            self.bubbleGridViewController.gameDidEnd = false
        }
    }
    
    private func movePreviewIntoLaunch() {
        if bubblesAmount == 0 {
            self.endGame()
        }
        
        launchBubbleView.alpha = 0
        // Preview bubble to move
        var bubbleToMove = GameCircularCell(frame: previewBubbleView.frame)
        bubbleToMove.setImage(previewBubbleView.getImage())
        bubbleToMove.alpha = previewBubbleView.alpha
        
        // Layer it on top
        self.gameArea.insertSubview(bubbleToMove as UIView, aboveSubview: self.view)
        previewBubbleView.alpha = 0
        

        UIView.animateWithDuration(NSTimeInterval(1.0), animations: {
            bubbleToMove.frame = CGRectMake( self.launchPad.x , self.launchPad.y , bubbleToMove.frame.width, bubbleToMove.frame.height)
            }, completion: { finished in
                bubbleToMove.removeFromSuperview()
                self.launchBubbleView.setImage(self.previewBubbleView.getImage())
                self.loadRandomBubbleIntoPreview()
                // Update the contents as well
                self.gameEngine.setGridContents(self.bubbleGridViewController.getGridContents())
                self.allowGesture = true
                if (self.bubblesAmount <= 0){
                    self.previewBubbleView.alpha = 0
                } else {
                    self.previewBubbleView.alpha = 1
                }
                self.launchBubbleView.alpha = 1
                
        })
    }
    
    // Win game
    private func checkWin() -> Bool {
        let gridBubbles = self.bubbleGridViewController.getGridContents()
        
        // Check if it is empty
        let maxColumn = 18
        let maxRow = 12
        for column in 0...maxColumn-1 {
            for row in 0...(maxRow - (column%2)) {
                if gridBubbles.arrayOfBubbles[row][column].getImage() != "" {
                    return false
                }
            }
        }
        return true
    }
    
    private func winGame() {
        self.bubbleGridViewController.score += ( self.bubblesAmount * 200 )
        let loadPrompt = UIAlertController(title: "You beat this level!", message: "Your score is: " + String(self.bubbleGridViewController.score) + "\n" + "Play this level again?", preferredStyle: UIAlertControllerStyle.Alert)
        loadPrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            //Segue for endgame screen if have time
            
            self.bubbleGridViewController.score = 0
            self.bubbleGridViewController.reset()
            self.bubbleGridViewController.loadIntoGame(self.sectionArr)
            self.bubbleGridViewController.bubblesToDrop()
            self.allowGesture = true
            self.previewBubbleView.alpha = 1
            self.bubblesAmount = self.storedBubblesAmount
            self.bubblesLeft.text = String(self.bubblesAmount)
        }))
        presentViewController(loadPrompt, animated: true, completion: nil)
        
    }
    
    // End game
    private func endGame() {
        let loadPrompt = UIAlertController(title: "Game over!", message: "Your score is: " + String(self.bubbleGridViewController.score) + "\n" + "Try again?", preferredStyle: UIAlertControllerStyle.Alert)
        loadPrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            //Segue for endgame if have time

            self.bubbleGridViewController.score = 0
            self.bubbleGridViewController.reset()
            self.bubbleGridViewController.loadIntoGame(self.sectionArr)
            self.bubbleGridViewController.bubblesToDrop()
            self.allowGesture = true
            self.previewBubbleView.alpha = 1
            self.bubblesAmount = self.storedBubblesAmount
            self.bubblesLeft.text = String(self.bubblesAmount)
        }))
        presentViewController(loadPrompt, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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


