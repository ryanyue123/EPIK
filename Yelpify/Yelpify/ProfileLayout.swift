//
//  ProfileLayout.swift
//  Yelpify
//
//  Created by Jonathan Lam on 5/16/16.
//  Copyright © 2016 Yelpify. All rights reserved.

import UIKit

class ProfileLayout: UICollectionViewFlowLayout {
    
    override init()
    {
        super.init()
        setupLayout()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElementsInRect(rect)! as [UICollectionViewLayoutAttributes]
        let offset = collectionView!.contentOffset
        if (offset.y < 0) {
            let deltaY = fabs(offset.y)
            for attributes in layoutAttributes {
                if let elementKind = attributes.representedElementKind {
                    if elementKind == UICollectionElementKindSectionHeader {
                        var frame = attributes.frame
                        frame.size.height = max(0, headerReferenceSize.height + deltaY)
                        frame.origin.y = CGRectGetMinY(frame) - deltaY
                        attributes.frame = frame
                    }
                }
            }
        }
        return layoutAttributes
    }
    
    override var itemSize: CGSize {
        set {
            
        }
        get {
            let numberOfColumns: CGFloat = 2
            
            let itemWidth = (CGRectGetWidth(self.collectionView!.frame) - (30 * (numberOfColumns - 1))) / numberOfColumns
            return CGSizeMake(itemWidth, itemWidth)
        }
    }
    
    func setupLayout()
    {
        minimumInteritemSpacing = 10
        minimumLineSpacing = 10
        scrollDirection = .Vertical
    }

    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
}
