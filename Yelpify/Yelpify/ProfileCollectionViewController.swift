//
//  ProfileCollectionViewController.swift
//  Yelpify
//
//  Created by Jonathan Lam on 5/3/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import Parse
import XLActionController

private let reuseIdentifier = "listCell"

class ProfileCollectionViewController: UICollectionViewController {
    
    var user: PFUser!
    var user_playlists = [PFObject]()
    
    func goToSettings(){
        performSegueWithIdentifier("SettingsView", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navigationBar = navigationController!.navigationBar
        navigationBar.tintColor = UIColor.whiteColor()
        
        let rightButton = UIBarButtonItem(title: "Settings", style: .Plain , target: self, action: "goToSettings")
        
        navigationItem.rightBarButtonItem = rightButton
        if (user == nil)
        {
            user = PFUser.currentUser()
        }
        let query = PFQuery(className: "Playlists")
        query.whereKey("createdBy", equalTo: user)
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if (error == nil)
            {
                dispatch_async(dispatch_get_main_queue(), {
                    self.user_playlists = objects!
                    self.collectionView?.reloadData()
                })
            }
        }
        
        
        // Register Nibs
        self.collectionView!.registerNib(UINib(nibName: "ProfileHeader", bundle: NSBundle.mainBundle()), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "profileHeader")

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        

        // Register cell classes
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        //self.collectionView!.collectionViewLayout = CollectionViewLayout()
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
            headerView.user = user
            headerView.listnum = self.user_playlists.count
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
        return user_playlists.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        collectionView.registerNib(UINib(nibName: "ListCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "listCell")

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("listCell", forIndexPath: indexPath) as! ListCollectionViewCell
        
        cell.configureCellLayout()
    
        return cell
    }
    
    @IBAction func showSettings(sender: UIBarButtonItem) {
        let actionController = YoutubeActionController()
        
        actionController.addAction(Action(ActionData(title: "Logout", image: UIImage(named: "yt-add-to-watch-later-icon")!), style: .Default, handler: { action in
            PFUser.logOut()
            //create unwind segue
            
        }))
        actionController.addAction(Action(ActionData(title: "Cancel", image: UIImage(named: "yt-cancel-icon")!), style: .Cancel, handler: nil))
        
        presentViewController(actionController, animated: false, completion: nil)

    }
    

}
