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

enum ContentTypes {
    case Places, Comments
}

class SinglePlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet weak var statusBarView: UIView!
    
    @IBOutlet weak var editPlaylistButton: UIBarButtonItem!

    @IBOutlet weak var playlistInfoView: UIView!
    @IBOutlet weak var playlistTableView: UITableView!
    
    @IBOutlet weak var playlistInfoBG: UIImageView!
    @IBOutlet weak var playlistInfoIcon: UIImageView!
    @IBOutlet weak var playlistInfoName: UILabel!
    @IBOutlet weak var playlistInfoUser: UIButton!
    @IBOutlet weak var collaboratorsImageView: UIView!
    
    @IBOutlet weak var numOfPlacesLabel: UILabel!
    @IBOutlet weak var numOfFollowersLabel: UILabel!
    @IBOutlet weak var averagePriceRating: UILabel!
    
    @IBOutlet weak var followListButton: UIButton!
    
    @IBOutlet weak var addPlaceButton: UIButton!
    
    @IBOutlet weak var segmentedBar: UISegmentedControl!
    @IBOutlet weak var segmentedBarView: UIView!
    
    let offset_HeaderStop:CGFloat = 40.0
    var contentToDisplay: ContentTypes = .Places
    
    //var businessObjects: [Business] = []
    var playlistArray = [Business]()
    var object: PFObject!
    var playlist_name: String!
    
    // The apps default color
    let defaultAppColor = UIColor(netHex: 0xFFFFFF)
    
    var viewDisappearing = false
    
    
    @IBAction func savePlaylist(sender: UIBarButtonItem) {
        savePlaylistToParse()
    }
    
    @IBAction func addPlaceButtonAction(sender: AnyObject)
    {
        
    }
    
    @IBAction func editPlaylistButtonAction(sender: AnyObject) {
        
        performSegueWithIdentifier("showActionsMenu", sender: self)
        /*
        let actionController = YoutubeActionController()
        
        actionController.addAction(Action(ActionData(title: "Add to Watch Later", image: UIImage(named: "yt-add-to-watch-later-icon")!), style: .Default, handler: { action in
        }))
        actionController.addAction(Action(ActionData(title: "Add to Playlist...", image: UIImage(named: "yt-add-to-playlist-icon")!), style: .Default, handler: { action in
        }))
        actionController.addAction(Action(ActionData(title: "Share...", image: UIImage(named: "yt-share-icon")!), style: .Default, handler: { action in
        }))
        actionController.addAction(Action(ActionData(title: "Cancel", image: UIImage(named: "yt-cancel-icon")!), style: .Cancel, handler: nil))
        
        presentViewController(actionController, animated: true, completion: nil)
    

        
        
        print(self.navigationItem.rightBarButtonItem!.title!)
        switch self.navigationItem.rightBarButtonItem!.title! {
        case "Edit":
            playlistTableView.setEditing(true, animated: true)
            self.navigationItem.rightBarButtonItem?.title = "Done" //= UIBarButtonItem(title: "Done", style: .Plain, target: self, action: nil)
        case "Done":
            playlistTableView.setEditing(false, animated: true)
            self.navigationItem.rightBarButtonItem?.title = "Edit"//= UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: nil)
        default:
            playlistTableView.setEditing(false, animated: true)
        }
 */
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

    
    // MARK: - ViewDidLoad and other View functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.playlistTableView.backgroundColor = appDefaults.color
        //navigationItem.rightBarButtonItem = editButtonItem()
        
        if (object == nil)
        {
            // Automatic edit mode
        }
        else if((object["createdbyuser"] as? String) == PFUser.currentUser()?.username) //later incorporate possibility of collaboration
        {
            self.convertParseArrayToBusinessArray(object["track"] as! [NSDictionary]) { (resultArray) in
                let viewedlist: NSMutableArray = []
                let recentlyviewed = PFUser.query()!
                recentlyviewed.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
                recentlyviewed.findObjectsInBackgroundWithBlock {(objects1: [PFObject]?, error: NSError?) -> Void in
                    let recent = objects1![0]
                    let recentarray = recent["recentlyViewed"] as! [String]
                    
                    viewedlist.addObjectsFromArray(recentarray)
                    viewedlist.insertObject(self.object.objectId!, atIndex: 0)
                    
                    recent["recentlyViewed"] = viewedlist
                    recent.saveInBackgroundWithBlock({ (success, error) in
                        if (error == nil)
                        {
                            print("Success")
                        }
                    })
                    
                }
                
                self.playlistArray = resultArray
                dispatch_async(dispatch_get_main_queue(), {
                    self.playlistTableView.reloadData()
                })
            }
            // edit button is enabled
        }
        else
        {
            // edit button disabled
            self.convertParseArrayToBusinessArray(object["track"] as! [NSDictionary]) { (resultArray) in
                
                let viewedlist: NSMutableArray = []
                let recentlyviewed = PFUser.query()!
                recentlyviewed.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
                recentlyviewed.findObjectsInBackgroundWithBlock {(objects1: [PFObject]?, error: NSError?) -> Void in
                    let recent = objects1![0]
                    let recentarray = recent["recentlyViewed"] as! [String]
                    
                    viewedlist.addObjectsFromArray(recentarray)
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
                    self.playlistTableView.reloadData()
                })
            }
        }

        
        setupCollaboratorViews()
        //configurePlaylistInfoView()
    }
    
    override func viewDidAppear(animated: Bool) {
        print("viewDidAppear")
    }
    
    override func viewWillAppear(animated: Bool) {
        print("viewWillAppear")
        
        //Configure Functions
        
        configureNavigationBar()
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
    
    // MARK: - Reload Data After Pass
    
    func convertParseArrayToBusinessArray(parseArray: [NSDictionary], completion: (resultArray: [Business])->Void){
        var businessArray: [Business] = []
        for dict in parseArray{
            let business = Business(name: dict["name"] as? String, address: dict["address"] as? String, photoRef: dict["photoRef"] as? String, latitude: dict["latitude"] as? Double, longitude: dict["longitude"] as? Double, placeID: dict["id"] as? String)
            businessArray.append(business)
        }
        completion(resultArray: businessArray)
    }
    
    // MARK: - Scroll View
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        fadePlaylistBG()
        if viewDisappearing != false{
            updateHeaderView()
            handleNavigationBarOnScroll()
        }
        
        let offset = scrollView.contentOffset.y + playlistInfoView.bounds.height
        
        if offset < 0{
            
        }else{
            
        }
        
        if offset > 323{
            var segmentTransform = CATransform3DIdentity
            segmentTransform = CATransform3DTranslate(segmentTransform, 0, (offset-315), 0)
            
            segmentedBarView.layer.transform = segmentTransform
        }else{
            
        }
        
        print(offset)
        
//        // Segment control
//        
//        let segmentViewOffset = playlistInfoView.frame.height - segmentedBarView.frame.height - offset
//        
//        var segmentTransform = CATransform3DIdentity
//        
//        // Scroll the segment view until its offset reaches the same offset at which the header stopped shrinking
//        segmentTransform = CATransform3DTranslate(segmentTransform, 0, max(segmentViewOffset, -offset_HeaderStop), 0)
//        
//        segmentedBarView.layer.transform = segmentTransform
//        
//        
//        // Set scroll view insets just underneath the segment control
//        playlistTableView.scrollIndicatorInsets = UIEdgeInsetsMake(segmentedBarView.frame.maxY, 0, 0, 0)
        
        
        
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
        self.view.viewWithTag(100)!.backgroundColor = appDefaults.color.colorWithAlphaComponent(showWhenScrollDownAlpha)
    }
    
    // MARK: - Setup Views
    
    private var playlistTableHeaderHeight: CGFloat = 250.0
    
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
        
        // Change the back button item to display no text
        //        let backItem = UIBarButtonItem()
        //        backItem.title = ""
        //        navigationController?.navigationItem.backBarButtonItem = backItem
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
    
    // MARK: - Set Up Collaborator View
    func setupCollaboratorViews(){
        addGestureToCollaboratorView()
        
        var numOfCollaborators = 2 // Temp Var
        var width: CGFloat = (collaboratorsImageView.frame.size.width / CGFloat(numOfCollaborators))
        var setWidth: CGFloat = width
        var height: CGFloat = collaboratorsImageView.frame.size.height
        var x = collaboratorsImageView.frame.origin.x
        
        var image = UIImage(named: "default_restaurant")// Temp Image

        for person in 0..<numOfCollaborators{
            print(person)
            let imageView = UIImageView(frame: CGRectMake(x, collaboratorsImageView.frame.origin.y, width, height))
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            
            collaboratorsImageView.addSubview(imageView)
            setWidth += width
            x += width
        }
    }
    
    func addGestureToCollaboratorView(){
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("tappedCollaborators"))
        self.collaboratorsImageView.userInteractionEnabled = true
        self.collaboratorsImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func tappedCollaborators(){
        //performSegueWithIdentifier("showProfileView", sender: self)
        let actionController = YoutubeActionController()
        
        actionController.addAction(Action(ActionData(title: "Add to Watch Later", image: UIImage(named: "yt-add-to-watch-later-icon")!), style: .Default, handler: { action in
            
        }))
        actionController.addAction(Action(ActionData(title: "Add to Playlist...", image: UIImage(named: "yt-add-to-playlist-icon")!), style: .Default, handler: { action in
            
        }))
        actionController.addAction(Action(ActionData(title: "Share...", image: UIImage(named: "yt-share-icon")!), style: .Default, handler: { action in
        }))
        actionController.addAction(Action(ActionData(title: "Cancel", image: UIImage(named: "yt-cancel-icon")!), style: .Cancel, handler: nil))
        
        presentViewController(actionController, animated: true, completion: nil)
        

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
        
//        let cell = tableView.dequeueReusableCellWithIdentifier("businessCell", forIndexPath: indexPath) as! BusinessTableViewCell
//        cell.configureCellWith(playlistArray[indexPath.row]) {
//            //self.playlistTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//        }
        
        var cell = UITableViewCell()
        
        switch contentToDisplay {
        case .Places:
            cell = tableView.dequeueReusableCellWithIdentifier("businessCell", forIndexPath: indexPath) as! BusinessTableViewCell
            //cell.textLabel?.text = "Tweet Tweet!"
            
        case .Comments:
            cell.textLabel?.text = "Piccies!"
            cell.imageView?.image = UIImage(named: "header_bg")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showBusinessDetail", sender: self)
    }
    
    // Override to support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            playlistArray.removeAtIndex(indexPath.row)
            playlistTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.playlistTableView.setEditing(editing, animated: animated)
    }

    
    // MARK - API Handling
    
    let dataHandler = APIDataHandler()
    var googleParameters = ["key": "AIzaSyDkxzICx5QqztP8ARvq9z0DxNOF_1Em8Qc", "location": "33.64496794563093,-117.83725295740864", "rankby":"distance", "keyword": ""]
    
    func performInitialSearch(){
        dataHandler.performAPISearch(googleParameters) { (businessObjectArray) -> Void in
            //self.businessObjects = businessObjectArray
            self.playlistTableView.reloadData()
        }
    }

    
    
    
    func convertPlacesArrayToDictionary(placesArray: [Business])-> [NSDictionary]{
        var placeDictArray = [NSDictionary]()
        for business in placesArray{
            placeDictArray.append(business.getDictionary())
        }
        return placeDictArray
    }
    
    func savePlaylistToParse()
    {
        let saveobject = PFObject(className: "Playlists")
        if let lat = playlistArray[0].businessLatitude
        {
            if let long = playlistArray[0].businessLongitude
            {
                saveobject["location"] = PFGeoPoint(latitude: lat, longitude: long)
            }
        }
        saveobject["createdbyuser"] = PFUser.currentUser()?.username
        saveobject["playlistName"] = playlist_name
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showBusinessDetail"){
            let upcoming: BusinessDetailViewController = segue.destinationViewController as! BusinessDetailViewController
            
            let indexPath = playlistTableView.indexPathForSelectedRow
            let object = playlistArray[indexPath!.row]
            upcoming.object = object
            upcoming.index = indexPath!.row
            self.playlistTableView.deselectRowAtIndexPath(indexPath!, animated: true)
        }else if (segue.identifier == "showActionsMenu"){
            let upcoming: ActionsViewController = segue.destinationViewController as! ActionsViewController
            //upcoming.view.backgroundColor = UIColor.clearColor()
            //upcoming.tableView.backgroundColor = UIColor.clearColor()
            //presentingViewController?.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            presentingViewController?.presentViewController(self, animated: true, completion: nil)
        }
    }
    
}
