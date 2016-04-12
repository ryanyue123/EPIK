//
//  PlaylistCreationViewController.swift
//  Yelpify
//
//  Created by Jonathan Lam on 3/9/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import Parse

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
    
    //var businessObjects: [Business] = []
    var playlistArray = [Business]()
    var object: PFObject!
    var playlist_name: String!
    
    // The apps default color
    let defaultAppColor = UIColor(netHex: 0xFFFFFF)
    
    @IBAction func addPlaceButtonAction(sender: AnyObject) {
        
    }
    
    @IBAction func editPlaylistButtonAction(sender: AnyObject) {
        
        performSegueWithIdentifier("showActionsMenu", sender: self)
        
        /*
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
    
    override func viewDidAppear(animated: Bool) {
        playlistInfoView.frame.size.height = 350
        playlistTableHeaderHeight = playlistInfoView.frame.size.height
        print(playlistInfoView.frame.size.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.playlistTableView.backgroundColor = appDefaults.color
        //navigationItem.rightBarButtonItem = editButtonItem()
        
        playlistInfoView.frame.size.height = 350
        
        if (object == nil)
        {
            // Automatic edit mode
        }
        else if((object["createdbyuser"] as? String) == PFUser.currentUser()?.username) //later incorporate possibility of collaboration
        {
            // edit button is enabled
        }
        else
        {
            // edit button disabled
        }
        
        configureNavigationBar()
        configurePlaylistInfoView()
    }
    
    override func viewWillAppear(animated: Bool) {
        if (object == nil)
        {
            playlist_name = playlist.playlistname
        }
        else
        {
            playlist_name = object["playlistName"] as! String
        }
        configureNavigationBar()
        configurePlaylistInfoView()
    }
    
    // MARK: - Table View Functions
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlistArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("businessCell", forIndexPath: indexPath) as! BusinessTableViewCell
        cell.configureCellWith(playlistArray[indexPath.row]) { 
            //self.playlistTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showBusinessDetail", sender: self)
    }
    
    // Override to support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
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
    func scrollViewDidScroll(scrollView: UIScrollView) {
        fadePlaylistBG()
        updateHeaderView()
        handleNavigationBarOnScroll()
    }
    
    private var playlistTableHeaderHeight: CGFloat = 250.0
    var headerView: UIView!
    
    func fadePlaylistBG(){
        self.playlistInfoBG.alpha = (-playlistTableView.contentOffset.y / playlistTableHeaderHeight) * 0.5
    }
    
    func handleNavigationBarOnScroll(){
        
        let showWhenScrollDownAlpha = 1 - (-playlistTableView.contentOffset.y / playlistTableHeaderHeight)
        //let showWhenScrollUpAlpha = (-playlistTableView.contentOffset.y / playlistTableHeaderHeight)
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(showWhenScrollDownAlpha) ]
        self.navigationItem.title = playlist_name
        
        // Handle Status Bar
        self.statusBarView.alpha = showWhenScrollDownAlpha
        
        // Handle Nav Shadow View
        self.view.viewWithTag(100)!.backgroundColor = appDefaults.color.colorWithAlphaComponent(showWhenScrollDownAlpha)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        playlistTableView.contentOffset.y = -350.0
        updateHeaderView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playlistTableView.contentOffset.y = -350.0
        updateHeaderView()
    }

    func updateHeaderView(){
        //playlistTableHeaderHeight = playlistInfoView.frame.size.height
        var headerRect = CGRect(x: 0, y: -playlistTableHeaderHeight, width: playlistTableView.frame.size.width, height: playlistTableHeaderHeight)
        
        //print("Playlist scrolled below offset", playlistTableView.contentOffset.y < -playlistTableHeaderHeight)
        
        if playlistTableView.contentOffset.y < -playlistTableHeaderHeight{
            //print("Scrolled above offset")
            headerRect.origin.y = playlistTableView.contentOffset.y
            headerRect.size.height = -playlistTableView.contentOffset.y
            //print(headerRect.origin.y, headerRect.size.height)
        }else if playlistTableView.contentOffset.y > -playlistTableHeaderHeight{
            //print("Scrolled below offset")
            self.navigationItem.title = playlist_name
            self.navigationItem.titleView?.tintColor = UIColor.whiteColor()
            
//            headerRect.origin.y = playlistTableView.contentOffset.y
//            headerRect.size.height = -playlistTableView.contentOffset.y//playlistTableHeaderHeight//playlistTableView.contentOffset.y
        }
        //print(headerRect)
        //print(playlistTableView.contentOffset.y)
        headerView.frame = headerRect
        //playlistInfoView.frame.size.height = 350.0
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

    
    func configurePlaylistInfoView(){
        headerView = playlistInfoView//playlistTableView.tableHeaderView
        
        playlistTableView.tableHeaderView = nil
        playlistTableView.addSubview(headerView)
        playlistTableView.contentInset = UIEdgeInsets(top: playlistTableHeaderHeight, left: 0, bottom: 0, right: 0)
        playlistTableView.contentOffset = CGPoint(x: 0, y: -playlistTableHeaderHeight)
    }
    
    func configureNavigationBar(){
        
        addShadowToBar()
    
        for parent in self.navigationController!.navigationBar.subviews {
            for childView in parent.subviews {
                if(childView is UIImageView) {
                    childView.removeFromSuperview()
                }
            }
        }
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        // Change the back button item to display no text
//        let backItem = UIBarButtonItem()
//        backItem.title = ""
//        navigationController?.navigationItem.backBarButtonItem = backItem
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
        let lat = playlistArray[0].businessLatitude!
        let long = playlistArray[0].businessLongitude!
        
        saveobject["createdbyuser"] = PFUser.currentUser()?.username
        saveobject["playlistName"] = playlist_name
        saveobject["track"] = convertPlacesArrayToDictionary(playlistArray)
        saveobject["location"] = PFGeoPoint(latitude: lat, longitude: long)
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
