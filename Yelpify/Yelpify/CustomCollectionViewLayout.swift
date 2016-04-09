//
//  HomeCollectionViewLayout.swift
//  Yelpify
//
//  Created by Ryan Yue on 4/8/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit

class CustomCollectionViewLayout: UICollectionViewLayout {
    let CELL_WIDTH = 140.0
    let CELL_HEIGHT = 140.0
    
    var cellAttrsDictionary = Dictionary<NSIndexPath, UICollectionViewLayoutAttributes>()
    var contentSize = CGSize.zero
    
    override func collectionViewContentSize() -> CGSize {
        return self.contentSize
    }
    override func prepareLayout() {
        if collectionView?.numberOfSections() > 0
        {
            for section in 0...collectionView!.numberOfSections()-1
            {
                if collectionView?.numberOfItemsInSection(section) > 0
                {
                    for item in 0...collectionView!.numberOfItemsInSection(section)-1
                    {
                        let cellIndex = NSIndexPath(forItem: item, inSection: section)
                        let xpos = Double(item) * CELL_WIDTH
                        let ypos = Double(section) * CELL_HEIGHT
                        
                        let cellAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: cellIndex)
                        cellAttributes.frame = CGRect(x: xpos, y: ypos, width: CELL_WIDTH, height: CELL_HEIGHT)
                        
                        if section == 0 && item == 0
                        {
                            cellAttributes.zIndex = 4
                        }
                        else if section == 0
                        {
                            cellAttributes.zIndex = 3
                        }
                        else if item == 0
                        {
                            cellAttributes.zIndex = 2
                        }
                        else
                        {
                            cellAttributes.zIndex = 1
                        }
                        cellAttrsDictionary[cellIndex] = cellAttributes
                    }
                }
            }
        }
        let contentWidth = Double(collectionView!.numberOfItemsInSection(0)) * CELL_WIDTH
        let contentHeight = Double(collectionView!.numberOfSections()) * CELL_HEIGHT
        self.contentSize = CGSize(width: contentWidth, height: contentHeight)
    }
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributesInRect = [UICollectionViewLayoutAttributes]()
        
        // Check each element to see if it should be returned.
        for cellAttributes in Array(cellAttrsDictionary.values) {
            if CGRectIntersectsRect(rect, cellAttributes.frame) {
                attributesInRect.append(cellAttributes)
            }
        }
        
        // Return list of elements.
        return attributesInRect
    }
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return cellAttrsDictionary[indexPath]!
    }
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return false
    }
    
}
