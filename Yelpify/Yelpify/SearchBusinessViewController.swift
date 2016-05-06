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

class SearchBusinessViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, IndicatorInfoProvider, UITextFieldDelegate  {
    
    var itemInfo: IndicatorInfo = "Places"
    
    // MARK: - GLOBAL VARIABLES
    //var yelpClient = YelpAPIClient()
    //var locuClient = LocuAPIClient()
    var googlePlacesClient = GooglePlacesAPIClient()
    var customSearchController: CustomSearchController!
    let cache = Shared.imageCache
    var dataHandler = APIDataHandler()
    var locationManager = CLLocationManager()
    var googleParameters = ["key": "AIzaSyDkxzICx5QqztP8ARvq9z0DxNOF_1Em8Qc", "location": "33.6450038818185,-117.837313786366", "rankby":"distance", "keyword": "food"]
    var searchDidChange = false
    var searchQuery = ""
    
    var searchTextField: UITextField!
    
    // MARK: - OUTLETS
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    @IBAction func searchWithGPlaces(sender: AnyObject) {
    }
    
    
    @IBAction func unwindToSearchBusinessVC(segue: UIStoryboardSegue) {
        if (segue.identifier != nil)
        {
            if segue.identifier == "unwindFromDetail"{
                let bdVC = segue.sourceViewController as! BusinessDetailViewController
                let indexp = bdVC.index
                addTrackToPlaylist(indexp)
            }
        }

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
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
        
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
    var businessObjects: [Business] = []
    var businessShown: [Bool] = []

    // Parse variables
    var index: NSIndexPath!
    var playlistArray = [Business]()

    // MARK: - TABLEVIEW FUNCTIONS

    @IBOutlet weak var tableView: UITableView!
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.whiteColor()
    }
    
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
        
        cell.configureCellWith(business, mode: .Add) { () -> Void in
        }
        cell.moreButton.tag = indexPath.row
        cell.moreButton.addTarget(self, action: "addTrackToPlaylist:", forControlEvents: .TouchUpInside)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showBusinessDetail", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "showBusinessDetail"){
            let cache = Shared.dataCache
            
            let upcoming: BusinessDetailViewController = segue.destinationViewController as! BusinessDetailViewController
            
            let indexPath = tableView.indexPathForSelectedRow
            let object = businessObjects[indexPath!.row]
            upcoming.object = object
            upcoming.index = indexPath!.row
            self.tableView.deselectRowAtIndexPath(indexPath!, animated: true)
        }else if (segue.identifier == "presentGPlacesVC"){
            
            let navController = segue.destinationViewController as! UINavigationController
            let upcoming = navController.topViewController as! GPlacesSearchViewController
            
            if self.navigationItem.title != "Around You"{
                upcoming.searchQuery = self.navigationItem.title
            }
            
            // Pass the location
            upcoming.currentLocationCoordinates = googleParameters["location"]
        }
    }
    
    func addTrackToPlaylist(button: UIButton)
    {
        button.tintColor = UIColor.greenColor()
        print("pressed")
        let index = button.tag
        playlistArray.append(businessObjects[index])
       
    }
    
    
    func addTrackToPlaylist(indx: Int!)
    {
        print("Added Business at Index", String(indx))
        playlistArray.append(businessObjects[indx])
    }
    
    func textFieldDidChange(textField: UITextField){
        print("hi")
    }
    
    
    


    // MARK: - VIEWDIDLOAD
    
    override func viewDidAppear(animated: Bool) {
        if searchTextField != nil{
            searchTextField.delegate = self
        }
    }

    
    override func viewDidLoad(){
        //getCurrentLocation()
        ConfigureFunctions.configureStatusBar(self.navigationController!)
        ConfigureFunctions.configureNavigationBar(self.navigationController!, outterView: self.view)
        
        // Register Nibs
        self.tableView.registerNib(UINib(nibName: "BusinessCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "businessCell")
        
//        // Set up Nav Bar
//        self.navigationController?.navigationBar.backgroundColor = appDefaults.color
//        self.navigationController?.navigationItem.titleView?.tintColor = UIColor.whiteColor()
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        
        // Performs an API search and returns a master array of businesses (as dictionaries)
        performInitialSearch()
        playlistArray.removeAll()
        
//        // Pull to Refresh
//        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
//        loadingView.tintColor = UIColor.whiteColor()
//        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
//            // Add your logic here
//            print("refreshing")
//            self?.tableView.reloadData()
//            // Do not forget to call dg_stopLoading() at the end
//            self?.tableView.dg_stopLoading()
//            }, loadingView: loadingView)
//        tableView.dg_setPullToRefreshFillColor(appDefaults.color_darker)
//        tableView.dg_setPullToRefreshBackgroundColor(appDefaults.color_darker)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.navigationController?.navigationBar.alpha = 1
        self.navigationController?.navigationBar.backgroundColor = appDefaults.color
        self.navigationItem.titleView?.alpha = 1
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
        print("olleh")
        textField.resignFirstResponder() //close keyboard
        return true
        // Will allow user to press "return" button to close keyboard
    }


}
