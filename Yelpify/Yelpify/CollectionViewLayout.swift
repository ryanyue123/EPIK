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
            
            let itemWidth = (self.collectionView!.frame.width - (30 * (numberOfColumns - 1))) / numberOfColumns
            return CGSize(width: itemWidth, height: itemWidth)
        }
    }
    func setupLayout()
    {
        minimumInteritemSpacing = 10
        minimumLineSpacing = 10
        scrollDirection = .vertical
    }
}
