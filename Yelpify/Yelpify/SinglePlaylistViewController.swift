//
//  PlaylistCreationViewController.swift
//  Yelpify
//
//  Created by Jonathan Lam on 3/9/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import Parse
import XLActionController
import MGSwipeTableCell
import BetterSegmentedControl

enum ContentTypes {
    case Places, Comments
}

class SinglePlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UIGestureRecognizerDelegate, MGSwipeTableCellDelegate{
    
    //@IBOutlet weak var leftBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var editPlaylistButton: UIBarButtonItem!

    @IBOutlet weak var playlistInfoView: UIView!
    @IBOutlet weak var playlistTableView: UITableView!
    
    @IBOutlet weak var playlistInfoBG: UIImageView!
    @IBOutlet weak var playlistInfoIcon: UIImageView!
    @IBOutlet weak var playlistInfoName: UILabel!
    @IBOutlet weak var playlistInfoUser: UIButton!
    @IBOutlet weak var collaboratorsView: UIView!
    @IBOutlet weak var creatorImageView: UIImageView!
    @IBOutlet weak var numOfPlacesLabel: UILabel!
    @IBOutlet weak var numOfFollowersLabel: UILabel!
    @IBOutlet weak var averagePriceRating: UILabel!
    
    @IBOutlet weak var followListButton: UIButton!
    
    @IBOutlet weak var addPlaceButton: UIButton!
    
    @IBOutlet weak var segmentedBar: UISegmentedControl!
    @IBOutlet weak var segmentedBarView: UIView!
    
    var statusBarView: UIView!
    
    let offset_HeaderStop:CGFloat = 40.0
    var contentToDisplay: ContentTypes = .Places
    
    var playlistArray = [Business]()
    var object: PFObject!
    var newPlaylist: Bool = false
    
    var playlist_name: String!
    
    // The apps default color
    let defaultAppColor = UIColor(netHex: 0xFFFFFF)
    
    var viewDisappearing = false
    
    func sortMethods(businesses: Array<Business>, type: String)->Array<Business>{
        var sortedBusinesses: Array<Business> = []
        if type == "name"{
            sortedBusinesses = businesses.sort{$0.businessName < $1.businessName}
        } else if type == "rating"{
            sortedBusinesses = businesses.sort{$0.businessRating > $1.businessRating}
        }
        return sortedBusinesses
        
    }

    
    @IBAction func editPlaylistButtonAction(sender: AnyObject) {
        
        let actionController = YoutubeActionController()
        
        actionController.addAction(Action(ActionData(title: "Share...", image: UIImage(named: "yt-add-to-watch-later-icon")!), style: .Default, handler: { action in
            print("Share")
        }))
        actionController.addAction(Action(ActionData(title: "Edit Playlist", image: UIImage(named: "yt-add-to-playlist-icon")!), style: .Default, handler: { action in
            print("Edit pressed")
            self.activateEditMode()
        }))
        actionController.addAction(Action(ActionData(title: "Sort", image: UIImage(named: "yt-share-icon")!), style: .Default, handler: { action in
            self.playlistArray = self.sortMethods(self.playlistArray, type: "name")
            self.playlistTableView.reloadData()
        }))
        actionController.addAction(Action(ActionData(title: "Cancel", image: UIImage(named: "yt-cancel-icon")!), style: .Cancel, handler: nil))
        
        presentViewController(actionController, animated: true, completion: nil)

    }
    
    @IBAction func selectContentType(sender: AnyObject) {
        // crap code I know
        if sender.selectedSegmentIndex == 0 {
            contentToDisplay = .Places
        }
        else {
            contentToDisplay = .Comments
        }
        
        playlistTableView.reloadData()
    }
    
    
    @IBAction func unwindToSinglePlaylist(segue: UIStoryboardSegue)
    {
        if(segue.identifier != nil)
        {
            if(segue.identifier == "unwindToPlaylist")
            {
                let sourceVC = segue.sourceViewController as! SearchBusinessViewController
                playlistArray.appendContentsOf(sourceVC.playlistArray)
                self.playlistTableView.reloadData()
            }
        }
    }
    
