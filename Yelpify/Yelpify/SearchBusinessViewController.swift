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

class SearchBusinessViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - GLOBAL VARIABLES
    var yelpClient = YelpAPIClient()
    var locuClient = LocuAPIClient()
    var googlePlacesClient = GooglePlacesAPIClient()
    
    var dataHandler = APIDataHandler()
    
    var locationManager = CLLocationManager()
    var searchParameters = ["ll": "", "category_filter": "pizza", "radius_filter": "10000", "sort": "0"]
    var locuSearchParameters = []
    
    // MARK: - OUTLETS
    @IBOutlet weak var locationTextField: UITextField!
    
    
    // MARK: - ACTIONS
    @IBAction func didEnterNewLocation(sender: AnyObject) {
        searchParameters["location"] = locationTextField.text!
        //searchBusinesses()
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
    var businessObjects: [Business]!
    var index: NSIndexPath!
    var object: PFObject!
    var playlistObject:PFObject!
    var playlistArray = [String]()
    var geopoint:PFGeoPoint!
    var businessShown: [Bool] = []

    var yelpSearchParameters = [
        "ll": "33.64496794563093,-117.83725295740864",
        "term": "pizza",
        "radius_filter": "10000",
        "sort": "1"]
    
    // MARK: - TABLEVIEW FUNCTIONS

    @IBOutlet weak var addToPlaylist: UIButton!
    @IBOutlet weak var tableView: UITableView!

    func updateImages(cell: BusinessTableViewCell, indexPath: NSIndexPath, business: Business){
        
        let photoReference = business.businessPhotoReference
        
        googlePlacesClient.getImageFromPhotoReference(photoReference, completion: { (photo, error) -> Void in
            
            if error != nil {
                print(error)
                cell.businessBackgroundImage.image = UIImage(named: "restaurantImage - InNOut")
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if(cell.tag == indexPath.row) {
                    cell.businessBackgroundImage.image = photo
                    cell.setNeedsLayout() // need to reload the view, which won't happen otherwise since this is in an async call
                }
            })
        })

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businesses.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "businessCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! BusinessTableViewCell
        cell.tag = indexPath.row
        
        if businessShown[indexPath.row] != true{
            if self.businessObjects.count >= indexPath.row{
                let business = self.businessObjects[indexPath.row]
                print(business, "\n")
                
                //let photoReference = business.businessPhotoReference
                
                cell.businessTitleLabel.text = business.businessName
                updateImages(cell, indexPath: indexPath, business: business)

            }
            businessShown[indexPath.row] = true
        }
        
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
        //getCurrentLocation()
        
        
        // Performs an API search and returns a master array of businesses (as dictionaries)
        dataHandler.performAPISearch(yelpSearchParameters) { (masterBusinessArray, masterBusinessObjArray) -> Void in
            self.businesses = masterBusinessArray as! [NSDictionary]
            self.businessObjects = masterBusinessObjArray
            for _ in masterBusinessObjArray{
                self.businessShown.append(false)
            }
            //self.tableView.reloadData()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
        
        geopoint = nil
        playlistArray.removeAll()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

