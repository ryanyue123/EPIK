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

class SearchBusinessViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // MARK: - GLOBAL VARIABLES
    var yelpClient = YelpAPIClient()
    var locuClient = LocuAPIClient()
    var googlePlacesClient = GooglePlacesAPIClient()
    
    var dataHandler = APIDataHandler()
    
    var locationManager = CLLocationManager()
    var searchParameters = ["ll": "", "category_filter": "pizza", "radius_filter": "10000", "sort": "0"]
    var yelpSearchParameters = [
        "ll": "33.64496794563093,-117.83725295740864",
        "term": "pizza",
        "radius_filter": "10000",
        "sort": "1"]

    var locuSearchParameters = []
    
    // MARK: - OUTLETS
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBAction func didFinishEditingLocation(sender: AnyObject) {
        locationTextField.resignFirstResponder()
        let query = locationTextField.text
        //let queryArr = query!.characters.split{$0 == " "}.map(String.init)
        yelpSearchParameters["term"] = query as String!
        
        self.businessObjects.removeAll()
        self.tableView.reloadData()
        
        dataHandler.performAPISearch(yelpSearchParameters) { (businessObjectArray) -> Void in
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
        
        searchParameters["ll"] = String(latitude) + "," + String(longitude)
        print(String(latitude) + "," + String(longitude))
    }
    func firstDictFromDict(dict: NSDictionary) -> NSDictionary{
        let key = dict.allKeys[0] as! String
        return dict[key] as! NSDictionary
    }
    
    
    // MARK: - TABLEVIEW VARIABLES
    var businesses: [NSDictionary] = []
    var businessObjects: [Business] = []
    
    var index: NSIndexPath!
    var object: PFObject!
    var playlistObject:PFObject!
    var playlistArray = [String]()
    var geopoint:PFGeoPoint!
    var businessShown: [Bool] = []

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
        //cell.tag = indexPath.row
        
        let business = self.businessObjects[indexPath.row]
        cell.configureCellWith(business)
        
        cell.addToPlaylist.tag = indexPath.row
        cell.addToPlaylist.addTarget(self, action: "addTrackToPlaylist:", forControlEvents: .TouchUpInside)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showBusinessDetail", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let upcoming: BusinessDetailViewController = segue.destinationViewController as! BusinessDetailViewController
        
        if (segue.identifier == "showBusinessDetail")
        {
            let indexPath = tableView.indexPathForSelectedRow
            let object = businessObjects[indexPath!.row]
            upcoming.object = object
            self.tableView.deselectRowAtIndexPath(indexPath!, animated: true)
        }
    }
    
    func addTrackToPlaylist(button: UIButton)
    {
        print("pressed")
        let index = button.tag
        let object = businessObjects[index]
        if (geopoint == nil)
        {
            geopoint = PFGeoPoint(latitude: object.businessLatitude, longitude: object.businessLongitude)
        }
        playlistArray.append(object.businessName)
    }
        
    @IBAction func finishedAddingToPlaylist(sender: UIBarButtonItem) {
        playlistObject = PFObject(className: "Playlists")
        playlistObject["playlist"] = playlistArray
        playlistObject["createdBy"] = PFUser.currentUser()?.username
        playlistObject["location"] = geopoint
        playlistObject.saveEventually {(success, error) -> Void in
            if (error == nil)
            {
                
            }
            else
            {
                print(error?.userInfo)
            }
        }
    }

    
    // MARK: - VIEWDIDLOAD
    
    override func viewDidLoad(){
        
        locationTextField.delegate = self
        //getCurrentLocation()
        
        // Performs an API search and returns a master array of businesses (as dictionaries)
        dataHandler.performAPISearch(yelpSearchParameters) { (businessObjectArray) -> Void in
            self.businessObjects = businessObjectArray
            for _ in businessObjectArray{
                self.businessShown.append(false)
            }
            
            for business in self.businessObjects{
                print(business.businessName)
            }
            self.tableView.reloadData()
        }
        geopoint = nil
        playlistArray.removeAll()
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

