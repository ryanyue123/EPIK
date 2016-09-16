////
////  HomeViewController.swift
////  Yelpify
////
////  Created by Ryan Yue on 4/9/16.
////  Copyright © 2016 Yelpify. All rights reserved.
////
//
import UIKit
//import Parse
//import Async
//
//struct playlist
//{
//    static var playlistname: String!
//}
//
struct sharedVariables{
    static var currentCoordinates = ""
}

struct appDefaults {
    static let font: UIFont! = UIFont(name: "Montserrat-Regular", size: 14)
    static let color: UIColor! = UIColor.init(netHex: 0x52abc0)
    static let color_bg: UIColor! = UIColor.init(netHex: 0xe4e4e4)
    static let color_darker: UIColor! = UIColor.init(netHex: 0x3a7b8a)
    
}
//
//class HomeViewController: UITableViewController, CLLocationManagerDelegate {
//    
//    @IBOutlet weak var tableViewImage: UIImageView!
//    @IBOutlet weak var tableViewDescrip: UILabel!
//    @IBOutlet weak var tableViewTitle: UILabel!
//    @IBOutlet weak var headerView: UIView!
//    @IBOutlet weak var headerImageView: UIImageView!
//    @IBOutlet weak var darkOverlay: UIView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.navigationController?.configureTopBar()
//        // Get Location and Fetch
//        DataFunctions.getLocation { (coordinates) in
//            sharedVariables.currentCoordinates = String(coordinates.latitude) + "," + String(coordinates.longitude)
//            self.parameters["ll"] = String(coordinates.latitude) + "," + String(coordinates.longitude)
//            self.userlatitude = coordinates.latitude
//            self.userlongitude = coordinates.longitude
//            self.fetchPlaylists()
//        }
//        self.configureColors()
//        self.configureHeaderView()
//        
//        // Add Items to Nav Bar
//        self.addNavBarItems()
//        
//        // Pull to Refresh
//        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
//        loadingView.tintColor = UIColor.whiteColor()
//        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
//            // Add your logic here
//            print("refreshing")
//            self?.all_playlists.removeAll()
//            self!.fetchPlaylists()
//            // Do not forget to call dg_stopLoading() at the end
//            self?.tableView.dg_stopLoading()
//            }, loadingView: loadingView)
//        tableView.dg_setPullToRefreshFillColor(appDefaults.color_darker)
//        tableView.dg_setPullToRefreshBackgroundColor(appDefaults.color_darker)
//        
//    }
//    
//    deinit {
//        tableView.dg_removePullToRefresh()
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        self.navigationController?.navigationBar.titleTextAttributes = [
//            NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(1) ]
//        //self.tableView.reloadData()
//        self.navigationController?.navigationBar.backgroundColor = appDefaults.color.withAlphaComponent(1)
//        self.addNavBarItems()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        // Configure Views
//    }
//    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        updateHeaderView()
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        updateHeaderView()
//    }
//    
//    func addNavBarItems(){
//        self.title = "EPIK"
//        let leftButton = UIBarButtonItem(image: UIImage(named: "updates_icon"), style: .plain, target: self, action: nil)
//        let rightButton = UIBarButtonItem(image: UIImage(named: "new_list_icon"), style: .plain, target: self, action: #selector(HomeViewController.showPlaylistAlert(_:)))
//        navigationItem.leftBarButtonItem = leftButton
//        navigationItem.rightBarButtonItem = rightButton
//    }
//    
//    // MARK: - Configure Methods
//    
//    fileprivate let headerHeight: CGFloat = 150.0
//    
//    func configureHeaderView(){
//        tableView.tableHeaderView = nil
//        tableView.addSubview(headerView)
//        tableView.contentInset = UIEdgeInsets(top: headerHeight, left: 0, bottom: 50, right: 0)
//        tableView.contentOffset = CGPoint(x: 0, y: -headerHeight)
//    }
//    
//    func configureColors(){
//        self.tableView.backgroundColor = appDefaults.color_bg
//        self.view.backgroundColor = appDefaults.color_bg
//    }
//    
//    func updateHeaderView(){
//        var headerRect = CGRect(x: 0, y: -headerHeight, width: self.tableView.frame.size.width, height: headerHeight)
//        
//        if self.tableView.contentOffset.y < -headerHeight{
//            headerRect.origin.y = tableView.contentOffset.y
//            headerRect.size.height = -tableView.contentOffset.y
//        }else if self.tableView.contentOffset.y > headerHeight{
//        }
//        
//        headerView.frame = headerRect
//    }
//    
//    // MARK: - Scroll View
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        self.fadeBG()
//        self.updateHeaderView()
//        
//        
//    }
//    
//    func configureCarousel(){
//        self.tableViewImage.image = UIImage(named:"bucket")
//        self.tableViewTitle.text = "Discover Irvine"
//        self.tableViewDescrip.text = "A specially curated list created for you."
//    }
//    
//    func fadeBG(){
//        self.headerImageView.alpha = (-tableView.contentOffset.y / headerHeight) * 0.5
//    }
//    
//    // end
//    
//    func addShadowToBar() {
//        let shadowView = UIView(frame: self.navigationController!.navigationBar.frame)
//        //shadowView.backgroundColor = appDefaults.color
//        shadowView.layer.masksToBounds = false
//        shadowView.layer.shadowOpacity = 0.7 // your opacity
//        shadowView.layer.shadowOffset = CGSize(width: 0, height: 3) // your offset
//        shadowView.layer.shadowRadius =  10 //your radius
//        self.view.addSubview(shadowView)
//        self.view.bringSubview(toFront: shadowView)
//        
//        shadowView.tag = 102
//    }
//    
//    
//    func configureStatusBar(_ navController: UINavigationController){
//        let statusBarRect = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 20.0)
//        let statusBarView = UIView(frame: statusBarRect)
//        statusBarView.backgroundColor = appDefaults.color
//        navController.view.addSubview(statusBarView)
//    }
//    
//    func configureNavBar(){
//        self.navigationController?.navigationBar.backgroundColor = appDefaults.color
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//    }
//    
//    //var locationManager = CLLocationManager()
//    //let client = YelpAPIClient()
//    var parameters = ["ll": "", "category_filter": "pizza", "radius_filter": "3000", "sort": "0"]
//    var playlists_location = []
//    var playlists_user = []
//    var recent_playlists = []
//    var all_playlists = [NSArray]()
//    var label_array: [String] = []
//    var row: Int!
//    var col: Int!
//    var userlatitude: Double!
//    var userlongitude: Double!
//    var inputTextField: UITextField!
//    
//    
//    func showPlaylistAlert(_ sender: UIBarButtonItem) {
//        let alertController = UIAlertController(title: "Create new playlist", message: "Enter name of playlist.", preferredStyle: UIAlertControllerStyle.alert)
//        
//        alertController.addTextField(configurationHandler: {(textField: UITextField!) in
//            textField.placeholder = "Playlist Name"
//            textField.isSecureTextEntry = false
//            self.inputTextField = textField
//        })
//        let deleteAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: {(alert :UIAlertAction!) in
//            self.view.endEditing(true)
//            print("Delete button tapped")
//        })
//        alertController.addAction(deleteAction)
//        let okAction = UIAlertAction(title: "Enter", style: UIAlertActionStyle.default, handler: {(alert :UIAlertAction!) in
//            if (!(self.inputTextField.text?.isEmpty)!) {
//                let query = PFQuery(className: "Playlists")
//                query.whereKey("createdBy", equalTo: PFUser.current()!)
//                query.whereKey("playlistName", equalTo: self.inputTextField.text!)
//                query.findObjectsInBackground {(objects: [PFObject]?, error: NSError?) -> Void in
//                    if ((error) == nil)
//                    {
//                        Async.main{
//                            if (objects!.count == 0)
//                            {
//                                let object = PFObject(className: "Playlists")
//                                object["playlistName"] = self.inputTextField.text!
//                                object["search_name"] = self.inputTextField.text!.uppercaseString
//                                object["createdBy"] = PFUser.currentUser()!
//                                object["place_id_list"] = []
//                                object["Collaborators"] = []
//                                object["comment"] = []
//                                object["comments"] = []
//                                object["average_price"] = 0
//                                object["num_places"] = 0
//                                object.saveInBackgroundWithBlock({ (success, error) in
//                                    if(error == nil)
//                                    {
//                                        let control = self.storyboard!.instantiateViewControllerWithIdentifier("singlePlaylistVC") as! SinglePlaylistViewController
//                                        control.object = object
//                                        control.editable = true
//                                        self.navigationController!.pushViewController(control, animated: true)
//                                    }
//                                })
//                            }
//                            else
//                            {
//                                print("You have already created this playlist")
//                            }
//
//                        } // End Async.main
//                    }
//                    else
//                    {
//                        print(error?.description)
//                    }
//                }
//            }
//        })
//        alertController.addAction(okAction)
//        present(alertController, animated: true, completion: nil)
//    }
//    
//
//    func fetchPlaylists()
//    {
//        self.all_playlists.removeAll()
//        self.label_array.removeAll()
//        let query:PFQuery = PFQuery(className: "Playlists")
//        query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: userlatitude, longitude: userlongitude), withinMiles: 1000000000.0)
//        query.order(byAscending: "location")
//        query.findObjectsInBackground {(objects: [PFObject]?, error: NSError?) -> Void in
//            if ((error) == nil)
//            {
//                
//                DispatchQueue.main.async(execute: {
//                    self.playlists_location = objects!
//                    self.all_playlists.append(self.playlists_location)
//                    self.label_array.append("Trending Lists")
//                    self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
//                    //self.tableView.reloadData()
//                    
//                    let query2: PFQuery = PFQuery(className: "Playlists")
//                    query2.whereKey("createdBy", equalTo: PFUser.current()!)
//                    query2.order(byDescending: "updatedAt")
//                    query2.findObjectsInBackground {(user: [PFObject]?, error: NSError?) -> Void in
//                        if ((error) == nil)
//                        {
//                            self.label_array.append("My Lists")
//                            DispatchQueue.main.async(execute: {
//                                if (user!.count != 0) {
//                                    self.playlists_user = user!
//                                    self.all_playlists.append(self.playlists_user)
//                                    self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
//                                }
//                                else {
//                                    self.all_playlists.append([])
//                                }
////                                let query3 = PFUser.query()!
////                                query3.whereKeyExists("username")
////                                query3.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
////                                query3.findObjectsInBackgroundWithBlock {(objects1: [PFObject]?, error: NSError?) -> Void in
////                                    if ((error) == nil)
////                                    {
////                                        dispatch_async(dispatch_get_main_queue(), {
////                                            if let recentarray = objects1![0]["recentlyViewed"] as? [String]
////                                            {
////                                                let query4 = PFQuery(className: "Playlists")
////                                                query4.whereKey("objectId", containedIn: recentarray)
////                                                query4.findObjectsInBackgroundWithBlock {(objects2: [PFObject]?, error: NSError?) -> Void in
////                                                    if ((error) == nil)
////                                                    {
////                                                        dispatch_async(dispatch_get_main_queue(), {
////                                                            self.recent_playlists = objects2!
////                                                            self.all_playlists.append(self.recent_playlists)
////                                                            self.label_array.append("Recently Viewed")
////                                                            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
////                                                        })
////                                                    }
////                                                }
////                                            }
////                                        })
////                                    }
////                                }
//                            })
//                        }
//                        else
//                        {
//                            print(error?.userInfo)
//                        }
//                    }
//
//                })
//            }
//            else
//            {
//                print(error?.userInfo)
//            }
//        }
//    }
//    
//    // MARK: - Table view data source
//    var storedOffsets = [Int: CGFloat]()
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return self.all_playlists.count
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
//        cell.reloadCollectionView()
//        print(label_array)
//        cell.titleLabel.text = label_array[(indexPath as NSIndexPath).row] 
//        cell.titleLabel.textColor = appDefaults.color
//        cell.selectionStyle = UITableViewCellSelectionStyle.none
//        return cell
//    }
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        guard let tableViewCell = cell as? TableViewCell else{return}
//        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: (indexPath as NSIndexPath).row)
//        tableViewCell.collectionViewOffset = storedOffsets[(indexPath as NSIndexPath).row] ?? 0
//    }
//    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath:IndexPath) {
//        
//        guard let tableViewCell = cell as? TableViewCell else { return }
//        
//        storedOffsets[(indexPath as NSIndexPath).row] = tableViewCell.collectionViewOffset
//    }
//}
//
//extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate
//{
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return all_playlists[collectionView.tag].count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        
//        collectionView.register(UINib(nibName: "ListCell", bundle: Bundle.main), forCellWithReuseIdentifier: "listCell")
//        
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listCell", for: indexPath) as! ListCollectionViewCell
//        
//        let cellobject = all_playlists[collectionView.tag][(indexPath as NSIndexPath).row] as! PFObject
//        
//        // CONFIGURE CELL
//        //cell.alpha = 0
//        
//        Async.main{
//            self.configureCell(cell, cellobject: cellobject) {
//    //            UIView.animateWithDuration(1.0, animations: {
//    //                cell.alpha = 1
//    //            })
//            }
//        }
//        
//        return cell
//    }
//    
//    
//    func configureCell(_ cell: ListCollectionViewCell, cellobject: PFObject, completion: () -> Void){
//        cell.listName.text = cellobject["playlistName"] as? String
//        let createdByUser = cellobject["createdBy"] as! PFUser
//        createdByUser.fetchIfNeededInBackground { (object, error) in
//            if (error == nil)
//            {
//                DispatchQueue.main.async(execute: {
//                    cell.creatorName.text = "BY " + ((object!["username"]? as AnyObject).uppercased)!
//                })
//            }
//        }
//        let followCount = cellobject["followerCount"]
//        if (followCount == nil) {
//            cell.followerCount.text = "0"
//        }
//        else {
//            cell.followerCount.text = String(describing: followCount)
//        }
//        
//        if let numPlaces = cellobject["num_places"] as? Int{
//            cell.numOfPlaces.text = String(numPlaces)
//        }
//        if let icon = cellobject["custom_bg"] as? PFFile{
//            icon.getDataInBackground(block: { (data, error) in
//                if error == nil{
//                    let image = UIImage(data: data!)
//                    cell.playlistImage.image = image
//                }
//            })
//        }
//        else {
//            cell.playlistImage.image = UIImage(named: "default_list_bg")
//        }
//        if let avgPrice = cellobject["average_price"] as? Int{
//            var avg_price = ""
//            for _ in 0..<(avgPrice) {
//                avg_price += "$"
//            }
//            if avg_price != ""{
//                cell.avgPrice.text = avg_price
//            }else{
//                let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "-$-")
//                attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
//                cell.avgPrice.attributedText = attributeString
//            }
//        }else{
//            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "-$-")
//            attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
//            cell.avgPrice.attributedText = attributeString
//        }
//        completion()
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        self.row = collectionView.tag
//        self.col = (indexPath as NSIndexPath).row
//
//        // Perform Segue and Pass List Data
//        let listVC = storyboard!.instantiateViewController(withIdentifier: "singlePlaylistVC") as! ListViewController//SinglePlaylistViewController
//        let temparray = all_playlists[collectionView.tag]
//        listVC.object = temparray[(indexPath as NSIndexPath).row] as! PFObject
//        self.navigationController!.pushViewController(listVC, animated: true)
//        
////        let segue = ZoomSegue(identifier: "showList", source: self, destination: listVC)
////        segue.objectToSet = temparray[indexPath.row] as! PFObject
//        
//        //self.performSegueWithIdentifier("showPlaylist", sender: self)
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//        if (segue.identifier == "showPlaylist")
//        {
//            let upcoming = segue.destination as? SinglePlaylistViewController
//            
//            let temparray = all_playlists[row]
//            //let navController: UINavigationController = self.navigationController!
//            upcoming?.object = temparray[col] as! PFObject
//        }
//    }
//    
//}
