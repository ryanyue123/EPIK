//
//  TableViewController.swift
//  Yelpify
//
//  Created by Ryan Yue on 4/9/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import ParseUI
import Parse
import CoreLocation
import MapKit
import SwiftLocation

struct playlist
{
    static var playlistname: String!
}

struct appDefaults {
    static let color: UIColor! = UIColor.init(netHex: 0x52abc0)
}

class TableViewController: UITableViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, CLLocationManagerDelegate {
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        
        self.getLocationAndFetch()
        
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.requestLocation()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        ConfigureFunctions.configureNavigationBar(self.navigationController!, outterView: self.view)
        ConfigureFunctions.configureStatusBar(self.navigationController!)

    }
    
    override func viewDidAppear(animated: Bool) {

        
        if (PFUser.currentUser() == nil) {
            let logInViewController = PFLogInViewController()
            logInViewController.delegate = self
            
            let signUpViewController = PFSignUpViewController()
            signUpViewController.delegate = self
            
            logInViewController.signUpController = signUpViewController
            
            self.presentViewController(logInViewController, animated: true, completion: nil)
            
            
        }
    }
    
    func configureStatusBar(navController: UINavigationController){
        let statusBarRect = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 20.0)
        let statusBarView = UIView(frame: statusBarRect)
        statusBarView.backgroundColor = appDefaults.color
        navController.view.addSubview(statusBarView)
    }
    
    func configureNavBar(){
        self.navigationController?.navigationBar.backgroundColor = appDefaults.color
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
    }
    
    //var locationManager = CLLocationManager()
    //let client = YelpAPIClient()
    var parameters = ["ll": "", "category_filter": "pizza", "radius_filter": "3000", "sort": "0"]
    var playlists_location = []
    var playlists_user = []
    var recent_playlists = []
    var all_playlists = [NSArray]()
    var label_array = ["Playlists Near You", "My Playlists", "Recently Viewed"]
    var row: Int!
    var col: Int!
    var userlatitude: Double!
    var userlongitude: Double!
    var inputTextField: UITextField!
    
    @IBAction func showPlaylistAlert(sender: UIBarButtonItem) {
        print("hello")
        let alertController = UIAlertController(title: "Create new playlist", message: "Enter name of playlist.", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Playlist Name"
            textField.secureTextEntry = false
            self.inputTextField = textField
        })
        let deleteAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive, handler: {(alert :UIAlertAction!) in
            self.view.endEditing(true)
            print("Delete button tapped")
        })
        alertController.addAction(deleteAction)
        let okAction = UIAlertAction(title: "Enter", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
            let query = PFQuery(className: "Playlists")
            query.whereKey("createdbyuser", equalTo: (PFUser.currentUser()?.username!)!)
            query.whereKey("playlistName", equalTo: self.inputTextField.text!)
            query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
                if ((error) == nil)
                {
                    dispatch_async(dispatch_get_main_queue(), {
                        if (objects!.count == 0)
                        {
                            playlist.playlistname = self.inputTextField.text!
                            self.performSegueWithIdentifier("createPlaylist", sender: self)
                        }
                        else
                        {
                            print("You have already created this playlist")
                        }
                    })
                }
                else
                {
                    print(error?.description)
                }
            }
        })
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func getLocationAndFetch(){
        // SwiftLocation
        do {
            try SwiftLocation.shared.currentLocation(Accuracy.Neighborhood, timeout: 20, onSuccess: { (location) -> Void in
                // location is a CLPlacemark
                self.userlatitude = location?.coordinate.latitude
                self.userlongitude = location?.coordinate.longitude
                
                self.fetchPlaylists()
                
                self.parameters["ll"] = String(self.userlatitude) + "," + String(self.userlongitude)
                
                print("1. Location found \(location?.description)")
            }) { (error) -> Void in
                print("1. Something went wrong -> \(error?.localizedDescription)")
            }
        } catch (let error) {
            print("Error \(error)")
        }
    }

    func fetchPlaylists()
    {
        let query:PFQuery = PFQuery(className: "Playlists")
        query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: userlatitude, longitude: userlongitude), withinMiles: 1000000000.0)
        query.orderByAscending("location")
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
            if ((error) == nil)
            {
                dispatch_async(dispatch_get_main_queue(), {
                    self.playlists_location = objects!
                    self.all_playlists.append(self.playlists_location)
                    self.tableView.reloadData()
                    
                    let query2: PFQuery = PFQuery(className: "Playlists")
                    query2.whereKey("createdbyuser", equalTo: (PFUser.currentUser()?.username)!)
                    query2.orderByDescending("updatedAt")
                    query2.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
                        if ((error) == nil)
                        {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.playlists_user = objects!
                                self.all_playlists.append(self.playlists_user)
                                self.tableView.reloadData()
                                
                                let query3 = PFUser.query()!
                                query3.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
                                print((PFUser.currentUser()?.username)!)
                                query3.findObjectsInBackgroundWithBlock {(objects1: [PFObject]?, error: NSError?) -> Void in
                                    if ((error) == nil)
                                    {
                                        print(objects1)
                                        dispatch_async(dispatch_get_main_queue(), {
                                            let recentarray = objects1![0]["recentlyViewed"] as! [String]
                                            let query4 = PFQuery(className: "Playlists")
                                            query4.whereKey("objectId", containedIn: recentarray)
                                            query4.findObjectsInBackgroundWithBlock {(objects2: [PFObject]?, error: NSError?) -> Void in
                                                if ((error) == nil)
                                                {
                                                    dispatch_async(dispatch_get_main_queue(), {
                                                        self.recent_playlists = objects2!
                                                        self.all_playlists.append(self.recent_playlists)
                                                        self.tableView.reloadData()
                                                    })
                                                }
                                            }
                                        })
                                    }
                                }
                            })
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

//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let userLocation: CLLocation = locations[0]
//        
//        let latitude = userLocation.coordinate.latitude
//        let longitude = userLocation.coordinate.longitude
//        print(userLocation.coordinate)
//        userlatitude = latitude
//        userlongitude = longitude
//        
//        
//        fetchPlaylists()
//        
//        parameters["ll"] = String(latitude) + "," + String(longitude)
//    }
//    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
//        print(error.description)
//    }
//    
//    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
//        if status == .AuthorizedWhenInUse
//        {
//            //print("Authorized")
//        }
//    }
    
    func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
        if (!username.isEmpty || !password.isEmpty)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        print("failed to login")
    }
    func signUpViewController(signUpController: PFSignUpViewController, shouldBeginSignUp info: [String : String]) -> Bool {
        if let password = info["password"]
        {
            return password.utf16.count >= 8
        }
        else
        {
            return false
        }
    }
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func signUpViewController(signUpController: PFSignUpViewController, didFailToSignUpWithError error: NSError?) {
        print("failed to signup")
    }
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController) {
        print("signup canceled")
    }

    // MARK: - Table view data source
    var storedOffsets = [Int: CGFloat]()
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.all_playlists.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TableViewCell
        cell.reloadCollectionView()
        cell.titleLabel.text = label_array[indexPath.row]
        cell.titleLabel.textColor = appDefaults.color
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let tableViewCell = cell as? TableViewCell else{return}
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath:NSIndexPath) {
        
        guard let tableViewCell = cell as? TableViewCell else { return }
        
        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
}

extension TableViewController: UICollectionViewDataSource, UICollectionViewDelegate
{
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return all_playlists[collectionView.tag].count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CollectionViewCell
        let tempobject = all_playlists[collectionView.tag][indexPath.row] as! PFObject
        cell.label.text = tempobject["playlistName"] as? String
    
        //takes image of first business and uses it as icon for playlist
        
        if let business = tempobject["track"] as? [NSDictionary]{
            let businessdict = business[0]
            let photoref = businessdict["photoReference"] as! String
            cell.configureCell(photoref)
        }
        return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.row = collectionView.tag
        self.col = indexPath.row
        
        // Perform Segue and Pass List Data
        let controller = storyboard!.instantiateViewControllerWithIdentifier("singlePlaylistVC") as! SinglePlaylistViewController
        let temparray = all_playlists[indexPath.row]
        controller.object = temparray[indexPath.row] as! PFObject
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if (segue.identifier == "showPlaylist")
//        {
//            let upcoming = segue.destinationViewController as? SinglePlaylistViewController
//            let temparray = all_playlists[row]
//            
//            let navController: UINavigationController = self.navigationController!
//            upcoming?.object = temparray[col] as! PFObject
//        }
    }
}
