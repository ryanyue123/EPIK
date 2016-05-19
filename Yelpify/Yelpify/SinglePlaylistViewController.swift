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
import Async

enum ContentTypes {
    case Places, Comments
}

enum ListMode{
    case View, Edit
}

class SinglePlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UIGestureRecognizerDelegate, MGSwipeTableCellDelegate, ModalViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate, Dimmable{
    
    //@IBOutlet weak var leftBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var addPlaceImageButton: UIImageView!
    @IBOutlet weak var editPlaylistButton: UIBarButtonItem!
    
    @IBOutlet weak var playlistInfoView: UIView!
    @IBOutlet weak var playlistTableView: UITableView!
    
    @IBOutlet weak var playlistInfoBG: UIImageView!
    
    @IBOutlet weak var indicatorTabView: UIView!
    
    
    let imagePicker = UIImagePickerController()
    
    @IBAction func loadImageButton(sender: AnyObject) {
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
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBOutlet weak var changePlaylistImageButton: UIButton!
    
    @IBOutlet weak var playlistInfoIcon: UIImageView!
    @IBOutlet weak var playlistInfoName: UITextField!
    @IBOutlet weak var playlistInfoUser: UIButton!
    @IBOutlet weak var collaboratorsView: UIView!
    @IBOutlet weak var creatorImageView: UIImageView!
    @IBOutlet weak var numOfPlacesLabel: UILabel!
    @IBOutlet weak var numOfFollowersLabel: UILabel!
    @IBOutlet weak var averagePriceRating: UILabel!
    
    @IBOutlet weak var followListButton: UIButton!
    
    @IBOutlet weak var segmentedBarView: UIView!
    
    var customImage: UIImage! = nil
    
    var mode: ListMode! = .View
    
    var statusBarView: UIView!
    
    let offset_HeaderStop:CGFloat = 40.0
    var contentToDisplay: ContentTypes = .Places
    
    var collaborators = [PFObject]()
    var playlistArray = [Business]()
    
    var placeArray = [GooglePlaceDetail]()
    var placeIDs = [String]()
    
    var commentsArray = [[String: String]]()
    
    var object: PFObject!
    var editable: Bool = false
    var sortMethod:String!
    var itemReceived: Array<AnyObject> = []
    var playlist_name: String!
    
    var addToOwnPlaylists: [PFObject]!
    var playlist_swiped: String!
    var comments = [NSDictionary]()
    
    var apiClient = APIDataHandler()
    
    var loadedSegmented = false
    
    // The apps default color
    let defaultAppColor = UIColor(netHex: 0xFFFFFF)
    
    var viewDisappearing = false
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            playlistInfoBG.contentMode = .ScaleAspectFill
            playlistInfoBG.clipsToBounds = true
            playlistInfoBG.image = pickedImage
            self.customImage = pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sendValue(value: AnyObject){
        itemReceived.append(value as! NSObject)
        
        for item in itemReceived{
            if item as! NSObject == "Alphabetical"{
                self.playlistArray = self.sortMethods(self.playlistArray, type: "name")
                getIDsFromArrayOfBusiness(self.playlistArray, completion: { (result) in
                    self.placeIDs = result
                    self.placeArray = self.sortGooglePlaces(self.placeArray, type: "name")
                    print("sorting")
                    self.playlistTableView.reloadData()
                })
            }else if item as! NSObject == "Rating"{
                self.playlistArray = self.sortMethods(self.playlistArray, type: "rating")
                getIDsFromArrayOfBusiness(self.playlistArray, completion: { (result) in
                    self.placeIDs = result
                    self.placeArray = self.sortGooglePlaces(self.placeArray, type: "rating")
                    self.playlistTableView.reloadData()
                })
                
            }
            else {
                let index = item as! Int
                var playlist = addToOwnPlaylists[index]["place_id_list"] as! [String]
                print(playlist)
                playlist.append(self.playlist_swiped)
                print(playlist)
                
                addToOwnPlaylists[index]["num_places"] = playlist.count
                addToOwnPlaylists[index]["place_id_list"] = playlist
                addToOwnPlaylists[index].saveInBackgroundWithBlock({ (success, error) in
                    if (error == nil) {
                        print("Saved")
                    }
                })
            }
            itemReceived = []
        }
        
        
    }
    
    func getIDsFromArrayOfBusiness(business: [Business], completion: (result:[String])->Void){
        var result:[String] = []
        for b in business{
            result.append(b.gPlaceID)
        }
        completion(result: result)
    }
    
    func sortMethods(businesses: Array<Business>, type: String)->[Business]{
        var sortedBusinesses: Array<Business> = []
        if type == "name"{
            sortedBusinesses = businesses.sort{$0.businessName < $1.businessName}
        } else if type == "rating"{
            sortedBusinesses = businesses.sort{$0.businessRating > $1.businessRating}
        }
        return sortedBusinesses
    }
    
    func sortGooglePlaces(gPlaces: [GooglePlaceDetail],type:String) -> [GooglePlaceDetail]{
        var sortedBusinesses: Array<GooglePlaceDetail> = []
        if type == "name"{
            sortedBusinesses = gPlaces.sort{$0.name < $1.name}
        } else if type == "rating"{
            sortedBusinesses = gPlaces.sort{$0.rating > $1.rating}
        }
        return sortedBusinesses

    }
    
    func makeCollaborative() {
        //let searchVC = self.storyboard?.instantiateViewControllerWithIdentifier("searchpeople")
        let searchPeopleVC = self.storyboard?.instantiateViewControllerWithIdentifier("searchPeopleVC") as! SearchPeopleTableViewController
        let navController = UINavigationController(rootViewController: searchPeopleVC) // Creating a navigation controller with VC1 at the root of the navigation stack.
        self.presentViewController(navController, animated:true, completion: nil)
        //let searchPeopleVC = searchVC?.childViewControllers[0] as! SearchPeopleTableViewController
        
        searchPeopleVC.mode = .Collaborate
        searchPeopleVC.collaborative = true
        searchPeopleVC.playlist = self.object
        self.dismissViewControllerAnimated(false, completion: nil)
        self.presentViewController(navController, animated: true, completion: nil)
    }
    
    
    
    func showActionsMenu(sender: AnyObject) {
        let actionController = YoutubeActionController()
        let pickerController = CZPickerViewController()
        let randomController = RandomPlaceController()
        
        actionController.addAction(Action(ActionData(title: "Randomize", image: UIImage(named: "action_random")!), style: .Default, handler: { action in
            if self.playlistArray.count != 0{
                self.performSegueWithIdentifier("randomPlace", sender: self)
            }
            
        }))
        if (editable) {
            actionController.addAction(Action(ActionData(title: "Edit", image: UIImage(named: "action_edit")!), style: .Default, handler: { action in
                print("Edit pressed")
                self.activateEditMode()
                self.playlistTableView.reloadData()
            }))
        }
        if (self.editable) {
            actionController.addAction(Action(ActionData(title: "Make Collaborative", image: UIImage(named: "action_collab")!), style: .Default, handler: { action in
                self.makeCollaborative()
            }))
        }
        actionController.addAction(Action(ActionData(title: "Sort", image: UIImage(named: "action_sort")!), style: .Cancel, handler: { action in
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
                    placeIDs.appendContentsOf(sourceVC.placeIDs)
                    
                    // Appends empty GooglePlaceDetail Objects to make list parallel to placeIDs and playlistArray
                    for _ in 0..<(placeIDs.count - placeArray.count){
                        placeArray.append(GooglePlaceDetail())
                    }
                    
                    // Update Info
                    self.numOfPlacesLabel.text = "\(placeIDs.count)"
                    self.getAveragePrice({ (avg) in
                        self.setPriceRating(avg)
                    })
                    self.playlistTableView.reloadData()
                }
            }
        }
    }
    

    @IBAction func unwindToSinglePlaylistWithComment(segue: UIStoryboardSegue){
        dim(.Out, alpha: dimLevel, speed: dimSpeed)
            if (segue.identifier == "withComment"){
            let sourceVC = segue.sourceViewController as? AddCommentViewController
                
            let username = "@ " + (PFUser.currentUser()?.username)!
            let newComment = sourceVC?.comment_content.text!
            let date = NSDate().timeIntervalSince1970.description
                
            if sourceVC?.comment_content.text != ""{
            // SAVE COMMENT TO PARSE
                Async.main{
                    let saveobject = self.object
                    var commentsArray = saveobject["comments"] as! [[String: String]]
                    commentsArray.insert(["text": newComment!,"author_name": username, "time": date], atIndex: 0)
                    
                    saveobject["comments"] = commentsArray
                    
                    saveobject.saveInBackgroundWithBlock { (success, error)  -> Void in
                        if (error == nil){
                            print("saved comment")
                        }else{
                            print(error?.description)
                        }
                    }
                }.main{
                    self.commentsArray.insert(["text": newComment!,"author_name": username, "time": date], atIndex: 0)
                    self.playlistTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
                }
            }
        }
        
    }
    
    // MARK: - ViewDidLoad and other View functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        ConfigureFunctions.configureNavigationBar(self.navigationController!, outterView: self.view)
        self.statusBarView = ConfigureFunctions.configureStatusBar(self.navigationController!)
        
        self.configurePlaylistInfoView()
        
        self.addPlaceImageButton.hidden = true
        let tap = UITapGestureRecognizer(target: self, action: "pressedOnAddPlace:")
        self.addPlaceImageButton.userInteractionEnabled = true
        self.addPlaceImageButton.addGestureRecognizer(tap)
        
        // Register Nibs
        self.playlistTableView.registerNib(UINib(nibName: "BusinessCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "businessCell")
        self.playlistTableView.registerNib(UINib(nibName: "ReviewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "reviewCell")
        
        
        self.playlistTableView.backgroundColor = appDefaults.color_bg
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
        
        Async.userInteractive{
            self.updateComments()
        }
    
        Async.main{
            self.segmentedBarView.userInteractionEnabled = false
            let placeIDs = self.object["place_id_list"] as! [String]
            self.placeIDs = placeIDs
            // Setup HeaderView with information
            self.configureInfo()
        }.main{
            // Get Array of IDs from Parse
            for _ in 0..<self.placeIDs.count{
                self.placeArray.append(GooglePlaceDetail())
                self.playlistArray.append(Business())
            }
            self.playlistTableView.reloadData()
        }.main{
            self.updateBusinessesFromIDs(self.placeIDs)
        }
        
        let rightButton = UIBarButtonItem(image: UIImage(named: "more_icon"), style: .Plain, target: self, action: "showActionsMenu:")
        navigationItem.rightBarButtonItem = rightButton
        
    }
    let dimLevel: CGFloat = 0.8
    let dimSpeed: Double = 0.5
    
    override func viewDidAppear(animated: Bool){
        handleNavigationBarOnScroll()
        if self.loadedSegmented == false{
            self.configureSegmentedBar()
            self.loadedSegmented = true
        }
        //self.performSegueWithIdentifier("addComment", sender: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if (object == nil) {
            playlist_name = playlist.playlistname
        }
        else {
            playlist_name = object["playlistName"] as! String
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
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
    
    func updateComments(){
        commentsArray = object["comments"] as! [[String : String]]
    }
    
    func updateBusinessesFromIDs(ids:[String], reloadIndex: Int = 0){
        if ids.count > 0{
            apiClient.performDetailedSearch(ids[0]) { (detailedGPlace) in
                self.placeArray[reloadIndex] = detailedGPlace
                self.playlistArray[reloadIndex] = detailedGPlace.convertToBusiness()
                
                // self.placeArray.append(detailedGPlace)
                // self.playlistArray.append(detailedGPlace.convertToBusiness())
                let idsSlice = Array(ids[1..<ids.count])
                let index = NSIndexPath(forRow: reloadIndex, inSection: 0)
                self.playlistTableView.reloadRowsAtIndexPaths([index], withRowAnimation: .Fade) // CHANGE
                let newIndex = reloadIndex + 1
                self.updateBusinessesFromIDs(idsSlice, reloadIndex: newIndex)
            }
        }else{
            self.segmentedBarView.userInteractionEnabled = true
            //self.playlistTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
        }
    }
    
    func convertBusinessesToIDs(businesses: [Business], completion: (ids: [String]) -> Void) {
        var ids: [String] = []
        for business in businesses{
            ids.append(business.gPlaceID)
        }
        completion(ids: ids)
    }
    
    func pressedOnAddPlace(img: AnyObject){
        if self.contentToDisplay == .Places{
            performSegueWithIdentifier("tapImageButton", sender: self)
        }else if self.contentToDisplay == .Comments{
            performSegueWithIdentifier("addComment", sender: self)
        }
    }
    
    
    func unwindView(sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func setPriceRating(price: Int){
        var result = ""
        if price != -1 && price != 0{
            for _ in 0..<price{
                result += "$"
            }
            self.averagePriceRating.text = result
        }else{
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "-$-")
            attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
            self.averagePriceRating.attributedText = attributeString
        }
    }
    
    func getAveragePrice(completion:(avg: Int) -> Void){
        var total = 0.0
        var numOfPlaces = 0.0
        for place in self.placeArray{
            if place.priceRating != -1{
                total += Double(place.priceRating)
                numOfPlaces += 1
            }
        }
        if numOfPlaces > 0{
            completion(avg: Int(round(total/numOfPlaces)))
        }else{
            completion(avg: -1)
        }
    }
    
    // MARK: - Set Up Header View With Info
    func configureInfo() {
        
        let pushAlpha: Double = 1.0
        let pushDuration: Double = 0.7
        let pushBeginScale: CGFloat = 1.0
        let pushAllScale: CGFloat = 1.1
        
        //fadeInView(self.playlistInfoView, duration: pushDuration, beginScale: pushAllScale)
        
        // Set List Name
        if let name = object["playlistName"] as? String{
            fadeInTextField(self.playlistInfoName, textToSet: name, duration: pushDuration, beginScale: pushBeginScale)
        }
        
        // Set User Name
        let user = object["createdBy"] as! PFUser
        self.playlistInfoUser.alpha = 0
        var byTitle = "BY " + user.username!.uppercaseString
        self.playlistInfoUser.setTitle("BY " + user.username!.uppercaseString, forState: .Normal)
        if let collabArray = object["Collaborators"] as? [PFUser]{
            if collabArray.count > 0{
                byTitle += " AND OTHERS" //+ String(collabArray[0].username).uppercaseString
            }
        }
        self.playlistInfoUser.setTitle(byTitle, forState: .Normal)
        
        fadeInView(self.playlistInfoUser, duration: pushDuration, beginScale: pushBeginScale)
        
        // Set Icon // CHANGE
        fadeInImageView(self.playlistInfoIcon, imageToAdd: UIImage(named: "default_Icon")!, duration: pushDuration, beginScale: pushBeginScale)
        self.playlistInfoIcon.transform = CGAffineTransformMakeScale(1.2, 1.2)
        //self.playlistInfoIcon.image = UIImage(named: "default_Icon")
        
        // Set Collaborators/ Authors Image
        self.setupCollaborators(object)
        
        self.fadeInView(self.collaboratorsView, duration: pushDuration, beginScale: pushBeginScale)
        self.fadeInImageView(self.creatorImageView, imageToAdd: UIImage(named: "face")!,  duration: pushDuration, beginScale: 0.8)
        
        // Set BG if custom BG exists in Parse
        if let bg = object["custom_bg"] as? PFFile{
            bg.getDataInBackgroundWithBlock({ (data, error) in
                if error == nil{
                    let image = UIImage(data: data!)
                    self.fadeInImageView(self.playlistInfoBG, imageToAdd: image!, endAlpha: 0.5, beginScale: 1.2)
                }
            })
        }else{
            self.fadeInImageView(self.playlistInfoBG, imageToAdd: UIImage(named: "default_list_bg")!, endAlpha: 0.5, beginScale: 1.2)
        }
        
        // Set Number of Places
        self.numOfPlacesLabel.text = String(self.placeIDs.count)
        
        let followCount = object["followerCount"]
        if followCount == nil {
            self.numOfFollowersLabel.text = "0"
        }
        else {
            self.numOfFollowersLabel.text = String(followCount)
        }
        
        if let avgPrice = object["average_price"] as? Int{
            self.setPriceRating(avgPrice)
        }
    }
    
    // CHANGE
    func setupCollaborators(object: PFObject){
        let collabList = object["Collaborators"] as! NSArray
        if collabList.count > 0{
            let originalX = self.collaboratorsView.frame.origin.x
            let originalWidth = self.collaboratorsView.frame.width
            self.collaboratorsView.transform = CGAffineTransformMakeScale(2.0, 0)
            self.collaboratorsView.transform = CGAffineTransformMakeTranslation(originalX - originalWidth, 0)
            
            let newRect = CGRectMake(self.collaboratorsView.frame.origin.x + originalWidth,
                                     self.collaboratorsView.frame.origin.y, originalWidth,
                                     self.collaboratorsView.frame.height)
            
            self.creatorImageView.transform = CGAffineTransformMakeTranslation(originalX - originalWidth, 0)
        
            let collabProfPic = UIImageView(frame: newRect)
            collabProfPic.image = UIImage(named: "face")
            self.collaboratorsView.backgroundColor = UIColor.clearColor()
            self.setupProfilePicture(self.creatorImageView)
            self.setupProfilePicture(collabProfPic)
            
            self.collaboratorsView.addSubview(collabProfPic)
            
        }else{
            self.setupProfilePicture(self.creatorImageView)
            self.collaboratorsView.backgroundColor = UIColor.clearColor()
        }
    }
    
    // MARK: - Animation Functions
    func fadeInImageView(imageView: UIImageView, imageToAdd: UIImage, duration: Double = 1,  endAlpha: CGFloat = 1, beginScale: CGFloat, endScale: CGFloat = 1){
        
        imageView.alpha = 0
        imageView.image = imageToAdd
        imageView.transform = CGAffineTransformMakeScale(beginScale, beginScale)
        imageView.clipsToBounds = true
        UIView.animateWithDuration(duration, animations: {
            imageView.alpha = endAlpha
            imageView.transform = CGAffineTransformMakeScale(endScale, endScale)
        })
    }
    
    func fadeInView(view: UIView, duration: Double = 1, endAlpha: CGFloat = 1, beginScale: CGFloat, endScale: CGFloat = 1, beginOffsetY: CGFloat = 0, endOffsetY: CGFloat = 0){
        view.alpha = 0
        view.layer.frame.origin.y += beginOffsetY
        view.transform = CGAffineTransformMakeScale(beginScale, beginScale)
        view.clipsToBounds = true
        UIView.animateWithDuration(duration, animations: {
            view.layer.frame.origin.y -= endOffsetY
            view.alpha = endAlpha
            view.transform = CGAffineTransformMakeScale(endScale, endScale)
        })
    }
    
    func fadeInLabel(label: UILabel, textToSet: String, duration: Double = 1, endAlpha: CGFloat = 1, beginScale: CGFloat, endScale: CGFloat = 1, beginOffsetY: CGFloat = 0, endOffsetY: CGFloat = 0){
        label.alpha = 0
        label.layer.frame.origin.y += beginOffsetY
        label.text = textToSet
        label.transform = CGAffineTransformMakeScale(beginScale, beginScale)
        label.clipsToBounds = true
        UIView.animateWithDuration(duration, animations: {
            label.layer.frame.origin.y -= endOffsetY
            label.alpha = endAlpha
            label.transform = CGAffineTransformMakeScale(endScale, endScale)
        })
    }
    
    func fadeInTextField(textField: UITextField, textToSet: String, duration: Double = 1, endAlpha: CGFloat = 1, beginScale: CGFloat, endScale: CGFloat = 1, beginOffsetY: CGFloat = 0, endOffsetY: CGFloat = 0){
        textField.alpha = 0
        textField.layer.frame.origin.y += beginOffsetY
        textField.text = textToSet
        textField.transform = CGAffineTransformMakeScale(beginScale, beginScale)
        textField.clipsToBounds = true
        UIView.animateWithDuration(duration, animations: {
            textField.layer.frame.origin.y -= endOffsetY
            textField.alpha = endAlpha
            textField.transform = CGAffineTransformMakeScale(endScale, endScale)
        })
    }

    
    func configureRecentlyViewed() {
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
    
    
    // MARK: Activate and Deactivate Edit Modes
    func activateEditMode() {
        
        // Make Title Text Editable
        self.playlistInfoName.userInteractionEnabled = true
        self.playlistInfoName.delegate = self
        
        // Show Change BG Image Button
        self.changePlaylistImageButton.hidden = false
    
        // Replace More Button With Cancel Button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "deactivateEditMode")
        
        // Animate and Show Add Place Button
        self.addPlaceImageButton.hidden = false
        UIView.animateWithDuration(0.3,delay: 0.0,options: UIViewAnimationOptions.BeginFromCurrentState,animations: {
            self.addPlaceImageButton.transform = CGAffineTransformMakeScale(0.5, 0.5)},
                                   completion: { finish in
                                    UIView.animateWithDuration(0.6){self.addPlaceImageButton.transform = CGAffineTransformIdentity}
        })
        
        // Set Editing to True
        self.setEditing(true, animated: true)
        
        // Set Edit Mode
        self.mode = .Edit
        
        // Replace Back Button with Done
        self.navigationItem.setHidesBackButton(true, animated: true)
        let backButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SinglePlaylistViewController.savePlaylistToParse(_:)))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    func deactivateEditMode() {
        
        // Make Title Text Editable
        self.playlistInfoName.userInteractionEnabled = false
        self.playlistInfoName.delegate = nil
        
        // Hide Change BG Image Button
        self.changePlaylistImageButton.hidden = true
        
        // Restore More Icon to Right Side of Nav Bar
        let rightButton = UIBarButtonItem(image: UIImage(named: "more_icon"), style: .Plain, target: self, action: "showActionsMenu:")
        navigationItem.rightBarButtonItem = rightButton
        
        // Restore Back Button
        self.navigationItem.setHidesBackButton(false, animated: true)
        self.navigationItem.leftBarButtonItem = nil
        
        // Set Editing to False
        self.setEditing(false, animated: true)
        
        // Hide Add Place Button
        self.addPlaceImageButton.hidden = true
        // Change to View Mode
        self.mode = .View
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
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
        let fadeAlpha = (-playlistTableView.contentOffset.y / playlistTableHeaderHeight) * 0.5
        //let scale = (-playlistTableView.contentOffset.y / playlistTableHeaderHeight) + 0.5
        
        self.playlistInfoBG.alpha = fadeAlpha
        //self.playlistInfoName.alpha = fadeAlpha
        
        //self.playlistInfoBG.transform = CGAffineTransformMakeScale(scale, scale)
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
        self.playlistInfoName.font = UIFont(name: "Montserrat-Regular", size: 32.0)
        playlistTableView.tableHeaderView = nil
        playlistTableView.addSubview(playlistInfoView)
        playlistTableView.contentInset = UIEdgeInsets(top: playlistTableHeaderHeight, left: 0, bottom: 0, right: 0)
        playlistTableView.contentOffset = CGPoint(x: 0, y: -playlistTableHeaderHeight)
    }
    
    func configureSegmentedBar(){
        let control = BetterSegmentedControl(
            frame: CGRect(x: 0.0, y: 0.0, width: self.playlistInfoView.frame.size.width, height: 40),
            titles: ["Places", "Comments"],
            index: 0,
            backgroundColor: appDefaults.color,
            titleColor: UIColor.whiteColor(),
            indicatorViewBackgroundColor: appDefaults.color,
            selectedTitleColor: .whiteColor())
        control.autoresizingMask = [.FlexibleWidth]
        control.panningDisabled = true
        control.titleFont = UIFont(name: "Montserrat", size: 12.0)!
        control.addTarget(self, action: "switchContentType", forControlEvents: .ValueChanged)
        control.alpha = 0
        self.segmentedBarView.addSubview(control)
        UIView.animateWithDuration(0.3) {
            control.alpha = 1
        self.segmentedBarView.bringSubviewToFront(self.indicatorTabView)
        }
    }
    
    
    func switchContentType(){
        switch self.contentToDisplay{
        case .Places:
            self.contentToDisplay = .Comments
            
            let tX = self.view.frame.width / 2
            
            UIView.animateWithDuration(0.2, animations: {
                self.indicatorTabView.transform = CGAffineTransformMakeTranslation(tX, 0)
            })
            
            
            self.playlistTableView.allowsSelection = false
            self.playlistTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
            
            self.addPlaceImageButton.hidden = false

        case .Comments:
            
            self.contentToDisplay = .Places
            
            let tX = self.view.frame.width / 2
            UIView.animateWithDuration(0.2, animations: {
                self.indicatorTabView.transform = CGAffineTransformMakeTranslation(0, 0)
            })
            
            self.playlistTableView.allowsSelection = true
            self.playlistTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
            self.addPlaceImageButton.hidden = true

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
    
//    func addShadowToBar() {
//        let shadowView = UIView(frame: self.navigationController!.navigationBar.frame)
//        //shadowView.backgroundColor = appDefaults.color
//        shadowView.layer.masksToBounds = false
//        shadowView.layer.shadowOpacity = 0.7 // your opacity
//        shadowView.layer.shadowOffset = CGSize(width: 0, height: 3) // your offset
//        shadowView.layer.shadowRadius =  10 //your radius
//        self.view.addSubview(shadowView)
//        self.view.bringSubviewToFront(statusBarView)
//        
//        shadowView.tag = 100
//    }
//    
    func setupProfilePicture(imageView: UIImageView){
        self.roundingUIView(self.creatorImageView, cornerRadiusParam: 15)
        //self.roundingUIView(self.collaboratorsView, cornerRadiusParam: 15)
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2.0
        imageView.layer.borderColor = UIColor.whiteColor().CGColor
        //self.collaboratorsView.layer.borderColor = UIColor.whiteColor().CGColor
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
            return commentsArray.count
        }
    }
    
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if self.mode == .Edit{
            return true
        }else{
            return false
        }
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        var itemToMove = playlistArray[fromIndexPath.row]
        var placeItemToMove = placeArray[fromIndexPath.row]
        var idOfItemToMove = placeIDs[fromIndexPath.row]
        
        playlistArray.removeAtIndex(fromIndexPath.row)
        placeArray.removeAtIndex(fromIndexPath.row)
        placeIDs.removeAtIndex(fromIndexPath.row)
        
        playlistArray.insert(itemToMove, atIndex: toIndexPath.row)
        placeArray.insert(placeItemToMove, atIndex: toIndexPath.row)
        placeIDs.insert(idOfItemToMove, atIndex: toIndexPath.row)
    }
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
            return true
    }

    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
            return .Delete
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete{
            playlistArray.removeAtIndex(indexPath.row)
            placeArray.removeAtIndex(indexPath.row)
            placeIDs.removeAtIndex(indexPath.row)
            self.playlistTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            self.playlistTableView.reloadData()
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
            
            reviewCell.configureCell(self.commentsArray[indexPath.row], ratingHidden: true)
            
            return reviewCell
        }else{
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (self.contentToDisplay == .Comments) {
            return UITableViewAutomaticDimension
        }
        return 110.0
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (self.contentToDisplay == .Comments) {
            return UITableViewAutomaticDimension
        }
        return 110.0
    }
    
    func configureSwipeButtons(cell: MGSwipeTableCell, mode: ListMode){
        if mode == .View{
            let routeButton = MGSwipeButton(title: "ROUTE", icon: UIImage(named: "swipe_route"),backgroundColor: appDefaults.color, padding: 25)
            routeButton.setEdgeInsets(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 15))
            routeButton.centerIconOverText()
            routeButton.titleLabel?.font = appDefaults.font
            
            let addButton = MGSwipeButton(title: "ADD", icon: UIImage(named: "swipe_add"),backgroundColor: appDefaults.color, padding: 25)
            addButton.setEdgeInsets(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 15))
            addButton.centerIconOverText()
            addButton.titleLabel?.font = appDefaults.font
            
            cell.rightButtons = [addButton]
            cell.rightSwipeSettings.transition = MGSwipeTransition.ClipCenter
            cell.rightExpansion.buttonIndex = 0
            cell.rightExpansion.fillOnTrigger = false
            cell.rightExpansion.threshold = 1
            
            cell.leftButtons = [routeButton]
            cell.leftSwipeSettings.transition = MGSwipeTransition.ClipCenter
            cell.leftExpansion.buttonIndex = 0
            cell.leftExpansion.fillOnTrigger = true
            cell.leftExpansion.threshold = 1
            
        }else if mode == .Edit{
            cell.rightButtons.removeAll()
            cell.leftButtons.removeAll()
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
        self.playlist_swiped = self.placeIDs[(indexPath?.row)!]
        let business = playlistArray[indexPath!.row]
        let actions = PlaceActions()
        let pickerController = CZPickerViewController()
        if self.mode == ListMode.View{
            if index == 0{
                if direction == MGSwipeDirection.LeftToRight{
                    PlaceActions.openInMaps(business)
                }else if direction == MGSwipeDirection.RightToLeft{
                    let query = PFQuery(className: "Playlists")
                    query.whereKey("createdBy", equalTo: PFUser.currentUser()!)
                    query.findObjectsInBackgroundWithBlock({ (object, error) in
                        if (error == nil) {
                            self.addToOwnPlaylists = object!
                            var user_array = [String]()
                            dispatch_async(dispatch_get_main_queue(), {
                                for playlist in object! {
                                    user_array.append(playlist["playlistName"] as! String)
                                }
                                pickerController.fruits = user_array
                                pickerController.headerTitle = "Playlists To Add To"
                                pickerController.showWithMultipleSelections(UIViewController)
                                pickerController.delegate = self
                            })
                        }
                    })
                }
                
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
            let routeButton = cell.leftButtons.first as! MGSwipeButton
            let addButton = cell.rightButtons[0] as! MGSwipeButton
            if cell.swipeState.rawValue == 2{
                routeButton.backgroundColor = appDefaults.color
                addButton.backgroundColor = UIColor(netHex: 0x27a915)
            }
            else if cell.swipeState.rawValue >= 4{
                addButton.backgroundColor = UIColor(netHex: 0x27a915)
                routeButton.backgroundColor = appDefaults.color
                cell.swipeBackgroundColor = appDefaults.color
            }
            
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showBusinessDetail", sender: self)
        
    }
    
    // Override to support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.playlistTableView.setEditing(editing, animated: animated)
    }
    
    func convertPlacesArrayToDictionary(placesArray: [Business])-> [NSDictionary]{
        var placeDictArray = [NSDictionary]()
        for business in placesArray{
            placeDictArray.append(business.getDictionary())
        }
        return placeDictArray
    }
    
    func addComment() {
       
    }
    
    func saveComments(comment: NSDictionary) {
        var current_comment = object["comment"] as! [NSDictionary]
        current_comment.insert(comment, atIndex: 0)
        object["comment"] = current_comment
        object.saveInBackgroundWithBlock { (success, error) in
            if (error == nil) {
                print("Saved comments")
            }
        }
    }
    
    // MARK: - SAVE PLAYLIST
    func savePlaylistToParse(sender: UIBarButtonItem)
    {
        self.deactivateEditMode()
        
        let saveobject = object
        
        Async.main{
            // Save Background Image
            if self.customImage != nil{
                let imageData: NSData! = UIImageJPEGRepresentation(self.customImage, 1.0)
                
                let fileName = self.playlistInfoName.text
                
                let imageFile: PFFile! = PFFile(name: fileName, data: imageData)
                do{ try imageFile.save() }catch{}
                
                saveobject["custom_bg"] = imageFile
            }
            
            // Saves List Name
            saveobject["playlistName"] = self.playlistInfoName.text
            
            if self.placeIDs.count > 0{
                
                // Save Location of First Object
                if let lat = self.playlistArray[0].businessLatitude
                {
                    if let long = self.playlistArray[0].businessLongitude
                    {
                        saveobject["location"] = PFGeoPoint(latitude: lat, longitude: long)
                    }
                }
                
                // Saves Number of Places
                saveobject["num_places"] = self.placeIDs.count
                
                
                // Saves Average Price
                self.getAveragePrice({ (avg) in
                    saveobject["average_price"] = avg
                })
                
                
                // Saves Businesses to Parse as [String] Ids
                saveobject["place_id_list"] = self.placeIDs
            }
        
        }.utility{
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
            print(index)
            
            // IF NO NEW PLACE IS ADDED
            if placeArray[index].name != ""{
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
        }else if (segue.identifier == "tapImageButton"){
            let nav = segue.destinationViewController as! UINavigationController
            let upcoming = nav.childViewControllers[0] as! SearchBusinessViewController
            upcoming.currentView = .AddPlace
            upcoming.searchTextField = upcoming.addPlaceSearchTextField
        }
        else if (segue.identifier == "addComment") {
            dim(.In, alpha: dimLevel, speed: dimSpeed)
        }
    }
}
