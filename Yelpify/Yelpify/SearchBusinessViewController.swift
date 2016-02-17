//
//  SearchBusinessViewController.swift
//  Yelpify
//
//  Created by Jonathan Lam on 2/15/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import CoreLocation

class SearchBusinessViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var location: String = "San Francisco"
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBAction func didEnterNewLocation(sender: AnyObject) {
        location = locationTextField.text!
        let parameters = ["location": location, "category_filter": "pizza", "radius_filter": "3000", "sort": "0"]
        performYelpSearch(parameters)
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let parameters = ["ll": findCurrentLocation(), "category_filter": "pizza", "radius_filter": "3000", "sort": "0"]
        
        performYelpSearch(parameters)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    //hello world
    

    func performYelpSearch(parameters: Dictionary<String, String>){
        let client = YelpAPIClient()
        
        client.searchPlacesWithParameters(parameters, successSearch: {
            (data, response) -> Void in
            //print(NSString(data: data, encoding: NSUTF8StringEncoding)!)
            print(client.extractData(data))
            
            }, failureSearch: { (error) -> Void in
                print(error)
        })

    }
    
    func findCurrentLocation() -> String{
        // GET LOCATION OF USER
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        dispatch_async(dispatch_get_main_queue(), {
            self.locationManager.startUpdatingLocation()
        })
        
        let lat = String(self.locationManager.location!.coordinate.latitude)
        let long = String(self.locationManager.location!.coordinate.longitude)
        
        let ll = lat + "," + long
        return ll
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let userLocation: CLLocation = locations[0]
//        
//        let latitude = userLocation.coordinate.latitude
//        let longitude = userLocation.coordinate.longitude
        
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
