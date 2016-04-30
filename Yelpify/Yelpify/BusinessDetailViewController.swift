//
//  BusinessDetailViewController.swift
//  Yelpify
//
//  Created by Ryan Yue on 2/23/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import Parse
import Haneke

class BusinessDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var darkOverlay: UIView!
    
    @IBOutlet weak var placePhotoImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var numOfReviewsLabel: UILabel!
    
    var statusBarView: UIView!
    var navBarShadowView: UIView!
    var loadedStatusBar = false
    var loadedNavBar = false
    
    //var placePhoto: UIImage? = UIImage(named: "default_restaurant")
    let cache = Shared.dataCache
    var object: Business!
    var index: Int!
    
    var photoRefs = [String]()
    var reviewArray = NSArray()
    
    var APIClient = APIDataHandler()
    let gpClient = GooglePlacesAPIClient()
    //var yelpClient = APIDataHandler()
    //var yelpObj:YelpBusiness!

    
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var webButton: UIButton!
    
    @IBAction func showBusinessList(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navBarShadowView = ConfigureFunctions.configureNavigationBar(self.navigationController!, outterView: self.view)
        
        // Configure status bar and set alpha to 0
        self.statusBarView = ConfigureFunctions.configureStatusBar(self.navigationController!)
        self.loadedStatusBar = true
        self.loadedNavBar = true
        
        configureHeaderView()

        self.directionsButton.enabled = false
        self.callButton.enabled = false
        //self.webButton.enabled = false
        self.title = "Details"
        
        APIClient.performDetailedSearch(object.gPlaceID!) { (detailedGPlace) in
            self.nameLabel.text = self.object.businessName
            self.addressLabel.text = detailedGPlace.address
            self.directionsButton.enabled = true
            self.callButton.enabled = true
            
            self.reviewArray = detailedGPlace.reviews!
            
            self.object.businessPhone = detailedGPlace.phone!
            
            /*
            print("Hours: ", detailedGPlace.hours!, "\n")
            print("Phone: ", detailedGPlace.phone!, "\n")
            print("Photos: ", detailedGPlace.photos!, "\n")
            print("Price Rating: ", detailedGPlace.priceRating!, "\n")
            print("Rating: ", detailedGPlace.rating!, "\n")
            print("Reviews: ", detailedGPlace.reviews, "\n")
            print("Website: ", detailedGPlace.website!, "\n")
            */
            
            if detailedGPlace.photos?.count > 0 {
                self.setCoverPhoto(detailedGPlace.photos![0] as! String)
            }
            
            
            self.tableView.reloadData()
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.loadedNavBar = true
        self.loadedStatusBar = true
        self.statusBarView.alpha = 0
    }
    
    override func viewDidAppear(animated: Bool) {
        //self.statusBarView.alpha = 0
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.loadedNavBar = false
        self.loadedStatusBar = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateHeaderView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderView()
    }
    
    func getReviewText(reviewDict: [NSDictionary]) -> [String]{
        var result: [String] = []
        for review in reviewDict{
            result.append(review["text"] as! String)
        }
        return result
    }
    
    // MARK: - Scroll View 
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.fadeBG()
        self.updateHeaderView()
        self.handleNavigationBarOnScroll()
    }
    
    func fadeBG(){
        //print(-tableView.contentOffset.y / headerHeight)
        self.darkOverlay.alpha = 1.6 - (-tableView.contentOffset.y / headerHeight)
        if self.darkOverlay.alpha < 0.6{ self.darkOverlay.alpha = 0.6 }
    }

    func handleNavigationBarOnScroll(){
        let showWhenScrollDownAlpha = 1 - (-tableView.contentOffset.y / headerHeight)
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(showWhenScrollDownAlpha) ]
        self.navigationItem.title = "details"
        
        self.navigationController?.navigationBar.backgroundColor = appDefaults.color.colorWithAlphaComponent((showWhenScrollDownAlpha))
        
        // Handle Status Bar
        //let statusBarView = self.view.viewWithTag(100)
        
        if loadedStatusBar == true{
            statusBarView.alpha = showWhenScrollDownAlpha
        }
        
        // Handle Nav Shadow View
        if loadedNavBar == true{
            self.navBarShadowView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(showWhenScrollDownAlpha)
        }
        //self.view.viewWithTag(102)!.backgroundColor = appDefaults.color.colorWithAlphaComponent(showWhenScrollDownAlpha)
    }

    
    // MARK: - Setup Views
    
    private let headerHeight: CGFloat = 350.0
    
