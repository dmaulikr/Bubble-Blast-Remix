//
//  GameViewController.swift
//  Bubble Blast Saga
//
//  Created by Jingrong (: on 10/2/15.
//  Copyright (c) 2015 Lim Jing Rong. All rights reserved.
//

import UIKit
import AVFoundation

class GameViewController: UIViewController {
    
    // Importing stuff from level designer to play
    var sectionArr = [[String]]()
    var bubbleGridIndexes = [[NSIndexPath]]()
    var bubblesAmount = Int()
    var storedBubblesAmount = Int()
    
    // Sound effects
    var launchPlayer: AVAudioPlayer!
    var endGamePlayer: AVAudioPlayer!
    var winGamePlayer: AVAudioPlayer!
    
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
    private var cannonImages = [UIImage]()
    private var cannonShaftImageView = UIImageView()
    private var cannonBaseImageView = UIImageView()
    
    // Default launch & preview position from view controller
    private var launchPad = CGPoint()
    private var previewPad = CGPoint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        launchPad = launchBubbleView.frame.origin
        previewPad = previewBubbleView.frame.origin
        
        gameEngine = GameEngine()
        loadBackground()
        loadBubbleGrid()
        gameBubble = MovableGameBubble()
        currentSavedPath = "Level_XXX"
        
        loadRandomBubbleIntoPreview()
        loadRandomBubbleToLaunch()
        loadCannon()
        loadSoundEffects()
        
