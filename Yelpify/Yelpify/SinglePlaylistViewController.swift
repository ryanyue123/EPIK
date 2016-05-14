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
import CZPicker

enum ContentTypes {
    case Places, Comments
}

enum ListMode{
    case View, Edit
}



class SinglePlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UIGestureRecognizerDelegate, MGSwipeTableCellDelegate, ModalViewControllerDelegate{
    
    //@IBOutlet weak var leftBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var addPlaceImageButton: UIImageView!
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
    
    @IBOutlet weak var segmentedBarView: UIView!
    
    var mode: ListMode! = .View
    
    var statusBarView: UIView!
    
    let offset_HeaderStop:CGFloat = 40.0
    var contentToDisplay: ContentTypes = .Places
    
    var collaborators = [PFObject]()
    var playlistArray = [Business]()
    
    var placeArray = [GooglePlaceDetail]()
    var placeIDs = [String]()
    
    var object: PFObject!
    var editable: Bool = false
    var sortMethod:String!
    var itemReceived: String!
    var playlist_name: String!
    
    var apiClient = APIDataHandler()
    
    // The apps default color
    let defaultAppColor = UIColor(netHex: 0xFFFFFF)
    
    var viewDisappearing = false
    
    func sendValue(value: AnyObject){
        itemReceived = value as! String
        
        if value as! String == "Alphabetical"{
            self.playlistArray = self.sortMethods(self.playlistArray, type: "name")
            self.playlistTableView.reloadData()
        }else if self.itemReceived == "Rating"{
            self.playlistArray = self.sortMethods(self.playlistArray, type: "rating")
            self.playlistTableView.reloadData()
        }
    }
    
    func sortMethods(businesses: Array<Business>, type: String)->Array<Business>{
        var sortedBusinesses: Array<Business> = []
        if type == "name"{
            sortedBusinesses = businesses.sort{$0.businessName < $1.businessName}
        } else if type == "rating"{
            sortedBusinesses = businesses.sort{$0.businessRating > $1.businessRating}
        }
        return sortedBusinesses
        
    }
    func makeCollaborative() {
        let searchVC = self.storyboard?.instantiateViewControllerWithIdentifier("searchpeople")
        let searchPeopleVC = searchVC?.childViewControllers[0] as! SearchPeopleTableViewController
        searchPeopleVC.playlist = self.object
        self.dismissViewControllerAnimated(false, completion: nil)
        self.presentViewController(searchVC!, animated: true, completion: nil)
    }
    
    
    
