//
//  SearchPlaylistCollectionViewController.swift
//  Yelpify
//
//  Created by Jonathan Lam on 5/2/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import Parse
import XLPagerTabStrip

private let reuseIdentifier = "listCell"

class SearchPlaylistCollectionViewController: UICollectionViewController, UITextFieldDelegate, IndicatorInfoProvider {
    
    @IBOutlet var collection_view: UICollectionView!
    var itemInfo: IndicatorInfo = "Lists"
    var playlist_query = [PFObject]()
    var searchTextField: UITextField!
    
    var locationUpdated = false
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if self.navigationController?.navigationBar.backgroundColor != appDefaults.color{
//            // Configure Functions
//           self.configureTopBar()
//        }
        
        self.collection_view.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        self.collection_view.backgroundColor = appDefaults.color_bg
        self.collection_view.collectionViewLayout = CollectionViewLayout()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // Register cell classes
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        let query = PFQuery(className: "Playlists")
        query.limit = 10
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if (error == nil)
            {
                dispatch_async(dispatch_get_main_queue(), {
                    self.playlist_query = objects!
                    self.collection_view.reloadData()
                })
            }
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.collection_view.reloadData()
    }

    override func viewDidAppear(animated: Bool) {
        self.navigationController?.resetNavigationBar(0)
        if locationUpdated == true{
            // UPDATE LOCATION UPDATES
        }
        
        if (searchTextField != nil)
        {
            searchTextField.placeholder = "Search for Place Lists"
            searchTextField.delegate = self
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        self.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("hello")
        let query = PFQuery(className: "Playlists")
        query.whereKey("playlistName", containsString: textField.text?.uppercaseString)        
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if (error == nil)
            {
                dispatch_async(dispatch_get_main_queue(), {

                    self.playlist_query = objects!
                    self.collection_view.reloadData()
                })
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain , target: self, action: "pressedCancel:")
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let rightButton = UIBarButtonItem(image: UIImage(named: "location_icon"), style: .Plain, target: self, action: "pressedLocation:")
        
        navigationItem.rightBarButtonItem = rightButton
        
    }
    
    
    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        print(playlist_query.count)
        return playlist_query.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        collectionView.registerNib(UINib(nibName: "ListCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "listCell")
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("listCell", forIndexPath: indexPath) as! ListCollectionViewCell
        let cellobject = self.playlist_query[indexPath.row]
        
        cell.configureCell(cellobject)
        
        return cell
    }
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("singlePlaylistVC") as! SinglePlaylistViewController
        controller.object = playlist_query[indexPath.row]
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
}
