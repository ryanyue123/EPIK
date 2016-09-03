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

protocol SendCustomImages {
    func sendImage(image: UIImage)
}

class ProfileCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, ShouldSegueToImagePickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var user: PFUser!
    var user_playlists = [PFObject]()
    
    var imagePicker = UIImagePickerController()
    
    var headerView: ProfileHeaderCollectionReusableView!
    
    var sendImagesDelegate: SendCustomImages!
    
    func goToSettings(){
        performSegueWithIdentifier("SettingsView", sender: self)
    }

    func shouldSegue() {
        print("segue")
        showImagePicker()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            sendImagesDelegate.sendImage(pickedImage)
        }
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showImagePicker(){
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        // Configure Status Bar
        let statusBarRect = CGRect(x: 0, y: 0, width: imagePicker.navigationBar.frame.size.width, height: 20.0)
        let statusBarView = UIView(frame: statusBarRect)
        statusBarView.backgroundColor = appDefaults.color
        imagePicker.view.addSubview(statusBarView)
        
        // Configure Navigation Bar
        imagePicker.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Top, barMetrics: .Default)
        imagePicker.navigationBar.backgroundColor = appDefaults.color
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker.delegate = self
        
        self.navigationController?.configureTopBar()
        self.navigationController?.navigationBar.addShadow(0.2, offset: CGSizeMake(0, 5), path: true)
        
        let width = CGRectGetWidth(collectionView!.bounds)
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.headerReferenceSize = CGSize(width: width, height: 149)
        layout.itemSize = CGSize(width: width, height: 62)
        
        //navigationBar.tintColor = UIColor.whiteColor()
        
        let rightButton = UIBarButtonItem(title: "Settings", style: .Plain , target: self, action: #selector(self.goToSettings))
        
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
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateHeaderView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderView()
    }
    
    private let headerHeight: CGFloat = 149.0

    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        updateHeaderView()
        self.navigationController!.updateNavigationBarForFade(self.headerHeight, bottomScrollView: scrollView)
        if self.navigationController?.statusBar != nil{
            self.navigationController!.updateStatusBarForFade(self.headerHeight, bottomScrollView: scrollView)
        }
    }
    
    func fadeHeaderBG(){
        let indexPathArray = self.collectionView?.indexPathsForVisibleSupplementaryElementsOfKind(UICollectionElementKindSectionHeader)
        if indexPathArray!.count > 0{
            let fadeAlpha = (-collectionView!.contentOffset.y / headerHeight) * 0.5
            //print("indexPathArray", indexPathArray!)
            if self.headerView != nil{
                headerView.alpha = fadeAlpha
            }
//            let headerView = self.collectionView!.supplementaryViewForElementKind(UICollectionElementKindSectionHeader, atIndexPath: indexPathArray![0]) as! ProfileHeaderCollectionReusableView
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
            headerRect.size.height = -collectionView!.contentOffset.y - 64.0 + 149.0
        }else if collectionView!.contentOffset.y > 64.0{
            self.navigationItem.titleView?.tintColor = UIColor.whiteColor()
        }
        
        // Applies height and origin
        let indexPathArray = self.collectionView?.indexPathsForVisibleSupplementaryElementsOfKind(UICollectionElementKindSectionHeader)
        if indexPathArray?.count > 0{
            //let headerView = self.collectionView!.supplementaryViewForElementKind(UICollectionElementKindSectionHeader, atIndexPath: indexPathArray![0]) as! ProfileHeaderCollectionReusableView
            //print("origin.y", headerView.frame.origin.y)
            //print("height", headerView.frame.size.height)
            if self.headerView != nil{
                headerView.frame = headerRect
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "profileHeader", forIndexPath: indexPath) as! ProfileHeaderCollectionReusableView
            
            self.headerView = headerView
            headerView.user = user
           //headerView.configureSegmentedBar()
            
//            
//            if user == PFUser.currentUser(){
//                headerView.changeBGPicButton.hidden = false
//                headerView.changeBGPicButton.hidden = false
//            }else{
//                headerView.changeBGPicButton.hidden = true
//                headerView.changeBGPicButton.hidden = true
//            }
//            
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
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("singlePlaylistVC") as! ListViewController
        controller.object = user_playlists[indexPath.row]
        self.navigationController!.changeTopBarColor(.clearColor())
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if (section == 0) {
            return UIEdgeInsetsMake(-50.0, 9, 9, 9)
        }
        return UIEdgeInsetsMake(-50.0, 9, 9, 9)
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


