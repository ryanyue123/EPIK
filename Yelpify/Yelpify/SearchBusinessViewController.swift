//
//  SearchBusinessViewController.swift
//  Yelpify
//
//  Created by Jonathan Lam on 2/15/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import CoreLocation
import Haneke
import Parse
import DGElasticPullToRefresh
import XLPagerTabStrip
import MGSwipeTableCell
import CZPicker


enum CurrentView {
    case AddPlace
    case SearchPlace
}

class SearchBusinessViewController: UIViewController, CLLocationManagerDelegate, IndicatorInfoProvider, UITextFieldDelegate, MGSwipeTableCellDelegate, ModalViewControllerDelegate, Dimmable{
    var addToOwnPlaylists: [PFObject]!
    var itemInfo: IndicatorInfo = "Places"
    var playlist_swiped: String!
    var itemReceived: Array<AnyObject> = []
    // MARK: - GLOBAL VARIABLES
    var googlePlacesClient = GooglePlacesAPIClient()
    var customSearchController: CustomSearchController!
    let cache = Shared.imageCache
    var dataHandler = APIDataHandler()
    var locationManager = CLLocationManager()
    var googleParameters = ["key": "AIzaSyDkxzICx5QqztP8ARvq9z0DxNOF_1Em8Qc", "location":"", "rankby":"distance", "keyword": "food"]
    var searchDidChange = false
    var searchQuery = ""
    var currentCity = ""
    
    var locationUpdated = false
    
    var currentView: CurrentView = .SearchPlace

    var searchTextField: UITextField!

    
    // MARK: - TABLEVIEW VARIABLES
    private var businessObjects: [Business] = []
    private var businessShown: [Bool] = []
    
    // Parse variables
    private var index: NSIndexPath!
    var placeIDs = [String]()
    var businessArray = [Business]()
    var newPlacesArray = [GooglePlaceDetail]()
    
    // MARK: - TABLEVIEW FUNCTIONS
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addPlaceSearchTextField: UITextField!
    
    // MARK: - OUTLETS
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    private let dimLevel: CGFloat = 0.8
    private let dimSpeed: Double = 0.5
    
    @IBAction func unwindToSearchBusinessVC(segue: UIStoryboardSegue) {
        if (segue.identifier != nil)
        {
            if segue.identifier == "unwindFromDetail"{
                let bdVC = segue.sourceViewController as! BusinessDetailViewController
                let indexp = bdVC.index
                self.addTrackToPlaylist(indexp)
            }else if segue.identifier == "unwindToSearchCancel"{
                print("unwindToSearchCancel")
                if let pagerTabVC = self.parentViewController as? SearchPagerTabStrip{
                    UIView.animateWithDuration(0.2, animations: {
                        pagerTabVC.navigationController?.navigationBar.alpha = 1
                    })
                    pagerTabVC.dim(.Out, alpha: dimLevel, speed: dimSpeed)
                }else{
                    UIView.animateWithDuration(0.2, animations: {
                        self.navigationController?.navigationBar.alpha = 1
                    })
                    dim(.Out, alpha: dimLevel, speed: dimSpeed)
                }
            }
        }

    }
    
    @IBAction func unwindToSearchBusinessVCWithSearch(segue: UIStoryboardSegue) {
        if (segue.identifier != nil) {
            if segue.identifier == "unwindToSearch" {
                if let pagerTabVC = self.parentViewController as? SearchPagerTabStrip{
                    UIView.animateWithDuration(0.2, animations: {
                        pagerTabVC.navigationController?.navigationBar.alpha = 1
                    })
                    pagerTabVC.dim(.Out, alpha: dimLevel, speed: dimSpeed)
                }else{
                    UIView.animateWithDuration(0.2, animations: {
                        self.navigationController?.navigationBar.alpha = 1
                    })
                    dim(.Out, alpha: dimLevel, speed: dimSpeed)
                }

                let locationVC = segue.sourceViewController as! LocationSearchViewController
                self.googleParameters["location"] = locationVC.currentLocationCoordinates
                self.currentCity = locationVC.currentCity
                if searchQuery != ""{
                    self.searchWithKeyword(searchQuery)
                }else{
                    searchQuery = "food"
                    self.searchWithKeyword(searchQuery)
                }
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
                
//                print("unwinded from locationSearchVC")
//                
//                let gPlacesVC = segue.sourceViewController as! LocationSearchViewController
//                if let searchVC = self.parentViewController as? SearchPagerTabStrip{
//                
//                    searchVC.chosenCoordinates = gPlacesVC.currentLocationCoordinates
//                    
//                    self.googleParameters["location"] = searchVC.chosenCoordinates
//                    
//                    self.searchWithKeyword(searchQuery)
//                    self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
//                    
//                    // CHANGE
//                }else{
//                    self.googleParameters["location"] = gPlacesVC.currentLocationCoordinates
//                    self.currentCity = gPlacesVC.currentCity
//                    self.searchWithKeyword(searchQuery)
//                    self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
//                
//                }
            }
        }
    }
    
    
    @IBOutlet weak var navBarTitleLabel: UINavigationItem!
    @IBOutlet weak var locationTextField: UITextField!
    
    
    func searchWithKeyword(keyword: String){
        googleParameters["keyword"] = keyword
        
        self.businessShown.removeAll()
        self.businessObjects.removeAll()
        cache.removeAll()
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
        }
        