//    func configureNavigationBar(){
//        addShadowToBar()
//        for parent in self.navigationController!.navigationBar.subviews {
//            for childView in parent.subviews {
//                if(childView is UIImageView) {
//                    childView.removeFromSuperview()
//                }
//            }
//        }
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
//        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
//
//    }
    
    func configureHeaderView(){
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        tableView.contentInset = UIEdgeInsets(top: headerHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -headerHeight)
    }
    
    func updateHeaderView(){
        var headerRect = CGRect(x: 0, y: -headerHeight, width: self.tableView.frame.size.width, height: headerHeight)
        
        if self.tableView.contentOffset.y < -headerHeight{
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
            print("high")
        }else if self.tableView.contentOffset.y > headerHeight{
            self.navigationItem.title = "hi"
            self.navigationItem.titleView?.tintColor = UIColor.whiteColor()
            print("low")
        }
        
        headerView.frame = headerRect
    }
    
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
    
    func setCoverPhoto(ref: String){
        self.gpClient.getImage(ref) { (image) in
            self.fadeOutImage(self.placePhotoImageView)
            
            UIImageView.animateWithDuration(1) {
                self.placePhotoImageView.alpha = 0
                self.placePhotoImageView.image = image
            }
            self.placePhotoImageView.alpha = 1
            //self.placePhotoImageView.image = image
        }
    }
    
    func fadeOutImage(imageView: UIImageView, endAlpha: CGFloat = 0.0){
        UIImageView.animateWithDuration(1) {
            imageView.image = UIImage()
            imageView.alpha = 1
        }
        imageView.alpha = endAlpha
    }
    
    @IBAction func addItemToPlaylist(sender: UIBarButtonItem) {
        performSegueWithIdentifier("unwindFromDetail", sender: self)
    }
    
//    @IBAction func PressedButton(sender: AnyObject) {
//        
//        var choose = UIAlertView()
//        
//        choose.addButtonWithTitle("Google Maps")
//        choose.addButtonWithTitle("Apple Maps")
//        choose.title = "Navigate"
//        choose.show()
//
//    }
    
    func convertAddress(address: String) -> String{
        let addressArray = address.characters.split{$0 == " "}.map(String.init)
        var resultString = ""
        for word in addressArray{
            resultString += word + "+"
        }
        return resultString
    }
    
    func convertPhone(phone: String) -> Int{
        let phoneArray = phone.characters.map { String($0) }
        var result = ""
        for char in phoneArray{
            if Int(char) != nil{
                result += char
            }
        }
        return Int(result)!
    }
    
    @IBAction func openInMaps(sender: UIButton) {
        let latitude = self.object.businessLatitude!
        let longitude = self.object.businessLongitude!
        
        if (UIApplication.sharedApplication().canOpenURL(NSURL(string: "comgooglemaps://")!))
        {
            let name = convertAddress(self.object.businessAddress!)
            //let name = self.object.businessName//self.object.businessName?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            print(name)
            let url = NSURL(string: "comgooglemaps://?saddr=\(name)&center=\(latitude),\(longitude)&directionsmode=driving")!
            print(url)
            UIApplication.sharedApplication().openURL(url)
        }
        else
        {
            print("not allowed")
        }
    }
    
    @IBAction func openInPhone(sender: UIButton)
    {
        let telnum = convertPhone(self.object.businessPhone!)
        if(UIApplication.sharedApplication().canOpenURL(NSURL(string: "tel://")!))
        {
            let url = NSURL(string: "tel://\(telnum)")
            UIApplication.sharedApplication().openURL(url!)
        }
    }
    @IBAction func openInWeb(sender: UIButton)
    {
        //check is self.object.businessURL is nil
        //let url = self.object.businessURL
        let url = NSURL(string: "")
        if (UIApplication.sharedApplication().canOpenURL(url!))
        {
            UIApplication.sharedApplication().openURL(url!)
        }
    }
    
    
    // MARK: - Table View Functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.reviewArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reviewCell", forIndexPath: indexPath) as! CommentTableViewCell
        let review = self.reviewArray[indexPath.row]
        cell.configureCell(review as! NSDictionary)
        return cell

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }

}