    func showActionsMenu(sender: AnyObject) {
        
        let actionController = YoutubeActionController()
        let pickerController = CZPickerViewController()
        let randomController = RandomPlaceController()

        actionController.addAction(Action(ActionData(title: "Get Random Place", image: UIImage(named: "yt-add-to-watch-later-icon")!), style: .Default, handler: { action in
            if self.playlistArray.count != 0{
                self.performSegueWithIdentifier("randomPlace", sender: self)
            }
            
        }))
        if (editable) {
            actionController.addAction(Action(ActionData(title: "Edit Playlist", image: UIImage(named: "yt-add-to-playlist-icon")!), style: .Default, handler: { action in
                print("Edit pressed")
                self.activateEditMode()
                self.playlistTableView.reloadData()
            }))
        }
        actionController.addAction(Action(ActionData(title: "Make Collaborative...", image: UIImage(named: "yt-add-to-watch-later-icon")!), style: .Default, handler: { action in
            self.makeCollaborative()
        }))
        actionController.addAction(Action(ActionData(title: "Sort", image: UIImage(named: "yt-share-icon")!), style: .Cancel, handler: { action in
            pickerController.headerTitle = "Sort Options"
            pickerController.fruits = ["Alphabetical","Rating"]
            pickerController.showWithFooter(UIViewController)
            pickerController.delegate = self
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
        print(segue.identifier)
        if(segue.identifier != nil) {
            if(segue.identifier == "unwindToPlaylist") {
                if let sourceVC = segue.sourceViewController as? SearchBusinessViewController
                {
                    playlistArray.appendContentsOf(sourceVC.businessArray)
                    self.playlistTableView.reloadData()
                }
            }
        }
    }

    // MARK: - ViewDidLoad and other View functions
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addPlaceImageButton.hidden = true
        let tap = UITapGestureRecognizer(target: self, action: "handleTap:")
        self.addPlaceImageButton.userInteractionEnabled = true
        self.addPlaceImageButton.addGestureRecognizer(tap)
        
        setupProfilePicture()
        self.playlistTableView.reloadData()
        
        
        // tapRecognizer, placed in viewDidLoad
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "longPress:")
        self.view.addGestureRecognizer(longPressRecognizer)
        
        // Register Nibs 
        self.playlistTableView.registerNib(UINib(nibName: "BusinessCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "businessCell")
        self.playlistTableView.registerNib(UINib(nibName: "ReviewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "reviewCell")

        self.addPlaceButton.hidden = true
        self.addPlaceButton.enabled = false

        self.playlistTableView.backgroundColor = appDefaults.color
        if (self.editable == true) {
            self.activateEditMode()
        }
        else if(object["createdBy"] as! PFUser == PFUser.currentUser()! || (object["Collaborators"] as! NSArray).containsObject(PFUser.currentUser()!)) {
            self.editable = true
            configureRecentlyViewed()
        }
        else {
            print("not nil")
            self.view.reloadInputViews()
            configureRecentlyViewed()
        }
        
        
        
        // Get Array of IDs from Parse
        let placeIDs = object["place_id_list"] as! [String]
        self.placeIDs = placeIDs
        self.updateBusinessesFromIDs(placeIDs)
        
        // Setup HeaderView with information
        self.configureInfo()
        
        // Setup Navigation Bar
        let navigationBar = navigationController!.navigationBar
        navigationBar.tintColor = UIColor.whiteColor()
        
        let rightButton = UIBarButtonItem(image: UIImage(named: "more_icon"), style: .Plain, target: self, action: "showActionsMenu:")
        
        navigationItem.rightBarButtonItem = rightButton
    }
    
    func updateBusinessesFromIDs(ids: [String]){
        for id in ids{
            apiClient.performDetailedSearch(id, completion: { (detailedGPlace) in
                self.placeArray.append(detailedGPlace)
                self.playlistArray.append(detailedGPlace.convertToBusiness())
                self.playlistTableView.reloadData()
            })
        }
    }
    
    func convertBusinessesToIDs(businesses: [Business], completion: (ids: [String]) -> Void) {
        var ids: [String] = []
        for business in businesses{
            ids.append(business.gPlaceID)
        }
        completion(ids: ids)
    }

    func handleTap(img: AnyObject){
       performSegueWithIdentifier("tapImageButton", sender: self)
        
    }
    
    override func viewDidAppear(animated: Bool){
        
        configureSegmentedBar()
        
            }
    
    override func viewWillAppear(animated: Bool) {
        //Configure Functions
        
        ConfigureFunctions.configureNavigationBar(self.navigationController!, outterView: self.view)
        self.statusBarView = ConfigureFunctions.configureStatusBar(self.navigationController!)
        
        playlistInfoView.frame.size.height = 350.0
        playlistTableHeaderHeight = playlistInfoView.frame.size.height
        configurePlaylistInfoView()
        
        if (object == nil) {
            playlist_name = playlist.playlistname
        }
        else {
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

    
    func unwindView(sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func configureInfo() {
        self.playlistInfoName.text = object["playlistName"] as? String
        let user = object["createdBy"] as! PFUser
        self.playlistInfoUser.titleLabel?.text = "BY " + user.username!.uppercaseString
        
        self.playlistInfoIcon.image = UIImage(named: "default_icon")
        self.playlistInfoBG.image = UIImage(named: "default_list_bg")
        
        self.numOfPlacesLabel.text = String(self.placeIDs.count)
        let followCount = object["followerCount"]
        if followCount == nil {
            self.numOfFollowersLabel.text = "0"
        }
        else {
            self.numOfFollowersLabel.text = String(followCount)
        }
        self.averagePriceRating.text = "$$$" // CHANGE
    }
    
    func configureRecentlyViewed() {
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
        }
    }
    
    func activateEditMode() {
        self.addPlaceImageButton.hidden = false
        UIView.animateWithDuration(0.3,delay: 0.0,options: UIViewAnimationOptions.BeginFromCurrentState,animations: {
            self.addPlaceImageButton.transform = CGAffineTransformMakeScale(0.5, 0.5)},
                                   completion: { finish in
                                    UIView.animateWithDuration(0.6){self.addPlaceImageButton.transform = CGAffineTransformIdentity}
        })
        
    
        self.mode = .Edit
        self.navigationItem.setHidesBackButton(true, animated: true)
        let backButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SinglePlaylistViewController.savePlaylistToParse(_:)))
        self.navigationItem.leftBarButtonItem = backButton
        self.addPlaceButton.hidden = false
        self.addPlaceButton.enabled = true
    }
    
    func deactivateEditMode() {
        self.addPlaceImageButton.hidden = true
        self.addPlaceButton.hidden = true
        self.addPlaceButton.enabled = false
        self.mode = .View
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
            frame: CGRect(x: 0.0, y: 0.0, width: self.playlistInfoView.frame.size.width, height: 40),
            titles: ["Places", "Comments"],
            index: 0,
            backgroundColor: appDefaults.color,
            titleColor: UIColor.whiteColor(),
            indicatorViewBackgroundColor: appDefaults.color_darker,
            selectedTitleColor: .whiteColor())
        control.autoresizingMask = [.FlexibleWidth]
        //control.cornerRadius = 10.0
        control.panningDisabled = true
        control.titleFont = UIFont(name: "Montserrat", size: 12.0)!
        control.addTarget(self, action: "switchContentType", forControlEvents: .ValueChanged)
        self.segmentedBarView.addSubview(control)
    }
    
    func switchContentType(){
        if self.contentToDisplay == .Places{
            self.contentToDisplay = .Comments
            self.playlistTableView.reloadData()
        }else{
            self.contentToDisplay = .Places
            self.playlistTableView.reloadData()
        }
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
        
        
        // IF SEGMENTED IS ON PLACES
        if self.contentToDisplay == .Places{
            let businessCell = tableView.dequeueReusableCellWithIdentifier("businessCell", forIndexPath: indexPath) as! BusinessTableViewCell

            businessCell.delegate = self
            configureSwipeButtons(businessCell, mode: self.mode)
            
            dispatch_async(dispatch_get_main_queue(), {
                businessCell.configureCellWith(self.playlistArray[indexPath.row], mode: .More) {
                    return businessCell
                }
            })
            return businessCell
              
        // IF SEGMENTED IS ON COMMENTS
        }else if self.contentToDisplay == .Comments{
            let reviewCell = tableView.dequeueReusableCellWithIdentifier("reviewCell", forIndexPath: indexPath) as! ReviewTableViewCell
            return reviewCell
        }else{
            return UITableViewCell()
        }
    }
    
    func configureSwipeButtons(cell: MGSwipeTableCell, mode: ListMode){
        if mode == .View{
            let routeButton = MGSwipeButton(title: "Route", icon: UIImage(named: "location_icon"),backgroundColor: appDefaults.color, padding: 25)
            routeButton.setEdgeInsets(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 15))
            routeButton.centerIconOverText()
            routeButton.titleLabel?.font = appDefaults.font
            
            let addButton = MGSwipeButton(title: "Add", icon: UIImage(named: "location_icon"),backgroundColor: appDefaults.color, padding: 25)
            addButton.setEdgeInsets(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 15))
            addButton.centerIconOverText()
            addButton.titleLabel?.font = appDefaults.font
            
            cell.leftButtons.removeAll()
            cell.rightButtons = [routeButton, addButton]
            cell.rightSwipeSettings.transition = MGSwipeTransition.ClipCenter
            cell.rightExpansion.buttonIndex = 0
            cell.rightExpansion.fillOnTrigger = true
            cell.rightExpansion.threshold = 1
        }else if mode == .Edit{
            cell.rightButtons.removeAll()
            let deleteButton = MGSwipeButton(title: "Delete",icon: UIImage(named: "location_icon"),backgroundColor: UIColor.redColor(),padding: 25)
            deleteButton.centerIconOverText()
            cell.leftButtons = [deleteButton]
            cell.leftSwipeSettings.transition = MGSwipeTransition.ClipCenter
            cell.leftExpansion.buttonIndex = 0
            cell.leftExpansion.fillOnTrigger = true
            cell.leftExpansion.threshold = 1
        }
    }
    
    // MGSwipeTableCell Delegate Methods

    func swipeTableCell(cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection) -> Bool {
        return true
    }
    
    func swipeTableCell(cell: MGSwipeTableCell!, tappedButtonAtIndex index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        let indexPath = playlistTableView.indexPathForCell(cell)
        let business = playlistArray[indexPath!.row] 
        let actions = PlaceActions()
        if self.mode == ListMode.View{
            if index == 0{
                actions.openInMaps(business)
        }
        }
        else if self.mode == ListMode.Edit{
            playlistArray.removeAtIndex(indexPath!.row)
            self.playlistTableView.reloadData()
        }
        
        return true
    }
    
    func swipeTableCell(cell: MGSwipeTableCell!, didChangeSwipeState state: MGSwipeState, gestureIsActive: Bool) {
        if self.mode == .View{
            let routeButton = cell.rightButtons.first as! MGSwipeButton
            let addButton = cell.rightButtons[1] as! MGSwipeButton
            if cell.swipeState.rawValue == 2{
                routeButton.backgroundColor = appDefaults.color
                addButton.backgroundColor = UIColor.greenColor()
            }
            else if cell.swipeState.rawValue >= 4{
                addButton.backgroundColor = appDefaults.color
                routeButton.backgroundColor = appDefaults.color
                cell.swipeBackgroundColor = appDefaults.color
                }
    
        }
    
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //print(indexPath.row)
        performSegueWithIdentifier("showBusinessDetail", sender: self)
    }
    
    // Override to support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
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
        if placeIDs.count > 0{
            let saveobject = object
//            if let lat = playlistArray[0].businessLatitude
//            {
//                if let long = playlistArray[0].businessLongitude
//                {
//                    saveobject["location"] = PFGeoPoint(latitude: lat, longitude: long)
//                }
//            }
            //saveobject["track"] = convertPlacesArrayToDictionary(playlistArray)
            
            // Saves Businesses to Parse as [String] Ids
            saveobject["place_id_list"] = placeIDs
            
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
        self.playlistTableView.reloadData()
    }
    
    @IBAction func showProfileView(sender: UIButton) {
        performSegueWithIdentifier("showProfileView", sender: self)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showBusinessDetail"){
            let upcoming: BusinessDetailViewController = segue.destinationViewController as! BusinessDetailViewController
            
            let index = playlistTableView.indexPathForSelectedRow!.row
            
            // IF NO NEW PLACE IS ADDED
            if index <= placeArray.count - 1{
                let gPlaceObject = placeArray[index]
                upcoming.gPlaceObject = gPlaceObject
                upcoming.index = index
            }else{
            // IF NEW PLACES ARE ADDED
                let businessObject = playlistArray[index]
                upcoming.object = businessObject
                upcoming.index = index
            }
            
            self.playlistTableView.deselectRowAtIndexPath(playlistTableView.indexPathForSelectedRow!, animated: true)
        }
        else if (segue.identifier == "showProfileView") {
            let upcoming = segue.destinationViewController as! ProfileCollectionViewController
            upcoming.user = object["createdBy"] as! PFUser
        }else if (segue.identifier == "randomPlace") {
            let upcoming = segue.destinationViewController as! RandomPlaceController
            upcoming.businessArray = self.playlistArray
        }
    }
}