        print("grabbing new data")
        dataHandler.performAPISearch(googleParameters) { (businessObjectArray) -> Void in
            for _ in businessObjectArray{
                self.businessShown.append(false)
            }
            self.businessObjects = businessObjectArray
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
        }

    }
    
    // MARK: - DATA TASKS
    func getLocationAndSearch(){
        DataFunctions.getLocation { (coordinates) in
            self.googleParameters["location"] = "\(coordinates.latitude),\(coordinates.longitude)"
            self.performInitialSearch()
            self.placeIDs.removeAll()
        }

    }
    
    func firstDictFromDict(dict: NSDictionary) -> NSDictionary{
        let key = dict.allKeys[0] as! String
        return dict[key] as! NSDictionary
    }
    
    func performInitialSearch(){
        dataHandler.performAPISearch(googleParameters) { (businessObjectArray) -> Void in
            self.businessObjects = businessObjectArray
            for _ in businessObjectArray{
                self.businessShown.append(false)
            }
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
        }
    }
    
    
    // MGSwipeTableCell Delegate Methods
    
    func swipeTableCell(cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection) -> Bool {
        return true
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "showBusinessDetail"){
            let cache = Shared.dataCache
            
            let upcoming: BusinessDetailViewController = segue.destinationViewController as! BusinessDetailViewController
            
            let indexPath = tableView.indexPathForSelectedRow
            let object = businessObjects[indexPath!.row]
            upcoming.fromSearchTab = true
            upcoming.object = object
            upcoming.index = indexPath!.row
            self.tableView.deselectRowAtIndexPath(indexPath!, animated: true)
        }else if (segue.identifier == "pickLocation"){
            
            // CHANGE
            let navController = segue.destinationViewController as! UINavigationController
            let upcoming = navController.topViewController as! LocationSearchViewController
            
            // Pass the location
            upcoming.currentLocationCoordinates = googleParameters["location"]
            upcoming.currentCity = self.currentCity
            
            print(currentCity)
            if self.currentCity != ""{
                upcoming.mainSearchTextField?.text = self.currentCity
            }
        }
    }
    
    // This one is added through the button in cell
    func addTrackToPlaylist(button: UIButton)
    {
    
        // If button already pressed
        if button.tintColor == UIColor.greenColor(){
            button.tintColor = appDefaults.color_darker
            print("removed")
            let index = button.tag
            let indexToRemove = self.placeIDs.indexOf(businessObjects[index].gPlaceID)
            print(indexToRemove)
            placeIDs.removeAtIndex(indexToRemove!)
            businessArray.removeAtIndex(indexToRemove!)
        }else{
            button.tintColor = UIColor.greenColor()
            print("pressed")
            let index = button.tag
            placeIDs.append(businessObjects[index].gPlaceID)
            businessArray.append(businessObjects[index])
            print(businessArray)
            
        }
    }
    func sendValue(value: AnyObject){
        itemReceived.append(value as! NSObject)
        
        for item in itemReceived{
            
            
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
            
            itemReceived = []
        }
        
        
    }
    
    // This one is added through DetailedVC
    
    // CHANGE
    func addTrackToPlaylist(indx: Int!)
    {
        print("Added Business at Index", String(indx))
        placeIDs.append(businessObjects[indx].gPlaceID)
        businessArray.append(businessObjects[indx])
        print(placeIDs)
    }
    
    func addTrackToPlaylistFromTap(sender: UIGestureRecognizer){
        let index = sender.view!.tag
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! BusinessTableViewCell
        
        let button = cell.moreButton
        
        if button.tintColor == UIColor.greenColor(){
            button.tintColor = appDefaults.color_darker
            print("removed")
            let index = button.tag
            let indexToRemove = self.placeIDs.indexOf(businessObjects[index].gPlaceID)
            print(indexToRemove)
            placeIDs.removeAtIndex(indexToRemove!)
            businessArray.removeAtIndex(indexToRemove!)
        }else{
            button.tintColor = UIColor.greenColor()
            print("pressed")
            let index = button.tag
            placeIDs.append(businessObjects[index].gPlaceID)
            businessArray.append(businessObjects[index])
            print(businessArray)
            
        }
        
        
        print(placeIDs)
    }
    
    
    func textFieldDidChange(textField: UITextField){
        print("hi")
    }

    // MARK: - VIEWDIDLOAD
    
    override func viewDidAppear(animated: Bool) {

        self.navigationController?.resetNavigationBar(1)
        
        if ((self.parentViewController as? SearchPagerTabStrip) == nil){
            let rightButton = UIBarButtonItem(image: UIImage(named: "location_icon"), style: .Plain, target: self, action: "pressedLocation:")
            
            navigationItem.rightBarButtonItem = rightButton
        }
        
        
        if searchTextField != nil{
            searchTextField.placeholder = "Search for Places"
            searchTextField.delegate = self
            self.tableView.reloadData()
        }
    }

    
    override func viewDidLoad(){
        
        // Get Location and Perform Search
        self.getLocationAndSearch()
        
        if self.navigationController?.navigationBar.backgroundColor != appDefaults.color{
            // Configure Functions
           self.navigationController!.configureTopBar()
        }

        self.tableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
        // Register Nibs
        self.tableView.registerNib(UINib(nibName: "BusinessCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "businessCell")
    }
    
    func pressedLocation(sender: UIBarButtonItem){
        if let _ = self.parentViewController as? SearchPagerTabStrip{
            performSegueWithIdentifier("pickLocation", sender: self)
        }else{
            dim(.In, alpha: dimLevel, speed: dimSpeed)
            self.navigationController?.navigationBar.alpha = 0.5
            performSegueWithIdentifier("pickLocation", sender: self)
        }
    }
    
    func pressedCancel(sender:UIBarButtonItem){
        addPlaceSearchTextField.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    func configureCustomSearchController() {
        customSearchController = CustomSearchController(searchResultsController: self, searchBarFrame: CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 50.0), searchBarFont: UIFont(name: "Futura", size: 16.0)!, searchBarTextColor: UIColor.orangeColor(), searchBarTintColor: UIColor.blackColor())
        
        customSearchController.customSearchBar.placeholder = "Search in this awesome bar..."
        self.tableView.tableHeaderView = customSearchController.customSearchBar
    }
    func configureSwipeButtons(cell: MGSwipeTableCell){
        
        let routeButton = MGSwipeButton(title: "ROUTE", icon: UIImage(named: "swipe_route"),backgroundColor: appDefaults.color, padding: 25)
        routeButton.setEdgeInsets(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 15))
        routeButton.centerIconOverText()
        routeButton.titleLabel?.font = appDefaults.font
        
        let addButton = MGSwipeButton(title: "ADD", icon: UIImage(named: "swipe_add"),backgroundColor: UIColor.greenColor(), padding: 25)
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
    }
    
    func swipeTableCell(cell: MGSwipeTableCell!, tappedButtonAtIndex index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        let indexPath = tableView.indexPathForCell(cell)
        
        //self.playlist_swiped = self.businessObjects[indexPath!.row].gPlaceID
        //self.playlist_swiped = self.placeIDs[(indexPath?.row)!]
        let business = businessObjects[indexPath!.row]
        self.playlist_swiped = business.gPlaceID
        //let actions = PlaceActions()
        let pickerController = CZPickerViewController()
        
        
        if direction == MGSwipeDirection.LeftToRight{
            print("swipelefttoright")
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
        return true
        }
    func swipeTableCell(cell: MGSwipeTableCell!, didChangeSwipeState state: MGSwipeState, gestureIsActive: Bool) {
        print(gestureIsActive)
        let routeButton = cell.leftButtons.first as! MGSwipeButton
        let addButton = cell.rightButtons[0] as! MGSwipeButton
        if cell.swipeState.rawValue == 2{
            routeButton.backgroundColor = appDefaults.color
            addButton.backgroundColor = UIColor(netHex: 0x27a915)
        }
        else if cell.swipeState.rawValue >= 4{
            addButton.backgroundColor = UIColor(netHex: 0x27a915)
            routeButton.backgroundColor = appDefaults.color
            //cell.swipeBackgroundColor = appDefaults.color
            }
            
        }
        
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        self.resignFirstResponder()
        // This will close the keyboard when touched outside.
    }
    
    func textFieldShouldReturn(textField:UITextField) -> Bool {
        searchQuery = textField.text!
        searchWithKeyword(searchQuery)
        textField.text = searchQuery
//        if currentCity != ""{
//            let longString = textField.text! + " NEAR " + currentCity.uppercaseString
//            let longestWord = " NEAR " + currentCity.uppercaseString
//            
//            let longestWordRange = (longString as NSString).rangeOfString(longestWord)
//            
//            let attributedString = NSMutableAttributedString(string: longString, attributes: [NSFontAttributeName : appDefaults.font.fontWithSize(14)])
//            
//            attributedString.setAttributes([NSFontAttributeName : appDefaults.font.fontWithSize(9), NSForegroundColorAttributeName : appDefaults.color_darker
//                ], range: longestWordRange)
//            
//            
//            textField.attributedText = attributedString
//            //textField.text! += " NEAR " + currentCity.uppercaseString
//        }
        textField.resignFirstResponder() //close keyboard
        return true
        // Will allow user to press "return" button to close keyboard
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain , target: self, action: "pressedCancel:")
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let rightButton = UIBarButtonItem(image: UIImage(named: "location_icon"), style: .Plain, target: self, action: "pressedLocation:")
        
//        if currentCity != ""{
//            let longString = textField.text! + " NEAR " + currentCity.uppercaseString
//            let longestWord = " NEAR " + currentCity.uppercaseString
//            
//            let longestWordRange = (longString as NSString).rangeOfString(longestWord)
//            
//            let attributedString = NSMutableAttributedString(string: longString, attributes: [NSFontAttributeName : appDefaults.font.fontWithSize(14)])
//            
//            attributedString.setAttributes([NSFontAttributeName : appDefaults.font.fontWithSize(9), NSForegroundColorAttributeName : appDefaults.color_darker
//                ], range: longestWordRange)
//            
//            
//            textField.attributedText = attributedString
//            //textField.text! += " NEAR " + currentCity.uppercaseString
//        }

        
        navigationItem.rightBarButtonItem = rightButton

    }


}

