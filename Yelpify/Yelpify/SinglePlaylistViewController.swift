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

    
    // MARK: - ViewDidLoad and other View functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.convertParseArrayToBusinessArray(object["track"] as! [NSDictionary]) { (resultArray) in
            self.playlistArray = resultArray
            dispatch_async(dispatch_get_main_queue(), {
                self.playlistTableView.reloadData()
            })
        }
        
        self.playlistTableView.backgroundColor = appDefaults.color
        //navigationItem.rightBarButtonItem = editButtonItem()
        
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
        
        setupCollaboratorViews()
        //configurePlaylistInfoView()
    }
    
    override func viewDidAppear(animated: Bool) {
        playlistInfoView.frame.size.height = 350.0
        playlistTableHeaderHeight = playlistInfoView.frame.size.height
        print(playlistInfoView.frame.size.height)
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
        configurePlaylistInfoView()
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
        updateHeaderView()
        handleNavigationBarOnScroll()
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
        performSegueWithIdentifier("showProfileView", sender: self)
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
