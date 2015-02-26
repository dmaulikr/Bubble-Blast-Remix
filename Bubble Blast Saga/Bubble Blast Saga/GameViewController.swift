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

    
    // Loadout

    @IBOutlet weak var launchBubbleView: GameCircularCell!
    @IBOutlet weak var previewBubbleView: GameCircularCell!
    
    // default launch position
    private let launchPad = CGPoint(x: 334.0, y: 951.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        gameEngine = GameEngine()
        loadBackground()
        loadBubbleGrid()
        gameBubble = MovableGameBubble()
        currentSavedPath = "Level_XXX"
        allowGesture = true
        
        loadRandomBubbleIntoPreview()
        loadRandomBubbleToLaunch()

        // Gesture recognizers
        let panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(self, action: "launchBubblePan:")
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        self.view.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: "launchBubbleTap:")
        self.view.addGestureRecognizer(tapGesture)
        
        // Timer
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0/60 , target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        
        // Load design
        // Requires mini buffer for NSIndexPaths in collection view to be updated appropriately.
        delay(1.0/60){
            self.bubbleGridViewController.loadIntoGame(self.sectionArr)
            self.bubbleGridViewController.bubblesToDrop()
        }

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
                self.allowGesture = true
            }))
            presentViewController(resetPrompt, animated: true, completion: nil)
        }
        
    }
    
    /***************************** Pallette (PS4) **********************************/
    
    private func loadRandomBubbleIntoPreview() {
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
        
        if (allowGesture == true){
            gameEngine.launchBubble(launchBubbleView, direction: velocity)
            allowGesture = false
        }
    }
    
    func update() {
        if (gameEngine.gameState == true) {
            self.bubbleGridViewController.addBubble(gameEngine.updateBubbleAtCollectionView(), color: launchBubbleView.getImage())
            movePreviewIntoLaunch()
            allowGesture = true     
        }
        gameEngine.update()
    }
    
    private func movePreviewIntoLaunch() {
        // TODO in ps5 : Animate the shifting
        launchBubbleView.setImage(previewBubbleView.getImage())
        launchBubbleView.center = launchPad
        loadRandomBubbleIntoPreview()
        
        // Update the contents as well
        gameEngine.setGridContents(bubbleGridViewController.getGridContents())
    }
    
    private func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