extension SearchBusinessViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.whiteColor()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businessObjects.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 128.5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("businessCell", forIndexPath: indexPath) as! BusinessTableViewCell
        cell.delegate = self
        cell.tag = indexPath.row
        
        configureSwipeButtons(cell)
        
        if self.currentView == .SearchPlace{
            cell.actionButton.hidden = true
        }else{
            cell.actionButton.hidden = false
        }
        
        let business = self.businessObjects[indexPath.row]
        
        cell.configureCellWith(business, mode: .Add) { (place) -> Void in
            
        }
        
        cell.moreButton.tag = indexPath.row
        cell.moreButton.addTarget(self, action: "addTrackToPlaylist:", forControlEvents: .TouchUpInside)
        
        let tappedGestureRec = UITapGestureRecognizer(target: self, action: "addTrackToPlaylistFromTap:")
        cell.actionButtonView.addGestureRecognizer(tappedGestureRec)
        cell.actionButtonView.tag = indexPath.row
        
        return cell
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showBusinessDetail", sender: self)
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        let cell  = tableView.cellForRowAtIndexPath(indexPath) as! BusinessTableViewCell
        cell.mainView.backgroundColor = UIColor.selectedGray()
        cell.businessBackgroundImage.alpha = 0.8
        cell.BusinessRating.backgroundColor = UIColor.selectedGray()
    }
    
    func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        let cell  = tableView.cellForRowAtIndexPath(indexPath) as! BusinessTableViewCell
        cell.mainView.backgroundColor = UIColor.whiteColor()
        cell.businessBackgroundImage.alpha = 1
        cell.BusinessRating.backgroundColor = UIColor.clearColor()
    }
    
    
    
}

