//
//  CircularCell.swift
//  LevelDesigner
//
//  Created by Jingrong (: on 2/2/15.
//  Copyright (c) 2015 NUS CS3217. All rights reserved.
//

import UIKit

class CircularCell: UICollectionViewCell {
    
    private var currentColor = String()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = self.bounds.size.width/2
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 1
        currentColor = ""
        self.layer.backgroundColor = UIColor.clearColor().colorWithAlphaComponent(0.15).CGColor
    }
    
    // Setter function to set image for this cell
    func setImage(color: String) {
        var bubbleImage = UIImage()
        if color == "redBubble"{
            bubbleImage = UIImage(named: "bubble-red.png")!
            self.currentColor = color
        } else if color == "blueBubble"{
            bubbleImage = UIImage(named: "bubble-blue.png")!
            self.currentColor = color
        } else if color == "orangeBubble"{
            bubbleImage = UIImage(named: "bubble-orange.png")!
            self.currentColor = color
        } else if color == "greenBubble"{
            bubbleImage = UIImage(named: "bubble-green.png")!
            self.currentColor = color
        } else if color == "eraser" {
            self.removeImage()
            self.currentColor = ""
        } else if color == "indestructibleBubble"{
            bubbleImage = UIImage(named: "bubble-indestructible.png")!
            self.currentColor = color
        } else if color == "starBubble"{
            bubbleImage = UIImage(named: "bubble-star.png")!
            self.currentColor = color
        } else if color == "bombBubble"{
            bubbleImage = UIImage(named: "bubble-bomb.png")!
            self.currentColor = color
        } else if color == "lightningBubble"{
            bubbleImage = UIImage(named: "bubble-lightning.png")!
            self.currentColor = color
        } else {
            self.removeImage()
        }
        
        let bubbleHeight = self.bounds.size.height
        let bubbleWidth = self.bounds.size.width
        let bubble = UIImageView(image: bubbleImage)
        bubble.frame = CGRectMake(0, 0, bubbleWidth, bubbleHeight)
        self.backgroundView = bubble
    }
    
    // Getter function to get image for this cell
    func getCurrentColor() -> String {
        return self.currentColor
    }
    
    // Removes image from this cell
    func removeImage() {
        var bubbleImage = UIImage(CGImage: nil)
        let bubbleHeight = self.bounds.size.height
        let bubbleWidth = self.bounds.size.width
        let bubble = UIImageView(image: bubbleImage)
        bubble.frame = CGRectMake(0, 0, bubbleWidth, bubbleHeight)
        self.backgroundView = bubble
        self.currentColor = ""
    }
    
    // Cycles through the colors for this cell
    func toggleImage(color: String) {
        var bubbleImage = UIImage()
        
        // Regular bubbles
        
        if color == "redBubble"{
            bubbleImage = UIImage(named: "bubble-orange.png")!
            self.currentColor = "orangeBubble"
        } else if color == "blueBubble"{
            bubbleImage = UIImage(named: "bubble-green.png")!
            self.currentColor = "greenBubble"
        } else if color == "orangeBubble"{
            bubbleImage = UIImage(named: "bubble-blue.png")!
            self.currentColor = "blueBubble"
        } else if color == "greenBubble"{
            bubbleImage = UIImage(named: "bubble-red.png")!
            self.currentColor = "redBubble"
        }
        
        // Special bubbles
        
        if color == "indestructibleBubble"{
            bubbleImage = UIImage(named: "bubble-star.png")!
            self.currentColor = color
        } else if color == "starBubble"{
            bubbleImage = UIImage(named: "bubble-bomb.png")!
            self.currentColor = color
        } else if color == "bombBubble"{
            bubbleImage = UIImage(named: "bubble-lightning.png")!
            self.currentColor = color
        } else if color == "lightningBubble"{
            bubbleImage = UIImage(named: "bubble-indestructible.png")!
            self.currentColor = color
        }
        
        let bubbleHeight = self.bounds.size.height
        let bubbleWidth = self.bounds.size.width
        let bubble = UIImageView(image: bubbleImage)
        bubble.frame = CGRectMake(0, 0, bubbleWidth, bubbleHeight)
        self.backgroundView = bubble
    }
}