    func showActionMenu(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        print("Holding")
        if longPressGestureRecognizer.state == UIGestureRecognizerState.Began {
            print("Holding")
            
            let touchPoint = longPressGestureRecognizer.locationInView(self.view)
            
            if let indexPath = playlistTableView.indexPathForRowAtPoint(touchPoint) {
                
                let actionController = YoutubeActionController()
                
                actionController.addAction(Action(ActionData(title: "Add to Watch Later", image: UIImage(named: "yt-add-to-watch-later-icon")!), style: .Default, handler: { action in
                }))
                actionController.addAction(Action(ActionData(title: "Edit Playlist", image: UIImage(named: "yt-add-to-playlist-icon")!), style: .Default, handler: { action in
                    print("Edit pressed")
                    self.activateEditMode()
                }))
                actionController.addAction(Action(ActionData(title: "Share...", image: UIImage(named: "yt-share-icon")!), style: .Default, handler: { action in
                }))
                actionController.addAction(Action(ActionData(title: "Cancel", image: UIImage(named: "yt-cancel-icon")!), style: .Cancel, handler: nil))
                
                presentViewController(actionController, animated: true, completion: nil)
            }
        }
        
    }
    
    //Called, when long press occurred
    func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.Began {
            
            let touchPoint = longPressGestureRecognizer.locationInView(self.view)
            if let indexPath = playlistTableView.indexPathForRowAtPoint(touchPoint) {
                let actionController = YoutubeActionController()
                
                actionController.addAction(Action(ActionData(title: "Add to Watch Later", image: UIImage(named: "yt-add-to-watch-later-icon")!), style: .Default, handler: { action in
                }))
                actionController.addAction(Action(ActionData(title: "Add to Playlist...", image: UIImage(named: "yt-add-to-playlist-icon")!), style: .Default, handler: { action in
                }))
                actionController.addAction(Action(ActionData(title: "Share...", image: UIImage(named: "yt-share-icon")!), style: .Default, handler: { action in
                }))
                actionController.addAction(Action(ActionData(title: "Cancel", image: UIImage(named: "yt-cancel-icon")!), style: .Cancel, handler: nil))
                
                presentViewController(actionController, animated: true, completion: nil)

                // your code here, get the row for the indexPath or do whatever you want
            }
        }
    }
    

    // MARK: - ViewDidLoad and other View functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let control = BetterSegmentedControl(
            frame: CGRect(x: 0.0, y: 0.0, width: view.bounds.width + 16, height: self.segmentedBarView.frame.size.height),
            titles: ["Places", "Comments"],
            index: 1,
            backgroundColor: appDefaults.color,
            titleColor: UIColor.whiteColor(),
            indicatorViewBackgroundColor: .whiteColor(),
            selectedTitleColor: .whiteColor())
        control.titleFont = UIFont(name: "Montserrat-Regular", size: 12.0)!
        control.addTarget(self, action: nil, forControlEvents: .ValueChanged)
        self.segmentedBarView.addSubview(control)
        
        setupProfilePicture()
        
        // tapRecognizer, placed in viewDidLoad
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "longPress:")
        self.view.addGestureRecognizer(longPressRecognizer)
        
        // Register Nibs 
         self.playlistTableView.registerNib(UINib(nibName: "BusinessCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "businessCell")

        self.addPlaceButton.hidden = true
        self.addPlaceButton.enabled = false
        
        
        self.playlistTableView.backgroundColor = appDefaults.color
        if (self.newPlaylist == true)
        {
            print("This is a new playlist")
            // Automatic edit mode
            self.activateEditMode()
        }
        
        else if(object["createdBy"] as! PFUser == PFUser.currentUser()!)
            //later incorporate possibility of collaboration
        {
            
            //print("not nil")
            self.convertParseArrayToBusinessArray(object["track"] as! [NSDictionary]) { (resultArray) in
                let viewedlist: NSMutableArray = []
                let recentlyviewed = PFUser.query()!
                recentlyviewed.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
                recentlyviewed.findObjectsInBackgroundWithBlock {(objects1: [PFObject]?, error: NSError?) -> Void in
                    let recent = objects1![0]
                    if let recentarray = recent["recentlyViewed"] as? [String]
                    {
                    
                        viewedlist.addObjectsFromArray(recentarray)
                    }
                    viewedlist.insertObject(self.object.objectId!, atIndex: 0)
                    
                    recent["recentlyViewed"] = viewedlist
                    recent.saveInBackgroundWithBlock({ (success, error) in
                        if (error == nil)
                        {
                        }
                    })
                    
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.playlistArray = resultArray
                    self.playlistTableView.reloadData()
                    self.configureInfo()
                })
            }
            // edit button is enabled
        }
        else
        {
            print("not nil")
            self.view.reloadInputViews()
            self.convertParseArrayToBusinessArray(object["track"] as! [NSDictionary]) { (resultArray) in
                
                let viewedlist: NSMutableArray = []
                let recentlyviewed = PFUser.query()!
                recentlyviewed.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
                recentlyviewed.findObjectsInBackgroundWithBlock {(objects1: [PFObject]?, error: NSError?) -> Void in
                    let recent = objects1![0]
                    if let recentarray = recent["recentlyViewed"] as? [String]
                    {
                        viewedlist.addObjectsFromArray(recentarray)
                    }
                    viewedlist.insertObject(self.object.objectId!, atIndex: 0)
                    
                    recent["recentlyViewed"] = viewedlist
                    recent.saveInBackgroundWithBlock({ (success, error) in
                        if (error == nil)
                        {
                            print("Success")
                        }
                    })
                    
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.playlistArray = resultArray
                    self.playlistTableView.reloadData()
                    self.configureInfo()
                })
            }
        }

        configureSegmentedBar()
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func viewWillAppear(animated: Bool) {
        //Configure Functions
        
        ConfigureFunctions.configureNavigationBar(self.navigationController!, outterView: self.view)
        self.statusBarView = ConfigureFunctions.configureStatusBar(self.navigationController!)
        
        playlistInfoView.frame.size.height = 350.0
        playlistTableHeaderHeight = playlistInfoView.frame.size.height
        configurePlaylistInfoView()
        
        if (object == nil)
        {
            playlist_name = playlist.playlistname
        }
        else
        {
            playlist_name = object["playlistName"] as! String
        }
        configurePlaylistInfoView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        print("viewWillDisappear")
        self.viewDisappearing = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateHeaderView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderView()
    }

    
    func unwindView(sender: UIBarButtonItem)
    {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func configureInfo(){
        self.playlistInfoName.text = object["playlistName"] as? String
        let user = object["createdBy"] as! PFUser
        self.playlistInfoUser.titleLabel?.text = "BY " + user.username!.uppercaseString
        
        self.playlistInfoIcon.image = UIImage(named: "default_icon")
        self.playlistInfoBG.image = UIImage(named: "default_list_bg")
        
        self.numOfPlacesLabel.text = String(playlistArray.count)
        let followCount = object["followerCount"]
        if followCount == nil
        {
            self.numOfFollowersLabel.text = "0"
        }
        else
        {
            self.numOfFollowersLabel.text = String(followCount)
        }
        self.averagePriceRating.text = "$$$" // CHANGE
    }
    
    func activateEditMode()
    {
        self.navigationItem.setHidesBackButton(true, animated: true)
        let backButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "savePlaylistToParse:")
        self.navigationItem.leftBarButtonItem = backButton
        self.addPlaceButton.hidden = false
        self.addPlaceButton.enabled = true
    }
    
    // MARK: - Reload Data After Pass
    
    func convertParseArrayToBusinessArray(parseArray: [NSDictionary], completion: (resultArray: [Business])->Void){
        var businessArray: [Business] = []
        for dict in parseArray{
            var business = Business()

            business.businessName = dict["name"] as! String
            business.businessAddress = dict["address"] as! String
            if let photoRef = dict["photoRef"] as? String{
                business.businessPhotoReference = photoRef
            }
            business.businessRating = dict["rating"] as! Double
            business.businessLatitude = dict["latitude"] as! Double
            business.businessLongitude = dict["longitude"] as! Double
            business.gPlaceID = dict["id"] as! String
            businessArray.append(business)
        }
        completion(resultArray: businessArray)
    }
    
    // MARK: - Scroll View
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        fadePlaylistBG()
        updateHeaderView()
        handleNavigationBarOnScroll()
        
        let offset = scrollView.contentOffset.y + playlistInfoView.bounds.height

        
