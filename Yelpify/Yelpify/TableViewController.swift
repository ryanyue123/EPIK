//
//  TableViewController.swift
//  Yelpify
//
//  Created by Ryan Yue on 4/9/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import Parse
import CoreLocation
import MapKit
import DGElasticPullToRefresh
import SwiftLocation

struct playlist
{
    static var playlistname: String!
}

struct appDefaults {
    static let color: UIColor! = UIColor.init(netHex: 0x52abc0)
    static let color_bg: UIColor! = UIColor.init(netHex: 0xe4e4e4)
    static let color_darker: UIColor! = UIColor.init(netHex: 0x3a7b8a)
}

class TableViewController: UITableViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var darkOverlay: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getLocationAndFetch()
        self.configureColors()
        self.configureHeaderView()
        
        // Test code, to be placed into functions in the future
        self.title = "EPIK"
        let leftButton =  UIBarButtonItem(title: "Search", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        let rightButton = UIBarButtonItem(title: "New", style: UIBarButtonItemStyle.Plain, target: self, action: "showPlaylistAlert:")
        
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton
        
        
        
        // Pull to Refresh
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.whiteColor()
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            // Add your logic here
            print("refreshing")
            self?.all_playlists.removeAll()
            self?.getLocationAndFetch()
            // Do not forget to call dg_stopLoading() at the end
            self?.tableView.dg_stopLoading()
            }, loadingView: loadingView)
        tableView.dg_setPullToRefreshFillColor(appDefaults.color_darker)
        tableView.dg_setPullToRefreshBackgroundColor(appDefaults.color_darker)
        
    }
    
    deinit {
        tableView.dg_removePullToRefresh()
    }
    
    override func viewWillAppear(animated: Bool) {
        // Configure Views
        ConfigureFunctions.configureNavigationBar(self.navigationController!, outterView: self.view)
        ConfigureFunctions.configureStatusBar(self.navigationController!)
    }

    override func viewDidAppear(animated: Bool) {

        //configureHeaderView()
        self.tableView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateHeaderView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderView()
    }
    
    // MARK: - Configure Methods
    
    private let headerHeight: CGFloat = 200.0
    
    func configureHeaderView(){
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        tableView.contentInset = UIEdgeInsets(top: headerHeight, left: 0, bottom: 50, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -headerHeight)
    }
    
    func configureColors(){
        self.tableView.backgroundColor = appDefaults.color_bg
        self.view.backgroundColor = appDefaults.color_bg
    }
    
    func updateHeaderView(){
        var headerRect = CGRect(x: 0, y: -headerHeight, width: self.tableView.frame.size.width, height: headerHeight)
        
        if self.tableView.contentOffset.y < -headerHeight{
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
        }else if self.tableView.contentOffset.y > headerHeight{
        }
        
        headerView.frame = headerRect
    }
    
    // MARK: - Scroll View
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        self.fadeBG()
        self.updateHeaderView()
    }
    
    func fadeBG(){
        self.headerImageView.alpha = (-tableView.contentOffset.y / headerHeight) * 0.5
    }
    
    // end
    
    func addShadowToBar() {
        let shadowView = UIView(frame: self.navigationController!.navigationBar.frame)
        //shadowView.backgroundColor = appDefaults.color
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowOpacity = 0.7 // your opacity
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 3) // your offset
        shadowView.layer.shadowRadius =  10 //your radius
        self.view.addSubview(shadowView)
        self.view.bringSubviewToFront(shadowView)
        
        shadowView.tag = 102
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
    var label_array: [String] = []
    var row: Int!
    var col: Int!
    var userlatitude: Double!
    var userlongitude: Double!
    var inputTextField: UITextField!
    
    
    func showPlaylistAlert(sender: UIBarButtonItem) {
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
        LocationManager.shared.observeLocations(.Block, frequency: .OneShot, onSuccess: { location in
            self.userlatitude = location.coordinate.latitude
            self.userlongitude = location.coordinate.longitude

            self.fetchPlaylists()

            self.parameters["ll"] = String(self.userlatitude) + "," + String(self.userlongitude)

        }) { error in
            // Something went wrong. error will tell you what
        }
        self.userlatitude = 37.322998
        self.userlongitude = -122.032182
        self.parameters["ll"] = String(self.userlatitude) + "," + String(self.userlongitude)
//
//        // SwiftLocation
//        do {
//            try SwiftLocation.shared.currentLocation(Accuracy.Block, timeout: 20, onSuccess: { (location) -> Void in
//                // location is a CLPlacemark
//                self.userlatitude = location?.coordinate.latitude
//                self.userlongitude = location?.coordinate.longitude
//                
//                self.fetchPlaylists()
//                
//                self.parameters["ll"] = String(self.userlatitude) + "," + String(self.userlongitude)
//                
//                print("1. Location found \(location?.description)")
//            }) { (error) -> Void in
//                print("1. Something went wrong -> \(error?.localizedDescription)")
//            }
//        } catch (let error) {
//            print("Error \(error)")
//        }
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
                    self.label_array.append("Playlists near me")
                    self.tableView.reloadData()
                    
                    /*
                    let query2: PFQuery = PFQuery(className: "Playlists")
                    query2.whereKey("createdbyuser", equalTo: (PFUser.currentUser()?.username)!)
                    query2.orderByDescending("updatedAt")
                    query2.findObjectsInBackgroundWithBlock {(user: [PFObject]?, error: NSError?) -> Void in
                        if ((error) == nil)
                        {
                            dispatch_async(dispatch_get_main_queue(), {
                                if (user!.count != 0)
                                {
                                    self.playlists_user = user!
                                    self.all_playlists.append(self.playlists_user)
                                    self.label_array.append("My playlists")
                                    self.tableView.reloadData()
                                }
                                
                                let query3 = PFUser.query()!
                                query3.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
                                query3.findObjectsInBackgroundWithBlock {(objects1: [PFObject]?, error: NSError?) -> Void in
                                    if ((error) == nil)
                                    {
                                        dispatch_async(dispatch_get_main_queue(), {
                                            if let recentarray = objects1![0]["recentlyViewed"] as? [String]
                                            {
                                                let query4 = PFQuery(className: "Playlists")
                                                query4.whereKey("objectId", containedIn: recentarray)
                                                query4.findObjectsInBackgroundWithBlock {(objects2: [PFObject]?, error: NSError?) -> Void in
                                                    if ((error) == nil)
                                                    {
                                                        dispatch_async(dispatch_get_main_queue(), {
                                                            self.recent_playlists = objects2!
                                                            self.all_playlists.append(self.recent_playlists)
                                                            self.label_array.append("Recently viewed")
                                                            self.tableView.reloadData()
                                                        })
                                                    }
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
                    }*/

                })
            }
            else
            {
                print(error?.userInfo)
            }
        }
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
        cell.titleLabel.text = label_array[indexPath.row] as! String
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
            if let photoref = businessdict["photoReference"] as? String
            {
                cell.configureCell(photoref)
            }
        }
        
        return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //self.row = collectionView.tag
        //self.col = indexPath.row
        print(collectionView.tag)
        print(indexPath.row)
        // Perform Segue and Pass List Data
        let controller = storyboard!.instantiateViewControllerWithIdentifier("singlePlaylistVC") as! SinglePlaylistViewController
        let temparray = all_playlists[collectionView.tag]
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
    
    override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
        let segue = CustomUnwindSegue(identifier: identifier, source: fromViewController, destination: toViewController)
        segue.animationType = .Push
        return segue
    }
}
