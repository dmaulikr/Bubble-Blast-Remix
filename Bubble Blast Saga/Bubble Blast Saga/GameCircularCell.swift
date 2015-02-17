//
//  GameCircularCell.swift
//  Bubble Blast Saga
//
//  Created by Jingrong (: on 10/2/15.
//  Copyright (c) 2015 Lim Jing Rong. All rights reserved.
//

import UIKit

class GameCircularCell: UICollectionViewCell {
    private var currentColor = String()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = self.bounds.size.width/2
        currentColor = ""


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
        } else {
            self.removeImage()
        }
        
        let bubbleHeight = self.bounds.size.height
        let bubbleWidth = self.bounds.size.width
        let bubble = UIImageView(image: bubbleImage)
        bubble.frame = CGRectMake(0, 0, bubbleWidth, bubbleHeight)
        self.backgroundView = bubble
    }
    
    func getImage() -> String {
        return self.currentColor
    }
    
    // Removes image from this cell
    func removeImage() {
        self.currentColor = ""
    }
    
}
