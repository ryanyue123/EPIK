//
//  CollectionViewController.swift
//  Yelpify
//
//  Created by Kay Lab on 3/7/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit

class CollectionViewController: UICollectionViewController{
    // data source
    let publishers = Publishers()
    
    //Mark: - UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
        
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section:Int) -> Int{
        return publishers.numberOfPublishers
    }
    
    private struct Storyboard{
        static let CellIdentifier  = "PublisherCell"
        
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath:NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Storyboard.CellIdentifier, forIndexPath: <#T##NSIndexPath#>)
        return cell
    }
    
    
}