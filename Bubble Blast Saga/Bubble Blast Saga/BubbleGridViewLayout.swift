//
//  BubbleGridViewFlowLayout.swift
//  LevelDesigner
//
//  Created by Jingrong (: on 3/2/15.
//  Copyright (c) 2015 NUS CS3217. All rights reserved.
//

// Heavily adapted from Zi Xian

import UIKit

class BubbleGridViewLayout: UICollectionViewLayout {
    private let shiftFactor = sqrt(3)/2.0
    private var layoutArr: [[UICollectionViewLayoutAttributes]]!
    private var width: Double!
    private var height: Double!
    private var itemSize: Double = 0
    
    override init() {
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareLayout() {
        let collectionView = self.collectionView!
        let numRows = collectionView.numberOfSections()
        layoutArr = [[UICollectionViewLayoutAttributes]](count: numRows, repeatedValue: [UICollectionViewLayoutAttributes]())
        
        // Coordinates
        var x: Double = 0
        var y: Double = 0
        width = 0
        for row in 0..<numRows {
            x = (row%2) == 0 ? 0:itemSize/2
            var numCells = collectionView.numberOfItemsInSection(row)
            for var column = 0; column < numCells; column++ {
                var cellAttr = UICollectionViewLayoutAttributes(forCellWithIndexPath: NSIndexPath(indexes: [row, column], length: 2))
                cellAttr.frame = CGRectMake(CGFloat(x), CGFloat(y), CGFloat(itemSize), CGFloat(itemSize))
                layoutArr[row].append(cellAttr)
                x += itemSize
            }
            width = (width == 0 ? x:width)
            y += shiftFactor * itemSize
        }
        height = y
    }
    
    override func collectionViewContentSize() -> CGSize {
        return self.collectionView!.bounds.size
    }
    
    func setItemSize (size: Double){
        self.itemSize = size
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        let row = indexPath.section
        let column = indexPath.row
        return layoutArr[row][column]
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        var array = [UICollectionViewLayoutAttributes]()
        let numRows = layoutArr.count
        let rectOrigin = rect.origin
        for row in 0..<numRows {
            for i in layoutArr[row] {
                var origin = i.frame.origin
                if origin.x >= rectOrigin.x  && origin.x <= rectOrigin.x + rect.width && origin.y >= rectOrigin.y && origin.y <= rectOrigin.y+rect.height {
                    array.append(i)
                }
            }
        }
        return array
    }
}
