//
//  ViewController.swift
//  LevelDesigner
//
//  Created by YangShun on 26/1/15.
//  Copyright (c) 2015 NUS CS3217. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Game Bubble Model
    private var gameBubble: GameBubble!
    private var bubbleGrid: BubbleGridViewController!
    
    private var fileList = [String]()
    private var directoryPath = String()
    private var currentSavedPath = String()
    
    @IBOutlet weak var gameArea: UIView!
    
    // Button views to show selection
    @IBOutlet weak var eraserImage: UIButton!
    @IBOutlet weak var orangeImage: UIButton!
    @IBOutlet weak var blueImage: UIButton!
    @IBOutlet weak var redImage: UIButton!
    @IBOutlet weak var greenImage: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadBackground()
        loadBubbleGrid()
        gameBubble = GameBubble()
        currentSavedPath = "Level_XXX"
        
        var urls = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        directoryPath = (urls[0] as NSURL).path! + "/"
        
        fileList = NSFileManager.defaultManager().contentsOfDirectoryAtPath(directoryPath, error: nil) as [String]
        
    }
    
    // Function to load background view
    private func loadBackground() {
        let backgroundImage = UIImage(named: "background.png")
        let background = UIImageView(image: backgroundImage)
        let gameViewHeight = gameArea.frame.size.height
        let gameViewWidth = gameArea.frame.size.width
        background.frame = CGRectMake(0, 0, gameViewWidth, gameViewHeight)
        self.gameArea.addSubview(background)
    }
    
    // Function to load grid layout using collection view
    private func loadBubbleGrid() {
        let gridWidth = gameArea.frame.size.width
        // To compact the 9 columns
        let gridHeight = CGFloat(595)
        let frame = CGRect(origin: CGPoint(x:0, y:0), size: CGSize(width: gridWidth, height: gridHeight))
        bubbleGrid = BubbleGridViewController(viewFrame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        self.addChildViewController(bubbleGrid)
        self.gameArea.addSubview(bubbleGrid.collectionView!)
        self.gameArea.bringSubviewToFront(bubbleGrid.collectionView!)
    }
    
    /*********************** Palette button pressing *****************************/
    
    @IBAction func eraserPressed(sender: AnyObject) {
        
        if (eraserImage.alpha == 0.5) {
            eraserImage.alpha = 1
            blueImage.alpha = 0.5
            greenImage.alpha = 0.5
            redImage.alpha = 0.5
            orangeImage.alpha = 0.5
        }
        gameBubble.setSelection("eraser")
        bubbleGrid.setGameBubble(gameBubble)
    }
    
    @IBAction func blueBubblePressed(sender: AnyObject) {
        
        if (blueImage.alpha == 0.5) {
            eraserImage.alpha = 0.5
            blueImage.alpha = 1
            greenImage.alpha = 0.5
            redImage.alpha = 0.5
            orangeImage.alpha = 0.5
        }
        gameBubble.setSelection("blueBubble")
        bubbleGrid.setGameBubble(gameBubble)
    }
    
    @IBAction func greenBubblePressed(sender: AnyObject) {
        
        if (greenImage.alpha == 0.5) {
            eraserImage.alpha = 0.5
            blueImage.alpha = 0.5
            greenImage.alpha = 1
            redImage.alpha = 0.5
            orangeImage.alpha = 0.5
        }
        gameBubble.setSelection("greenBubble")
        bubbleGrid.setGameBubble(gameBubble)
    }
    
    @IBAction func redBubblePressed(sender: AnyObject) {
        
        if (redImage.alpha == 0.5) {
            eraserImage.alpha = 0.5
            blueImage.alpha = 0.5
            greenImage.alpha = 0.5
            redImage.alpha = 1
            orangeImage.alpha = 0.5
        }
        gameBubble.setSelection("redBubble")
        bubbleGrid.setGameBubble(gameBubble)
    }
    
    @IBAction func orangeBubblePressed(sender: AnyObject) {
        
        if (orangeImage.alpha == 0.5) {
            eraserImage.alpha = 0.5
            blueImage.alpha = 0.5
            greenImage.alpha = 0.5
            redImage.alpha = 0.5
            orangeImage.alpha = 1.0
        }
        gameBubble.setSelection("orangeBubble")
        bubbleGrid.setGameBubble(gameBubble)
    }
    

    /*********************** Menu button pressing *****************************/
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "designToGame") {
            // Pass current bubble grid information to game screen
            var gameController = segue.destinationViewController as GameViewController;
            gameController.sectionArr = self.bubbleGrid.getSectionArr()
            
        }
    }
    
    
    @IBAction func saveButton(sender: AnyObject) {
        var inputTextField: UITextField?
        var saveFileName = currentSavedPath  // place holder
        var allFiles = ""
        var fileCount = 1
        for i in fileList {
            allFiles = allFiles + String(fileCount) + "." + i + "\n"
            fileCount += 1
        }
        
        let savePrompt = UIAlertController(title: "Enter file name to save grid to", message: "Previous loads contains: " + "\n" +  allFiles, preferredStyle: UIAlertControllerStyle.Alert)
        savePrompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        savePrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            saveFileName = inputTextField?.text as String!
            NSFileManager.defaultManager().removeItemAtPath((self.directoryPath + saveFileName), error: nil)
            var dataToSave = self.bubbleGrid.getSectionArr() as NSArray
            if dataToSave.writeToFile((self.directoryPath + saveFileName), atomically: true) == true {
                if (!contains(self.fileList,saveFileName)) {
                    self.fileList.append(saveFileName)
                }
                
                self.currentSavedPath = saveFileName
                self.resetGrid()
                self.delay(0) {
                    self.loadGrid(saveFileName)
                }
                
                // Prompts to user that save is successful
                var alert = UIAlertController(title: "Newly created grid: " + self.currentSavedPath +  "\n" + "has been saved", message: "Create a new layout or continue from previously saved grids", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Got it", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            self.bubbleGrid.collectionView?.reloadData()
        }))
        savePrompt.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = self.currentSavedPath
            inputTextField = textField
        })
        presentViewController(savePrompt, animated: true, completion: nil)
        
    }
    
    @IBAction func loadButton(sender: AnyObject) {
        var inputTextField: UITextField?
        var loadFileName = currentSavedPath
        var allFiles = ""
        var fileCount = 1
        for i in fileList {
            allFiles = allFiles + String(fileCount) + "." + i + "\n"
            fileCount += 1
        }
        let loadPrompt = UIAlertController(title: "Load previously-saved level", message: "Previous loads contains: " + "\n" +  allFiles, preferredStyle: UIAlertControllerStyle.Alert)
        loadPrompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        loadPrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            loadFileName = inputTextField?.text as String!
            if (contains(self.fileList, loadFileName)) {
                self.loadGrid(loadFileName)
                self.currentSavedPath = loadFileName
            } else {
                var alert = UIAlertController(title: "File does not exist!", message: "Please select a previously loaded file", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Got it", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
            
        }))
        loadPrompt.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = self.currentSavedPath
            inputTextField = textField
        })
        presentViewController(loadPrompt, animated: true, completion: nil)
    }
    
    private func loadGrid(loadFile : String) {
        
        var bubbleGridIndexes = [NSIndexPath: String]()
        resetGrid()
        if let toLoad = NSArray(contentsOfFile: directoryPath + loadFile){
            var currentIndexPath = NSIndexPath()
            for eachCol in 0...8 {
                for eachRow in 0...(11-(eachCol%2)) {
                    var currentColor = toLoad[eachCol][eachRow] as? String
                    if currentColor != "" {
                        currentIndexPath = NSIndexPath(forRow: eachRow, inSection: eachCol)
                        bubbleGridIndexes[currentIndexPath] = currentColor
                    }
                }
            }
            bubbleGrid.loadBubbleGrid(bubbleGridIndexes)
            bubbleGrid.updateDictionary(bubbleGridIndexes)
        }
    }
    
    @IBAction func resetButton(sender: AnyObject) {
        var alert = UIAlertController(title: "Grid is resetted!", message: "Create a new layout or load from previous", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Got it", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        resetGrid()
    }
    
    private func resetGrid() {
        var allCells = bubbleGrid.collectionView?.visibleCells() as [CircularCell]
        for cell in allCells{
            cell.removeImage()
        }
        bubbleGrid.wipeColorIndexing()
    }
    
    @IBAction func buttonPressed(sender: AnyObject) {
        let button = sender as UIButton
        var newColor : UIColor
        if button.titleColorForState(UIControlState.Normal) == UIColor.blueColor() {
            newColor = UIColor.lightGrayColor()
        } else {
            newColor = UIColor.blueColor()
        }
        button.setTitleColor(newColor, forState: UIControlState.Normal)
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

