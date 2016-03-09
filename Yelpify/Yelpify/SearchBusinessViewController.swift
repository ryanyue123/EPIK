//
//  SearchBusinessViewController.swift
//  Yelpify
//
//  Created by Jonathan Lam on 2/15/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import CoreLocation
import Parse
import Haneke

class SearchBusinessViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - GLOBAL VARIABLES
    var yelpClient = YelpAPIClient()
    var locuClient = LocuAPIClient()
    var googlePlacesClient = GooglePlacesAPIClient()
    
    var customSearchController: CustomSearchController!
    
    let cache = Shared.imageCache
    
    var dataHandler = APIDataHandler()
    
    var locationManager = CLLocationManager()
//    var searchParameters = ["ll": "", "category_filter": "pizza", "radius_filter": "10000", "sort": "0"]
//    var yelpSearchParameters = [
//        "ll": "33.64496794563093,-117.83725295740864",
//        "term": "tacos",
//        "radius_filter": "10000",
//        "sort": "1"]
    
    var googleParameters = ["key": "AIzaSyDkxzICx5QqztP8ARvq9z0DxNOF_1Em8Qc", "location": "33.64496794563093,-117.83725295740864", "rankby":"distance", "keyword": ""]
    
    var searchDidChange = false
    var searchQuery = ""

    //var locuSearchParameters = []
    
    // MARK: - OUTLETS
    
    @IBAction func searchWithGPlaces(sender: AnyObject) {
    }
    
    
    @IBAction func unwindToSearchBusinessVC(sender: UIStoryboardSegue) {

    }
    
    @IBAction func unwindToSearchBusinessVCWithSearch(segue: UIStoryboardSegue) {
        if (segue.identifier != nil) {
            if segue.identifier == "unwindToSearch" {
                
                let gPlacesVC = segue.sourceViewController as! GPlacesSearchViewController
                
                if let searchQuery = gPlacesVC.searchQuery{
                    if searchQuery != ""{
                        self.navigationItem.title = searchQuery
                    }else{
                        self.navigationItem.title = "Around You"
                    }
                    searchWithKeyword(searchQuery)
                    
                }
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
        self.tableView.reloadData()
        
        print("grabbing new data")
        dataHandler.performAPISearch(googleParameters) { (businessObjectArray) -> Void in
            for _ in businessObjectArray{
                self.businessShown.append(false)
            }
            self.businessObjects = businessObjectArray
            self.tableView.reloadData()
        }

    }
    
    // MARK: - DATA TASKS
    func getCurrentLocation(){
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.description)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse
        {
            print("Authorized")
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        //searchParameters["ll"] = String(latitude) + "," + String(longitude)
        print(String(latitude) + "," + String(longitude))
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
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - TABLEVIEW VARIABLES
    var businesses: [NSDictionary] = []
    var businessObjects: [Business] = []
    var businessShown: [Bool] = []

    // Parse variables
    var index: NSIndexPath!
    var object: PFObject!
    var playlistArray = [NSDictionary]()
    var geopoint:PFGeoPoint!

    // MARK: - TABLEVIEW FUNCTIONS

    @IBOutlet weak var addToPlaylist: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businessObjects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("businessCell", forIndexPath: indexPath) as! BusinessTableViewCell
        cell.tag = indexPath.row
        
        let business = self.businessObjects[indexPath.row]
        
        cell.configureCellWith(business) { () -> Void in
            //print("reloading cell", indexPath.row)
            //self.businessShown[indexPath.row] = true
            //self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
        }
//        
//        if !businessShown.contains(false){
//            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//            businessShown[indexPath.row] = true
//        }
//        
        cell.addToPlaylist.tag = indexPath.row
        cell.addToPlaylist.addTarget(self, action: "addTrackToPlaylist:", forControlEvents: .TouchUpInside)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showBusinessDetail", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "showBusinessDetail"){
            let upcoming: BusinessDetailViewController = segue.destinationViewController as! BusinessDetailViewController
            let indexPath = tableView.indexPathForSelectedRow
            let object = businessObjects[indexPath!.row]
            upcoming.object = object
            self.tableView.deselectRowAtIndexPath(indexPath!, animated: true)
        }else if (segue.identifier == "presentGPlacesVC"){
            
            let navController = segue.destinationViewController as! UINavigationController
            let upcoming = navController.topViewController as! GPlacesSearchViewController
            
            if self.navigationItem.title != "Around You"{
                upcoming.searchQuery = self.navigationItem.title
            }
        }
    }
    
    func addTrackToPlaylist(button: UIButton)
    {
        print("pressed")
        let index = button.tag
        let object = businessObjects[index]
        print(object.businessName)
        print(object.businessAddress)
        if (geopoint == nil)
        {
            geopoint = PFGeoPoint(latitude: object.businessLatitude!, longitude: object.businessLongitude!)
        }
        let arraydict = ["name": object.businessName!, "address": object.businessAddress!, "google-id": object.gPlaceID!] // Yelp ID not in use -> "yelp-id": object.yelpID!]
        playlistArray.append(arraydict)
       
    }
    
    @IBAction func finishedEditingPlaylist(sender: UIBarButtonItem) {
        let query = PFQuery(className: "Playlists")
        query.whereKey("createdbyuser", equalTo: (PFUser.currentUser()?.username)!)
        query.whereKey("playlistName", equalTo: playlist.playlistname)
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
            if ((error) == nil)
            {
                dispatch_async(dispatch_get_main_queue(), {
                    print(objects)
                    let playlistObject = objects![0]
                    playlistObject["track"] = self.playlistArray
                    if (self.geopoint != nil)
                    {
                        playlistObject["location"] = self.geopoint
                    }
                    playlistObject.saveInBackgroundWithBlock {(success, error) -> Void in
                        if (error == nil)
                        {
                            print("hello")
                        }
                        else
                        {
                            print(error?.userInfo)
                        }
                    }
                })
            }
            else
            {
                print(error?.userInfo)
            }
        }
    }

    // MARK: - VIEWDIDLOAD
    
    override func viewDidLoad(){
        //getCurrentLocation()
        //self.navigationController?.navigationBar.set
        
        // Performs an API search and returns a master array of businesses (as dictionaries)
        performInitialSearch()
//        geopoint = nil
//        playlistArray.removeAll()
    }
    
    func configureCustomSearchController() {
        customSearchController = CustomSearchController(searchResultsController: self, searchBarFrame: CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 50.0), searchBarFont: UIFont(name: "Futura", size: 16.0)!, searchBarTextColor: UIColor.orangeColor(), searchBarTintColor: UIColor.blackColor())
        
        customSearchController.customSearchBar.placeholder = "Search in this awesome bar..."
        self.tableView.tableHeaderView = customSearchController.customSearchBar
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        // This will close the keyboard when touched outside.
    }
    
    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder() //close keyboard
        return true
        // Will allow user to press "return" button to close keyboard
    }
    
//    func textFieldDidEndEditing(textField: UITextField) {
//        let query = locationTextField.text
//        //let queryArr = query!.characters.split{$0 == " "}.map(String.init)
//        //yelpSearchParameters["term"] = query as String!
//        
//        self.businessObjects.removeAll()
//        self.tableView.reloadData()
//        
////        dataHandler.performAPISearch(yelpSearchParameters) { (businessObjectArray) -> Void in
////            self.businessObjects = businessObjectArray
////            self.tableView.reloadData()
////        }
//        
//    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
