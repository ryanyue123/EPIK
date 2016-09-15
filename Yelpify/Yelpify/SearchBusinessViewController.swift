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
    case addPlace
    case searchPlace
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
    
    var currentView: CurrentView = .searchPlace

    var searchTextField: UITextField!

    
    // MARK: - TABLEVIEW VARIABLES
    fileprivate var businessObjects: [Business] = []
    fileprivate var businessShown: [Bool] = []
    
    // Parse variables
    fileprivate var index: IndexPath!
    var placeIDs = [String]()
    var businessArray = [Business]()
    var newPlacesArray = [GooglePlaceDetail]()
    
    // MARK: - TABLEVIEW FUNCTIONS
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addPlaceSearchTextField: UITextField!
    
    // MARK: - OUTLETS
    
    func indicatorInfoForPagerTabStrip(_ pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    fileprivate let dimLevel: CGFloat = 0.8
    fileprivate let dimSpeed: Double = 0.5
    
    @IBAction func unwindToSearchBusinessVC(_ segue: UIStoryboardSegue) {
        if (segue.identifier != nil)
        {
            if segue.identifier == "unwindFromDetail"{
                let bdVC = segue.source as! BusinessDetailViewController
                let indexp = bdVC.index
                self.addTrackToPlaylist(indexp)
            }else if segue.identifier == "unwindToSearchCancel"{
                print("unwindToSearchCancel")
                if let pagerTabVC = self.parent as? SearchPagerTabStrip{
                    UIView.animateWithDuration(0.2, animations: {
                        pagerTabVC.navigationController?.navigationBar.alpha = 1
                    })
                    pagerTabVC.dim(.Out, alpha: dimLevel, speed: dimSpeed)
                }else{
                    UIView.animate(withDuration: 0.2, animations: {
                        self.navigationController?.navigationBar.alpha = 1
                    })
                    dim(.out, alpha: dimLevel, speed: dimSpeed)
                }
            }
        }

    }
    
    @IBAction func unwindToSearchBusinessVCWithSearch(_ segue: UIStoryboardSegue) {
        if (segue.identifier != nil) {
            if segue.identifier == "unwindToSearch" {
                if let pagerTabVC = self.parent as? SearchPagerTabStrip{
                    UIView.animateWithDuration(0.2, animations: {
                        pagerTabVC.navigationController?.navigationBar.alpha = 1
                    })
                    pagerTabVC.dim(.Out, alpha: dimLevel, speed: dimSpeed)
                }else{
                    UIView.animate(withDuration: 0.2, animations: {
                        self.navigationController?.navigationBar.alpha = 1
                    })
                    dim(.out, alpha: dimLevel, speed: dimSpeed)
                }

                let locationVC = segue.source as! LocationSearchViewController
                self.googleParameters["location"] = locationVC.currentLocationCoordinates
                self.currentCity = locationVC.currentCity
                if searchQuery != ""{
                    self.searchWithKeyword(searchQuery)
                }else{
                    searchQuery = "food"
                    self.searchWithKeyword(searchQuery)
                }
                self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
                
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
    
    
    func searchWithKeyword(_ keyword: String){
        googleParameters["keyword"] = keyword
        
        self.businessShown.removeAll()
        self.businessObjects.removeAll()
        cache.removeAll()
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
        }
        
        print("grabbing new data")
        dataHandler.performAPISearch(googleParameters) { (businessObjectArray) -> Void in
            for _ in businessObjectArray{
                self.businessShown.append(false)
            }
            self.businessObjects = businessObjectArray
            self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
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
    
    func firstDictFromDict(_ dict: NSDictionary) -> NSDictionary{
        let key = dict.allKeys[0] as! String
        return dict[key] as! NSDictionary
    }
    
    func performInitialSearch(){
        dataHandler.performAPISearch(googleParameters) { (businessObjectArray) -> Void in
            self.businessObjects = businessObjectArray
            for _ in businessObjectArray{
                self.businessShown.append(false)
            }
            self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
        }
    }
    
    
    // MGSwipeTableCell Delegate Methods
    
    func swipeTableCell(_ cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection) -> Bool {
        return true
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "showBusinessDetail"){
            let cache = Shared.dataCache
            
            let upcoming: BusinessDetailViewController = segue.destination as! BusinessDetailViewController
            
            let indexPath = tableView.indexPathForSelectedRow
            let object = businessObjects[(indexPath! as NSIndexPath).row]
            upcoming.fromSearchTab = true
            upcoming.object = object
            upcoming.index = (indexPath! as NSIndexPath).row
            self.tableView.deselectRow(at: indexPath!, animated: true)
        }else if (segue.identifier == "pickLocation"){
            
            // CHANGE
            let navController = segue.destination as! UINavigationController
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
    func addTrackToPlaylist(_ button: UIButton)
    {
    
        // If button already pressed
        if button.tintColor == UIColor.green{
            button.tintColor = appDefaults.color_darker
            print("removed")
            let index = button.tag
            let indexToRemove = self.placeIDs.index(of: businessObjects[index].gPlaceID)
            print(indexToRemove)
            placeIDs.remove(at: indexToRemove!)
            businessArray.remove(at: indexToRemove!)
        }else{
            button.tintColor = UIColor.green
            print("pressed")
            let index = button.tag
            placeIDs.append(businessObjects[index].gPlaceID)
            businessArray.append(businessObjects[index])
            print(businessArray)
            
        }
    }
    func sendValue(_ value: AnyObject){
        itemReceived.append(value as! NSObject)
        
        for item in itemReceived{
            
            
            let index = item as! Int
            var playlist = addToOwnPlaylists[index]["place_id_list"] as! [String]
            print(playlist)
            playlist.append(self.playlist_swiped)
            print(playlist)
            
            addToOwnPlaylists[index]["num_places"] = playlist.count
            addToOwnPlaylists[index]["place_id_list"] = playlist
            addToOwnPlaylists[index].saveInBackground(block: { (success, error) in
                if (error == nil) {
                    print("Saved")
                    }
                })
            
            itemReceived = []
        }
        
        
    }
    
    // This one is added through DetailedVC
    
    // CHANGE
    func addTrackToPlaylist(_ indx: Int!)
    {
        print("Added Business at Index", String(indx))
        placeIDs.append(businessObjects[indx].gPlaceID)
        businessArray.append(businessObjects[indx])
        print(placeIDs)
    }
    
    func addTrackToPlaylistFromTap(_ sender: UIGestureRecognizer){
        let index = sender.view!.tag
        let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as! BusinessTableViewCell
        
        let button = cell.moreButton
        
        if button?.tintColor == UIColor.green{
            button?.tintColor = appDefaults.color_darker
            print("removed")
            let index = button?.tag
            let indexToRemove = self.placeIDs.index(of: businessObjects[index!].gPlaceID)
            print(indexToRemove)
            placeIDs.remove(at: indexToRemove!)
            businessArray.remove(at: indexToRemove!)
        }else{
            button?.tintColor = UIColor.green
            print("pressed")
            let index = button?.tag
            placeIDs.append(businessObjects[index!].gPlaceID)
            businessArray.append(businessObjects[index!])
            print(businessArray)
            
        }
        
        
        print(placeIDs)
    }
    
    
    func textFieldDidChange(_ textField: UITextField){
        print("hi")
    }

    // MARK: - VIEWDIDLOAD
    
    override func viewDidAppear(_ animated: Bool) {

        self.navigationController?.resetNavigationBar(1)
        
        if ((self.parent as? SearchPagerTabStrip) == nil){
            let rightButton = UIBarButtonItem(image: UIImage(named: "location_icon"), style: .plain, target: self, action: #selector(SearchBusinessViewController.pressedLocation(_:)))
            
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
        self.tableView.register(UINib(nibName: "BusinessCell", bundle: Bundle.main), forCellReuseIdentifier: "businessCell")
    }
    
    func pressedLocation(_ sender: UIBarButtonItem){
        if let _ = self.parent as? SearchPagerTabStrip{
            performSegue(withIdentifier: "pickLocation", sender: self)
        }else{
            dim(.in, alpha: dimLevel, speed: dimSpeed)
            self.navigationController?.navigationBar.alpha = 0.5
            performSegue(withIdentifier: "pickLocation", sender: self)
        }
    }
    
    func pressedCancel(_ sender:UIBarButtonItem){
        addPlaceSearchTextField.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    func configureCustomSearchController() {
        customSearchController = CustomSearchController(searchResultsController: self, searchBarFrame: CGRect(x: 0.0, y: 0.0, width: self.tableView.frame.size.width, height: 50.0), searchBarFont: UIFont(name: "Futura", size: 16.0)!, searchBarTextColor: UIColor.orange, searchBarTintColor: UIColor.black)
        
        customSearchController.customSearchBar.placeholder = "Search in this awesome bar..."
        self.tableView.tableHeaderView = customSearchController.customSearchBar
    }
    func configureSwipeButtons(_ cell: MGSwipeTableCell){
        
        let routeButton = MGSwipeButton(title: "ROUTE", icon: UIImage(named: "swipe_route"),backgroundColor: appDefaults.color, padding: 25)
        routeButton?.setEdgeInsets(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 15))
        routeButton?.centerIconOverText()
        routeButton?.titleLabel?.font = appDefaults.font
        
        let addButton = MGSwipeButton(title: "ADD", icon: UIImage(named: "swipe_add"),backgroundColor: UIColor.green, padding: 25)
        addButton?.setEdgeInsets(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 15))
        addButton?.centerIconOverText()
        addButton?.titleLabel?.font = appDefaults.font
        
        
        cell.rightButtons = [addButton]
        cell.rightSwipeSettings.transition = MGSwipeTransition.clipCenter
        cell.rightExpansion.buttonIndex = 0
        cell.rightExpansion.fillOnTrigger = false
        cell.rightExpansion.threshold = 1
        
        cell.leftButtons = [routeButton]
        cell.leftSwipeSettings.transition = MGSwipeTransition.clipCenter
        cell.leftExpansion.buttonIndex = 0
        cell.leftExpansion.fillOnTrigger = true
        cell.leftExpansion.threshold = 1
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell!, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        let indexPath = tableView.indexPath(for: cell)
        
        //self.playlist_swiped = self.businessObjects[indexPath!.row].gPlaceID
        //self.playlist_swiped = self.placeIDs[(indexPath?.row)!]
        let business = businessObjects[(indexPath! as NSIndexPath).row]
        self.playlist_swiped = business.gPlaceID
        //let actions = PlaceActions()
        let pickerController = CZPickerViewController()
        
        
        if direction == MGSwipeDirection.leftToRight{
            print("swipelefttoright")
            PlaceActions.openInMaps(business)
        }else if direction == MGSwipeDirection.rightToLeft{
            let query = PFQuery(className: "Playlists")
            query.whereKey("createdBy", equalTo: PFUser.current()!)
            query.findObjectsInBackground(block: { (object, error) in
                if (error == nil) {
                    self.addToOwnPlaylists = object!
                    var user_array = [String]()
                    DispatchQueue.main.async(execute: {
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
    func swipeTableCell(_ cell: MGSwipeTableCell!, didChange state: MGSwipeState, gestureIsActive: Bool) {
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        self.resignFirstResponder()
        // This will close the keyboard when touched outside.
    }
    
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain , target: self, action: #selector(SearchBusinessViewController.pressedCancel(_:)))
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let rightButton = UIBarButtonItem(image: UIImage(named: "location_icon"), style: .plain, target: self, action: #selector(SearchBusinessViewController.pressedLocation(_:)))
        
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.white
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businessObjects.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128.5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "businessCell", for: indexPath) as! BusinessTableViewCell
        cell.delegate = self
        cell.tag = (indexPath as NSIndexPath).row
        
        configureSwipeButtons(cell)
        
        if self.currentView == .searchPlace{
            cell.actionButton.isHidden = true
        }else{
            cell.actionButton.isHidden = false
        }
        
        let business = self.businessObjects[(indexPath as NSIndexPath).row]
        
        cell.configureCellWith(business, mode: .add) { (place) -> Void in
            
        }
        
        cell.moreButton.tag = (indexPath as NSIndexPath).row
        cell.moreButton.addTarget(self, action: #selector(SearchBusinessViewController.addTrackToPlaylist(_:) as (SearchBusinessViewController) -> (UIButton) -> ()), for: .touchUpInside)
        
        let tappedGestureRec = UITapGestureRecognizer(target: self, action: #selector(SearchBusinessViewController.addTrackToPlaylistFromTap(_:)))
        cell.actionButtonView.addGestureRecognizer(tappedGestureRec)
        cell.actionButtonView.tag = (indexPath as NSIndexPath).row
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showBusinessDetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell  = tableView.cellForRow(at: indexPath) as! BusinessTableViewCell
        cell.mainView.backgroundColor = UIColor.selectedGray()
        cell.businessBackgroundImage.alpha = 0.8
        cell.BusinessRating.backgroundColor = UIColor.selectedGray()
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell  = tableView.cellForRow(at: indexPath) as! BusinessTableViewCell
        cell.mainView.backgroundColor = UIColor.white
        cell.businessBackgroundImage.alpha = 1
        cell.BusinessRating.backgroundColor = UIColor.clearColor()
    }
    
    
    
}

