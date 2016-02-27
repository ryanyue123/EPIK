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
        //searchBusinesses()
    }
    
    func firstDictFromDict(dict: NSDictionary) -> NSDictionary{
        let key = dict.allKeys[0] as! String
        return dict[key] as! NSDictionary
    }
    
    
    // MARK: - TABLEVIEW VARIABLES
    
    var businesses: [NSDictionary] = []
    var index: NSIndexPath!
    var playlistObject:PFObject!
    var playlistArray = [String]()
    
    var yelpSearchParameters = [
        "ll": "33.64496794563093,-117.83725295740864",
        "term": "pizza",
        "radius_filter": "10000",
        "sort": "1"]
    
    var gPlacesParameters = [
        "key" : "AIzaSyAZ1KUrHPxY36keuRlZ4Yu6ZMBNhyLcgfs",
        "keyword": "pizza",
        "location" : "33.64496794563093,-117.83725295740864",
        //"radius" : "50000", // DO NOT USE RADIUS IF RANKBY = DISTANCE
        "rankby": "distance"
        //"query" : "pizza"
    ]
    
    // MARK: - TABLEVIEW FUNCTIONS
    
    @IBOutlet weak var addToPlaylist: UIButton!
    @IBOutlet weak var tableView: UITableView!

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businesses.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "businessCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! BusinessTableViewCell
    
        let outerBusinessDict = businesses[indexPath.row]
        let businessDict = self.firstDictFromDict(outerBusinessDict)
        
        let photoReference = businessDict["photoReference"] as! String
        
        cell.businessTitleLabel.text = businessDict["name"] as! String
        
        googlePlacesClient.getImageFromPhotoReference(photoReference, completion: { (photo) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                cell.businessBackgroundImage.image = photo
            })
            //self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        })
        
        
//        // Fetches the appropriate business for the data source layout.
//        let business = businesses[indexPath.row]
//        
//        cell.businessTitleLabel.text = business.businessName
//        self.updateImages(cell, indexPath: indexPath, business: business)
        
        //cell.businessBackgroundImage.image = downloadImage(business.businessImageURL)
        // self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        
        cell.addToPlaylist.tag = indexPath.row
        cell.addToPlaylist.addTarget(self, action: "addTrackToPlaylist:", forControlEvents: .TouchUpInside)
        return cell
    }
    func addTrackToPlaylist(button: UIButton)
    {
        print("pressed")
        let index = button.tag
        //let object = businesses[index].businessName
        //playlistArray.append(object)
    }
        
    @IBAction func finishedAddingToPlaylist(sender: UIBarButtonItem) {
        playlistObject = PFObject(className: (PFUser.currentUser()?.username)!)
        playlistObject["Playlist"] = playlistArray
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
        getCurrentLocation()
        
        // Performs an API search and returns a master array of businesses (as dictionaries)
        dataHandler.performAPISearch(yelpSearchParameters, gpParameters: gPlacesParameters) { (masterBusinessArray) -> Void in
            self.businesses = masterBusinessArray
            self.tableView.reloadData()
        }
        
        playlistObject = PFObject(className: (PFUser.currentUser()?.username)!)
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

