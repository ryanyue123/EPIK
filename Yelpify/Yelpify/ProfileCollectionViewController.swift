//
//  ProfileCollectionViewController.swift
//  Yelpify
//
//  Created by Jonathan Lam on 5/3/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit

private let reuseIdentifier = "listCell"

class ProfileCollectionViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Register Nibs
        self.collectionView!.registerNib(UINib(nibName: "ProfileHeader", bundle: NSBundle.mainBundle()), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "profileHeader")

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        

        // Register cell classes
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.collectionViewLayout = CollectionViewLayout()
        //collectionView?.reloadData()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "profileHeader", forIndexPath: indexPath) as! ProfileHeaderCollectionReusableView
            
            headerView.frame.size.height = 300.0
            
            headerView.configureView()
            
            return headerView
            
//        case UICollectionElementKindSectionFooter:
//            let footerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Footer", forIndexPath: indexPath) as! UICollectionReusableView
//            
//            footerView.backgroundColor = UIColor.greenColor();
//            return footerView
//            
        default:
            
            assert(false, "Unexpected element kind")
        }
    }

    

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 10
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        collectionView.registerNib(UINib(nibName: "ListCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "listCell")

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("listCell", forIndexPath: indexPath) as! ListCollectionViewCell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
