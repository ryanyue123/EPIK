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
import BetterSegmentedControl

private let reuseIdentifier = "listCell"

class ProfileCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var user: PFUser!
    var user_playlists = [PFObject]()
    
    func goToSettings(){
        performSegueWithIdentifier("SettingsView", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let navigationBar = navigationController!.navigationBar
        ConfigureFunctions.configureNavigationBar(self.navigationController!, outterView: self.view)
        ConfigureFunctions.configureStatusBar(self.navigationController!)
        
        
        let width = CGRectGetWidth(collectionView!.bounds)
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.headerReferenceSize = CGSize(width: width, height: 350)
        layout.itemSize = CGSize(width: width, height: 62)
        
        //navigationBar.tintColor = UIColor.whiteColor()
        
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
    
    override func viewDidAppear(animated: Bool) {
        //ConfigureFunctions.resetNavigationBar(self.navigationController!)
        handleNavigationBarOnScroll()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateHeaderView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderView()
    }
    
    private let headerHeight: CGFloat = 350.0

    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        print("content offset", self.collectionView!.contentOffset.y)
        //fadeHeaderBG()
        updateHeaderView()
        handleNavigationBarOnScroll()
    }
    
    func fadeHeaderBG(){
        let indexPathArray = self.collectionView?.indexPathsForVisibleSupplementaryElementsOfKind(UICollectionElementKindSectionHeader)
        if indexPathArray!.count > 0{
            let fadeAlpha = (-collectionView!.contentOffset.y / headerHeight) * 0.5
            //print("indexPathArray", indexPathArray!)
            let headerView = self.collectionView!.supplementaryViewForElementKind(UICollectionElementKindSectionHeader, atIndexPath: indexPathArray![0]) as! ProfileHeaderCollectionReusableView
            headerView.alpha = fadeAlpha
        }
        //self.playlistInfoName.alpha = fadeAlpha
        
        //self.playlistInfoBG.transform = CGAffineTransformMakeScale(scale, scale)
    }
    
    func updateHeaderView(){
        //playlistTableHeaderHeight = playlistInfoView.frame.size.height
        var headerRect = CGRect(x: 0, y: -64.0, width: collectionView!.frame.size.width, height: headerHeight)
        if collectionView!.contentOffset.y < -64.0{
            //print("Scrolled above offset")
            headerRect.origin.y = collectionView!.contentOffset.y
            headerRect.size.height = -collectionView!.contentOffset.y - 64.0 + 350.0
        }else if collectionView!.contentOffset.y > 64.0{
            self.navigationItem.titleView?.tintColor = UIColor.whiteColor()
        }
        
        // Applies height and origin
        let indexPathArray = self.collectionView?.indexPathsForVisibleSupplementaryElementsOfKind(UICollectionElementKindSectionHeader)
        if indexPathArray?.count > 0{
            let headerView = self.collectionView!.supplementaryViewForElementKind(UICollectionElementKindSectionHeader, atIndexPath: indexPathArray![0]) as! ProfileHeaderCollectionReusableView
            print("origin.y", headerView.frame.origin.y)
            print("height", headerView.frame.size.height)

            headerView.frame = headerRect
        }
    }
    
    func handleNavigationBarOnScroll(){
        
        let showWhenScrollDownAlpha = (self.collectionView!.contentOffset.y / 180.0)
        //let showWhenScrollUpAlpha = (-playlistTableView.contentOffset.y / playlistTableHeaderHeight)
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(showWhenScrollDownAlpha) ]
        self.navigationItem.title = "hi"
        self.navigationController?.navigationBar.backgroundColor = appDefaults.color.colorWithAlphaComponent((showWhenScrollDownAlpha))
        
        // Handle Status Bar
        //self.statusBarView.alpha = showWhenScrollDownAlpha
        
        // Handle Nav Shadow View
        //self.statusBarView.backgroundColor = appDefaults.color.colorWithAlphaComponent(showWhenScrollDownAlpha)
        //self.view.viewWithTag(100)!.backgroundColor = appDefaults.color.colorWithAlphaComponent(showWhenScrollDownAlpha)
    }
    

    // MARK: UICollectionViewDataSource
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "profileHeader", forIndexPath: indexPath) as! ProfileHeaderCollectionReusableView
            
            //headerView.frame.size.height = 350.0
            headerView.user = user
            headerView.listnum = self.user_playlists.count
            headerView.configureView()
            
            return headerView
        default:
            
            assert(false, "Unexpected element kind")
        }
    }

    

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return user_playlists.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        collectionView.registerNib(UINib(nibName: "ListCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "listCell")

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("listCell", forIndexPath: indexPath) as! ListCollectionViewCell
        
        cell.configureCell(user_playlists[indexPath.row])
       //cell.configureCellLayout()
    
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if (section == 0) {
            return UIEdgeInsetsMake(-50.0, 7.5, 0, 7.5)
        }
        return UIEdgeInsetsMake(-50.0, 7.5, 0, 7.5)
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
