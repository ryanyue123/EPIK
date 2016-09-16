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
//import BetterSegmentedControl
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


private let reuseIdentifier = "listCell"
//
//protocol SendCustomImages {
//    func sendImage(image: UIImage)
//}

class ProfileCollectionViewController_old: UICollectionViewController, UICollectionViewDelegateFlowLayout, ShouldSegueToImagePickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var user: PFUser!
    var user_playlists = [PFObject]()
    
    var imagePicker = UIImagePickerController()
    
    var headerView: ProfileHeaderCollectionReusableView!
    
    var sendImagesDelegate: SendCustomImages!
    
    func goToSettings(){
        performSegue(withIdentifier: "SettingsView", sender: self)
    }
    
    func shouldSegue() {
        print("segue")
        showImagePicker()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            sendImagesDelegate.sendImage(pickedImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func showImagePicker(){
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        // Configure Status Bar
        let statusBarRect = CGRect(x: 0, y: 0, width: imagePicker.navigationBar.frame.size.width, height: 20.0)
        let statusBarView = UIView(frame: statusBarRect)
        statusBarView.backgroundColor = appDefaults.color
        imagePicker.view.addSubview(statusBarView)
        
        // Configure Navigation Bar
        imagePicker.navigationBar.setBackgroundImage(UIImage(), for: .top, barMetrics: .default)
        imagePicker.navigationBar.backgroundColor = appDefaults.color
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker.delegate = self
        //let navigationBar = navigationController!.navigationBar
        self.navigationController?.configureTopBar()
        
        let width = collectionView!.bounds.width
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.headerReferenceSize = CGSize(width: width, height: 350)
        layout.itemSize = CGSize(width: width, height: 62)
        
        //navigationBar.tintColor = UIColor.whiteColor()
        
        let rightButton = UIBarButtonItem(title: "Settings", style: .plain , target: self, action: #selector(self.goToSettings))
        
        navigationItem.rightBarButtonItem = rightButton
        if (user == nil)
        {
            user = PFUser.current()
        }
        let query = PFQuery(className: "Playlists")
        query.whereKey("createdBy", equalTo: user)
        query.findObjectsInBackground { (objects, error) in
            if (error == nil)
            {
                DispatchQueue.main.async(execute: {
                    self.user_playlists = objects!
                    self.collectionView?.reloadData()
                })
            }
        }
        
        // Register Nibs
        self.collectionView!.register(UINib(nibName: "ProfileHeader", bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "profileHeader")
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        //self.collectionView!.collectionViewLayout = CollectionViewLayout()
        //collectionView?.reloadData()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    fileprivate let headerHeight: CGFloat = 350.0
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("content offset", self.collectionView!.contentOffset.y)
        //fadeHeaderBG()
        updateHeaderView()
        handleNavigationBarOnScroll()
    }
    
    func fadeHeaderBG(){
        let indexPathArray = self.collectionView?.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionElementKindSectionHeader)
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
            headerRect.size.height = -collectionView!.contentOffset.y - 64.0 + 350.0
        }else if collectionView!.contentOffset.y > 64.0{
            self.navigationItem.titleView?.tintColor = UIColor.white
        }
        
        // Applies height and origin
        let indexPathArray = self.collectionView?.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionElementKindSectionHeader)
        if indexPathArray?.count > 0{
            //let headerView = self.collectionView!.supplementaryViewForElementKind(UICollectionElementKindSectionHeader, atIndexPath: indexPathArray![0]) as! ProfileHeaderCollectionReusableView
            //print("origin.y", headerView.frame.origin.y)
            //print("height", headerView.frame.size.height)
            if self.headerView != nil{
                headerView.frame = headerRect
            }
        }
    }
    
    func handleNavigationBarOnScroll(){
        
        let showWhenScrollDownAlpha = (self.collectionView!.contentOffset.y / 180.0)
        //let showWhenScrollUpAlpha = (-playlistTableView.contentOffset.y / playlistTableHeaderHeight)
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(showWhenScrollDownAlpha) ]
        self.navigationItem.title = user.username
        self.navigationController?.navigationBar.backgroundColor = appDefaults.color.withAlphaComponent((showWhenScrollDownAlpha))
        
        // Handle Status Bar
        //self.statusBarView.alpha = showWhenScrollDownAlpha
        
        // Handle Nav Shadow View
        //self.statusBarView.backgroundColor = appDefaults.color.colorWithAlphaComponent(showWhenScrollDownAlpha)
        //self.view.viewWithTag(100)!.backgroundColor = appDefaults.color.colorWithAlphaComponent(showWhenScrollDownAlpha)
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "profileHeader", for: indexPath) as! ProfileHeaderCollectionReusableView
            
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
    
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return user_playlists.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        collectionView.register(UINib(nibName: "ListCell", bundle: Bundle.main), forCellWithReuseIdentifier: "listCell")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listCell", for: indexPath) as! ListCollectionViewCell
        
        cell.configureCell(user_playlists[(indexPath as NSIndexPath).row])
        //cell.configureCellLayout()
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = storyboard!.instantiateViewController(withIdentifier: "singlePlaylistVC") as! ListViewController
        controller.object = user_playlists[(indexPath as NSIndexPath).row]
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if (section == 0) {
            return UIEdgeInsetsMake(-50.0, 9, 9, 9)
        }
        return UIEdgeInsetsMake(-50.0, 9, 9, 9)
    }
    
    
    @IBAction func showSettings(_ sender: UIBarButtonItem) {
        let actionController = YoutubeActionController()
        
        actionController.addAction(Action(ActionData(title: "Logout", image: UIImage(named: "yt-add-to-watch-later-icon")!), style: .default, handler: { action in
            PFUser.logOut()
            //create unwind segue
            
        }))
        actionController.addAction(Action(ActionData(title: "Cancel", image: UIImage(named: "yt-cancel-icon")!), style: .cancel, handler: nil))
        
        present(actionController, animated: false, completion: nil)
        
    }
    
}


