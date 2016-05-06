//
//  CollectionViewLayout.swift
//  Yelpify
//
//  Created by Ryan Yue on 5/5/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit

class CollectionViewLayout: UICollectionViewFlowLayout {
    override init()
    {
        super.init()
        setupLayout()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    override var itemSize: CGSize {
        set {
            
        }
        get {
            let numberOfColumns: CGFloat = 2
            
            let itemWidth = (CGRectGetWidth(self.collectionView!.frame) - (5 * (numberOfColumns - 1))) / numberOfColumns
            return CGSizeMake(itemWidth, itemWidth)
        }
    }
    func setupLayout()
    {
        minimumInteritemSpacing = 5
        minimumLineSpacing = 5
        scrollDirection = .Vertical
    }
}