        storedBubblesAmount = bubblesAmount
        bubblesLeft.text = String(bubblesAmount)
        
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
            self.delay(0.1){
                self.bubbleGridViewController.bubblesToDrop()
                self.allowGesture = true
            }
            
        }
        
    }
    
    // Function to load sound effects
    private func loadSoundEffects() {
        // Sound effect for launch
        let launchPath = NSBundle.mainBundle().pathForResource("launchBubble", ofType: "wav")!
        let launchURL = NSURL(fileURLWithPath: launchPath)
        launchPlayer = AVAudioPlayer(contentsOfURL: launchURL, error: nil)
        launchPlayer.prepareToPlay()
        
        // Sound effect for winning the level
        let winPath = NSBundle.mainBundle().pathForResource("winGame", ofType: "wav")!
        let winURL = NSURL(fileURLWithPath: winPath)
        winGamePlayer = AVAudioPlayer(contentsOfURL: winURL, error: nil)
        winGamePlayer.prepareToPlay()
        
        // Sound effect for losing the level
        let losePath = NSBundle.mainBundle().pathForResource("gameOver", ofType: "wav")!
        let loseURL = NSURL(fileURLWithPath: losePath)
        endGamePlayer = AVAudioPlayer(contentsOfURL: loseURL, error: nil)
        endGamePlayer.prepareToPlay()
    }
    
    // Function to load Cannon
    private func loadCannon() {
        
        // Scale by default size
        let scalingFactor = 0.18 as CGFloat
        let horizontalCount = 6
        let verticalCount = 2
        // As per image input of 2400 by 1600 and 6x2 images
        let cannonImageHeight = (1600.0 / CGFloat(verticalCount)) as CGFloat
        let cannonImageWidth = (2400.0 / CGFloat(horizontalCount)) as CGFloat
        var cannonImageToSplit = UIImage(named: "cannon")?.CGImage
        
        // Loading all sprites of cannons into array
        for i in 0...verticalCount - 1 {
            for j in 0...horizontalCount - 1 {
                var yValue = CGFloat(i) * cannonImageHeight
                var xValue = CGFloat(j) * cannonImageWidth
                var partOfImageAsCG = CGImageCreateWithImageInRect(cannonImageToSplit, CGRectMake(xValue, yValue, cannonImageWidth, cannonImageHeight)) as CGImageRef
                cannonImages.append(UIImage(CGImage: partOfImageAsCG)!)
            }
        }
        
        var cannonShaftImage = cannonImages[0]
        cannonShaftImageView = UIImageView(image: cannonShaftImage)
        
        // As per image input of 400 by 200
        let baseWidth = 400.0 as CGFloat
        let baseHeight = 200.0 as CGFloat
        let cannonBaseImage = UIImage(named: "cannon-base.png")
        cannonBaseImageView = UIImageView(image: cannonBaseImage)
        cannonShaftImageView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.9)
        
        cannonShaftImageView.frame = CGRectMake(launchBubbleView.center.x - (cannonImageWidth * scalingFactor) / 2.0 , launchBubbleView.center.y - (cannonImageHeight * scalingFactor) - ((baseHeight/2.0) * scalingFactor), cannonImageWidth * scalingFactor, cannonImageHeight * scalingFactor)
        cannonShaftImageView.alpha = 0.8
        
        self.view.addSubview(cannonShaftImageView)
        
        var cannonBaseScalingFactor = scalingFactor * 1.8
        cannonBaseImageView.frame = CGRectMake(launchBubbleView.center.x - (baseWidth * cannonBaseScalingFactor ) / 2.0, launchBubbleView.center.y - (baseHeight * cannonBaseScalingFactor), baseWidth * cannonBaseScalingFactor, baseHeight * cannonBaseScalingFactor)
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
                self.resetAfterGameEnd()
                self.delay(0.1){
                    self.allowGesture = true
                }
            }))
            presentViewController(resetPrompt, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func previewBubblePressed(sender: AnyObject) {
        if bubblesAmount > 0 {
            swapBubble()
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "gameToMenu") {
            // Back to main menu
            var menuController = segue.destinationViewController as MenuViewController;
            menuController.isPlaying = true
        }
    }
    
    // Function to swap positions of preview and launch bubble
    private func swapBubble() {
        if (self.allowGesture == true) {
            self.allowGesture = false
            
            var previewToLaunch = GameCircularCell(frame: previewBubbleView.frame)
            previewToLaunch.setImage(previewBubbleView.getImage())
            
            var launchToPreview = GameCircularCell(frame: launchBubbleView.frame)
            launchToPreview.setImage(launchBubbleView.getImage())
            
            // Layer it on top
            self.gameArea.insertSubview(previewToLaunch as UIView, aboveSubview: self.view)
            self.gameArea.insertSubview(launchToPreview as UIView, aboveSubview: self.view)
            previewBubbleView.alpha = 0
            launchBubbleView.alpha = 0
            
            UIView.animateWithDuration(NSTimeInterval(0.3), animations: {
                previewToLaunch.frame = CGRectMake( self.launchPad.x , self.launchPad.y , previewToLaunch.frame.width, previewToLaunch.frame.height)
                launchToPreview.frame = CGRectMake( self.previewPad.x , self.previewPad.y , launchToPreview.frame.width, launchToPreview.frame.height)
                }, completion: { finished in
                    self.launchBubbleView.setImage(previewToLaunch.getImage())
                    self.previewBubbleView.setImage(launchToPreview.getImage())
                    self.previewBubbleView.alpha = 1
                    self.launchBubbleView.alpha = 1
                    
                    previewToLaunch.removeFromSuperview()
                    launchToPreview.removeFromSuperview()
                    self.allowGesture = true
            })
        }
        
    }
    /***************************** Game Engine (PS4) *************************************/
    
    func launchBubblePan(sender: UIPanGestureRecognizer) {
        var panPoint = sender.locationInView(self.view)
        
        
        if (allowGesture == true && (sender.state == UIGestureRecognizerState.Changed || sender.state == UIGestureRecognizerState.Began)) {
            var displacement = CGPoint(x: panPoint.x - launchBubbleView.center.x, y: panPoint.y - launchBubbleView.center.y)
            var angleToChange = atan(CGFloat((abs(displacement.x)) / (abs(displacement.y)) )) / 2.0
            if ( displacement.x < 0) {
                angleToChange *= -1.0
            }
            
            cannonShaftImageView.transform = CGAffineTransformMakeRotation(angleToChange);
            cannonShaftImageView.transform = CGAffineTransformRotate(cannonShaftImageView.transform, angleToChange);
        }
        
        if (allowGesture == true && (sender.state == UIGestureRecognizerState.Ended)){
            var displacement = CGPoint(x: panPoint.x - launchBubbleView.center.x, y: panPoint.y - launchBubbleView.center.y)
            var velocity = CGPoint()
            
            var angle = atan(CGFloat((displacement.y) / (displacement.x) ))
            let constantVelocity = CGFloat(15.0)
            velocity.x = constantVelocity * cos(angle) * (displacement.x / abs(displacement.x))
            velocity.y = -1.0 *  abs(constantVelocity * sin(angle))
            
            // Threshold value to prevent very 'slow' progression upwards
            if velocity.y > -1.5 {
                velocity.y = -1.5
            }
            
            // Animation and sound effects
            launchPlayer.play()
            gameEngine.launchBubble(launchBubbleView, direction: velocity)
            
            
            // Cannon launcher effect
            cannonShaftImageView.animationImages = cannonImages
            cannonShaftImageView.animationDuration = 0.5
            cannonShaftImageView.startAnimating()
            delay(0.5) {
                self.cannonShaftImageView.stopAnimating()
            }
            
            allowGesture = false
        }
    }
    
    func launchBubbleTap(sender: UITapGestureRecognizer) {
        if (allowGesture == true){
            var tapPoint = sender.locationInView(self.view)
            var displacement = CGPoint(x: tapPoint.x - launchBubbleView.center.x, y: tapPoint.y - launchBubbleView.center.y)
            var velocity = CGPoint()
            
            var angle = atan(CGFloat((abs(displacement.y)) / (abs(displacement.x)) ))
            let constantVelocity = CGFloat(15.0)
            velocity.x = constantVelocity * cos(angle) * (displacement.x / abs(displacement.x))
            velocity.y = -1.0 *  abs(constantVelocity * sin(angle))
            
            // Threshold value to prevent very 'slow' progression upwards
            if velocity.y > -1.5 {
                velocity.y = -1.5
            }
            
            launchPlayer.play()
            gameEngine.launchBubble(launchBubbleView, direction: velocity)
            
            var angleToChange = atan(CGFloat((abs(displacement.x)) / (abs(displacement.y)) )) / 2.0
            if ( displacement.x < 0) {
                angleToChange *= -1.0
            }
            
            cannonShaftImageView.transform = CGAffineTransformMakeRotation(angleToChange);
            cannonShaftImageView.transform = CGAffineTransformRotate(cannonShaftImageView.transform, angleToChange);
            
            // Cannon launcher effect
            cannonShaftImageView.animationImages = cannonImages
            cannonShaftImageView.animationDuration = 0.5
            cannonShaftImageView.startAnimating()
            delay(0.5) {
                self.cannonShaftImageView.stopAnimating()
            }
            
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
            self.scoreLabel.text = String(self.bubbleGridViewController.score)
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
    
    /******************************* Game state conditions *************************************/
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
        winGamePlayer.play()
        self.bubbleGridViewController.score += ( self.bubblesAmount * 200 )
        let loadPrompt = UIAlertController(title: "You beat this level!", message: "Your score is: " + String(self.bubbleGridViewController.score) + "\n" + "Play this level again?", preferredStyle: UIAlertControllerStyle.Alert)
        loadPrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            //Segue for endgame screen if have time
            self.resetAfterGameEnd()
        }))
        presentViewController(loadPrompt, animated: true, completion: nil)
        
    }
    
    // End game
    private func endGame() {
        endGamePlayer.play()
        let loadPrompt = UIAlertController(title: "Game over!", message: "Your score is: " + String(self.bubbleGridViewController.score) + "\n" + "Try again?", preferredStyle: UIAlertControllerStyle.Alert)
        loadPrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            //Segue for endgame if have time
            self.resetAfterGameEnd()
            
        }))
        presentViewController(loadPrompt, animated: true, completion: nil)
        
    }
    
    private func resetAfterGameEnd() {
        self.bubbleGridViewController.score = 0
        self.bubbleGridViewController.reset()
        self.bubbleGridViewController.loadIntoGame(self.sectionArr)
        self.bubbleGridViewController.bubblesToDrop()
        self.allowGesture = true
        self.previewBubbleView.alpha = 1
        self.bubblesAmount = self.storedBubblesAmount
        self.bubblesLeft.text = String(self.bubblesAmount)
        self.scoreLabel.text = String(self.bubbleGridViewController.score)
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