//        if offset > 323{
//            var segmentTransform = CATransform3DIdentity
//            segmentTransform = CATransform3DTranslate(segmentTransform, 0, (offset-315), 0)
//            
//            segmentedBarView.layer.transform = segmentTransform
//        }else{
//            
//        }
        
        
    }
    
    func fadePlaylistBG(){
        self.playlistInfoBG.alpha = (-playlistTableView.contentOffset.y / playlistTableHeaderHeight) * 0.5
    }
    
    func handleNavigationBarOnScroll(){
        
        let showWhenScrollDownAlpha = 1 - (-playlistTableView.contentOffset.y / playlistTableHeaderHeight)
        //let showWhenScrollUpAlpha = (-playlistTableView.contentOffset.y / playlistTableHeaderHeight)
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(showWhenScrollDownAlpha) ]
        self.navigationItem.title = playlist_name
        
        self.navigationController?.navigationBar.backgroundColor = appDefaults.color.colorWithAlphaComponent((showWhenScrollDownAlpha))
        
        // Handle Status Bar
        self.statusBarView.alpha = showWhenScrollDownAlpha
        
        // Handle Nav Shadow View
        //self.statusBarView.backgroundColor = appDefaults.color.colorWithAlphaComponent(showWhenScrollDownAlpha)
        //self.view.viewWithTag(100)!.backgroundColor = appDefaults.color.colorWithAlphaComponent(showWhenScrollDownAlpha)
    }
    
    // MARK: - Setup Views
    
    private var playlistTableHeaderHeight: CGFloat = 350.0
    
    func configurePlaylistInfoView(){
        playlistTableView.tableHeaderView = nil
        playlistTableView.addSubview(playlistInfoView)
        playlistTableView.contentInset = UIEdgeInsets(top: playlistTableHeaderHeight, left: 0, bottom: 0, right: 0)
        playlistTableView.contentOffset = CGPoint(x: 0, y: -playlistTableHeaderHeight)
    }
    
    func configureNavigationBar(){
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        //self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        addShadowToBar()
        
        for parent in self.navigationController!.navigationBar.subviews {
            for childView in parent.subviews {
                if(childView is UIImageView) {
                    childView.removeFromSuperview()
                }
            }
        }
        
    }
    
    func configureSegmentedBar(){
        let control = BetterSegmentedControl(
            frame: CGRect(x: 0.0, y: 330.0, width: self.view.frame.width, height: 20.0),
            titles: ["Places, Comments"],
            index: 1,
            backgroundColor: appDefaults.color,
            titleColor: .whiteColor(),
            indicatorViewBackgroundColor: appDefaults.color_bg,
            selectedTitleColor: .blackColor())
        control.titleFont = UIFont(name: "Montserrat-Regular", size: 10.0)!
        control.addTarget(self, action: nil, forControlEvents: .ValueChanged)
        self.view.addSubview(control)
        control.tag = 302
        
        let controlView = view.viewWithTag(302)
        self.view.bringSubviewToFront(controlView!)
    }
    
    func updateHeaderView(){
        //playlistTableHeaderHeight = playlistInfoView.frame.size.height
        var headerRect = CGRect(x: 0, y: -playlistTableHeaderHeight, width: playlistTableView.frame.size.width, height: playlistTableHeaderHeight)
        if playlistTableView.contentOffset.y < -playlistTableHeaderHeight{
            //print("Scrolled above offset")
            headerRect.origin.y = playlistTableView.contentOffset.y
            headerRect.size.height = -playlistTableView.contentOffset.y
        }else if playlistTableView.contentOffset.y > -playlistTableHeaderHeight{
            //print("Scrolled below offset")
            self.navigationItem.title = playlist_name
            self.navigationItem.titleView?.tintColor = UIColor.whiteColor()
            
            //            headerRect.origin.y = playlistTableView.contentOffset.y
            //            headerRect.size.height = -playlistTableView.contentOffset.y//playlistTableHeaderHeight//playlistTableView.contentOffset.y
        }
        playlistInfoView.frame = headerRect
    }
    
    func addShadowToBar() {
        let shadowView = UIView(frame: self.navigationController!.navigationBar.frame)
        //shadowView.backgroundColor = appDefaults.color
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowOpacity = 0.7 // your opacity
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 3) // your offset
        shadowView.layer.shadowRadius =  10 //your radius
        self.view.addSubview(shadowView)
        self.view.bringSubviewToFront(statusBarView)
        
        shadowView.tag = 100
    }
    
    func setupProfilePicture(){
        self.roundingUIView(self.creatorImageView, cornerRadiusParam: 15)
        self.roundingUIView(self.collaboratorsView, cornerRadiusParam: 15)
        self.collaboratorsView.layer.borderWidth = 2.0
        self.collaboratorsView.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    private func roundingUIView(let aView: UIView!, let cornerRadiusParam: CGFloat!) {
        aView.clipsToBounds = true
        aView.layer.cornerRadius = cornerRadiusParam
    }
    
    func addGestureToCollaboratorView(){
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("tappedCollaborators"))
        self.collaboratorsView.userInteractionEnabled = true
        self.collaboratorsView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func tappedCollaborators(){
        
    }

    
    // MARK: - Table View Functions
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch contentToDisplay {
        case .Places:
            return playlistArray.count
            
        case .Comments:
            return 20
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("businessCell", forIndexPath: indexPath) as! BusinessTableViewCell
        cell.delegate = self

        
        // Configure Cell
        cell.configureCellWith(playlistArray[indexPath.row], mode: .More) {
        }
        
        // Add Swipe Buttons
        // configure left buttons
        cell.leftButtons = [MGSwipeButton(title: "Route", backgroundColor: appDefaults.color_darker, padding: 30)]
        cell.leftSwipeSettings.transition = MGSwipeTransition.ClipCenter

        // configure right buttons
        cell.rightButtons = [MGSwipeButton(title: "Add", backgroundColor: UIColor.redColor())]
        cell.rightSwipeSettings.transition = MGSwipeTransition.ClipCenter
        
        cell.leftExpansion.buttonIndex = 0
        cell.leftExpansion.fillOnTrigger = false
        cell.leftExpansion.threshold = 1.75
        
        
        return cell
    }
    
    // MGSwipeTableCell Delegate Methods
    
    func swipeTableCell(cell: MGSwipeTableCell!, tappedButtonAtIndex index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        let indexPath = playlistTableView.indexPathForCell(cell)
        let business = playlistArray[indexPath!.row] as! Business
        let actions = PlaceActions()
        actions.openInMaps(business)
        
        return true
    }
    
    func swipeTableCell(cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection) -> Bool {
        return true
    }
    
    func swipeTableCell(cell: MGSwipeTableCell!, didChangeSwipeState state: MGSwipeState, gestureIsActive: Bool) {
        
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //print(indexPath.row)
        performSegueWithIdentifier("showBusinessDetail", sender: self)
    }
    
    // Override to support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        print("this is row ")
        print(indexPath.row)
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
    {
        var shareAction = UITableViewRowAction(style: .Normal, title: "Share") {(action:
            UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            print("sharing")
        }
        
        shareAction.backgroundColor = appDefaults.color
        
        var routeAction = UITableViewRowAction(style: .Normal, title: "Route") { (action: UITableViewRowAction!, indexPath: NSIndexPath) in
            print("routing")
        }
        
        routeAction.backgroundColor = appDefaults.color_darker
        
        return [shareAction, routeAction]
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
    }
    
    func convertPlacesArrayToDictionary(placesArray: [Business])-> [NSDictionary]{
        var placeDictArray = [NSDictionary]()
        for business in placesArray{
            placeDictArray.append(business.getDictionary())
        }
        return placeDictArray
    }
    
    func savePlaylistToParse(sender: UIBarButtonItem)
    {
        if playlistArray.count > 0{
            let saveobject = object
            if let lat = playlistArray[0].businessLatitude
            {
                if let long = playlistArray[0].businessLongitude
                {
                    saveobject["location"] = PFGeoPoint(latitude: lat, longitude: long)
                }
            }
            saveobject["track"] = convertPlacesArrayToDictionary(playlistArray)
            saveobject.saveInBackgroundWithBlock { (success, error)  -> Void in
                if (error == nil){
                    print("saved")
                }
                else{
                    print(error?.description)
                }
            }
        }
        
        self.navigationItem.setHidesBackButton(false, animated: true)
        self.navigationItem.leftBarButtonItem = nil
    }
    
    @IBAction func showProfileView(sender: UIButton) {
        performSegueWithIdentifier("showProfileView", sender: self)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showBusinessDetail"){
            let upcoming: BusinessDetailViewController = segue.destinationViewController as! BusinessDetailViewController
            
            let indexPath = playlistTableView.indexPathForSelectedRow
            let temp = indexPath!.row
            let object = playlistArray[temp]
            upcoming.object = object
            upcoming.index = indexPath!.row
            self.playlistTableView.deselectRowAtIndexPath(indexPath!, animated: true)
        }
        else if (segue.identifier == "showProfileView")
        {
            let upcoming = segue.destinationViewController as! ProfileCollectionViewController
            upcoming.user = object["createdBy"] as! PFUser
        }
    }
    
}
