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
import Cosmos
import BetterSegmentedControl

class BusinessDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var cosmosRating: CosmosView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var darkOverlay: UIView!
    
    @IBOutlet weak var priceRatingLabel: UILabel!
    @IBOutlet weak var placePhotoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var typeIconImageView: UIImageView!

    @IBOutlet weak var segmentedView: UIView!
    
    var statusBarView: UIView!
    var navBarShadowView: UIView!
    var loadedStatusBar = false
    var loadedNavBar = false
    
    
    //var placePhoto: UIImage? = UIImage(named: "default_restaurant")
    let cache = Shared.dataCache
    var object: Business!
    var gPlaceObject: GooglePlaceDetail!
    
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
        
        // Register Nibs
        self.tableView.registerNib(UINib(nibName: "ReviewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "reviewCell")
        
        configureTableView()
        
        self.navBarShadowView = ConfigureFunctions.configureNavigationBar(self.navigationController!, outterView: self.view)
        
        // Configure status bar and set alpha to 0
        self.statusBarView = ConfigureFunctions.configureStatusBar(self.navigationController!)
        self.loadedStatusBar = true
        self.loadedNavBar = true
        
        configureHeaderView()
        
        configureSegmentedBar()

        self.directionsButton.enabled = false
        self.callButton.enabled = false
        //self.webButton.enabled = false
        self.title = "Details"
        
        // IF SEGUEING FROM SEARCHBUSINESSCONTROLLER
        if object != nil{
            APIClient.performDetailedSearch(object.gPlaceID!) { (detailedGPlace) in
        
                // Set Icon
                self.setTypeIcon(self.object.businessTypes)
                
                // Set Name
                self.nameLabel.text = self.object.businessName
                
                // Set Address
                //self.addressLabel.text = detailedGPlace.address
                
                // Set Reviews
                self.reviewArray = detailedGPlace.reviews!
                
                // Set Phone
                self.object.businessPhone = detailedGPlace.phone!
                
                // Set Rating
                if let ratingValue = detailedGPlace.rating{
                    if ratingValue != -1{
                        self.cosmosRating.rating = ratingValue
                    }else{
                        self.cosmosRating.hidden = true
                        //self.cosmosRating.addSubview(UILabel)
                    }
                }
                
                // Set Price
                if let price = detailedGPlace.priceRating{
                    self.setPriceRating(price)
                }
//                if let price = detailedGPlace.priceRating{
//                    var priceString = ""
//                    for _ in 0..<price {
//                        priceString += "$"
//                    }
//                    self.priceRatingLabel.text = priceString
//                }
                
                // Set Hours
                if detailedGPlace.hours!.count != 0{
                    self.hoursLabel.text = self.getHours(detailedGPlace.hours!)
                }else{
                    self.hoursLabel.text = "No Hours Availible"
                }
            
                // Set Photos
                if detailedGPlace.photos?.count > 0 {
                    let randNum = Int(arc4random_uniform(UInt32(detailedGPlace.photos.count)))
                    self.setCoverPhoto(detailedGPlace.photos![randNum] as! String)
                }
                
                
                /*
                print("Hours: ", detailedGPlace.hours!, "\n")
                print("Phone: ", detailedGPlace.phone!, "\n")
                print("Photos: ", detailedGPlace.photos!, "\n")
                print("Price Rating: ", detailedGPlace.priceRating!, "\n")
                print("Rating: ", detailedGPlace.rating!, "\n")
                print("Reviews: ", detailedGPlace.reviews, "\n")
                print("Website: ", detailedGPlace.website!, "\n")
                */
                
                // Set Action Buttons
                self.directionsButton.enabled = true
                self.callButton.enabled = true
             
                self.tableView.reloadData()
            }
        }else{
        // IF SEGUEING FROM SINGLEPLAYLISTCONTROLLER
            // Set Types
            self.setTypeIcon(gPlaceObject.types)
            
            // Set Name
            self.nameLabel.text = gPlaceObject.name
            
            // Set Rating
            self.cosmosRating.rating = gPlaceObject.rating
            
            // Set Price Rating
            self.priceRatingLabel.text = String(gPlaceObject.priceRating)
            
            // Set Hours
            self.hoursLabel.text = getHours(gPlaceObject.hours)
            
            // Set Background Image
            if gPlaceObject.photos.count > 0{
                self.setCoverPhoto(gPlaceObject.photos[0] as! String)
            }
            
            // Set Reviews
            self.reviewArray = gPlaceObject.reviews
            self.tableView.reloadData()
            
            // Set Price Rating
            self.setPriceRating(gPlaceObject.priceRating)
            
        }
    
    
    }
    
    func getHours(hoursArray: NSMutableArray) -> String{
        let dayDict = [0: "Sunday", 1: "Monday", 2: "Tuesday", 3: "Wednesday", 4: "Thursday", 5: "Friday", 6: "Saturday"]
        
        let hoursArr = hoursArray
        hoursArr.insertObject(hoursArr[6], atIndex: 0)
        hoursArr.removeLastObject()
        
        let today = getDayOfWeek()!
        let hoursToday = hoursArr[today]
        let hoursTodayArr = hoursToday.componentsSeparatedByString(",")
        if hoursTodayArr.count > 1{
            return "24 Hours"
        }else{
            let parsedString = hoursTodayArr[0].stringByReplacingOccurrencesOfString((dayDict[today]! + ":"), withString: "")
            return parsedString
        }
        
    }

    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewDidAppear(animated: Bool) {
        handleNavigationBarOnScroll()
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
    
    func setPriceRating(price: Int){
        var result = ""
        if price != -1{
            for _ in 0..<price{
                result += "$"
            }
            self.priceRatingLabel.text = result
        }else{
            self.priceRatingLabel.text = ""
        }
    }
    
    func setTypeIcon(businessTypes: NSArray){
        // Set Icon
        let businessList = ["restaurant","food","amusement","bakery","bar","beauty_salon","bowling_alley","cafe","car_rental","car_repair","clothing_store","department_store","grocery_or_supermarket","gym","hospital","liquor_store","lodging","meal_takeaway","movie_theater","night_club","police","shopping_mall"]
        
        if businessTypes.count != 0 && businessList.contains(String(businessTypes[0])){
            self.typeIconImageView.image = UIImage(named: String(businessTypes[0]) + "_Icon")!
        }else{
            self.typeIconImageView.image = UIImage(named: "default_Icon")!
        }

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
    
    private let headerHeight: CGFloat = 320.0
    
    func configureHeaderView(){
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        tableView.contentInset = UIEdgeInsets(top: headerHeight + 5, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -headerHeight)
    }
    
    func updateHeaderView(){
        var headerRect = CGRect(x: 0, y: -headerHeight, width: self.tableView.frame.size.width, height: headerHeight)
        
        if self.tableView.contentOffset.y < -headerHeight{
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
        }else if self.tableView.contentOffset.y > headerHeight{
            self.navigationItem.title = "hi"
            self.navigationItem.titleView?.tintColor = UIColor.whiteColor()
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
    
    func configureSegmentedBar(){
        let control = BetterSegmentedControl(
            frame: CGRect(x: 0.0, y: 0.0, width: self.headerView.frame.size.width, height: 40),
            titles: ["Info", "Reviews"],
            index: 0,
            backgroundColor: appDefaults.color,
            titleColor: UIColor.whiteColor(),
            indicatorViewBackgroundColor: appDefaults.color_darker,
            selectedTitleColor: .whiteColor())
        control.autoresizingMask = [.FlexibleWidth]
        control.panningDisabled = true
        control.titleFont = UIFont(name: "Montserrat", size: 12.0)!
        control.addTarget(self, action: nil, forControlEvents: .ValueChanged)
        self.segmentedView.addSubview(control)
    }

    
    func configureTableView(){
        //tableView.layoutMargins = UIEdgeInsetsMake(20, 0, 20, 0)
        //tableView.separatorInset = UIEdgeInsetsMake(20, 0, 20, 0)
        //tableView.estimatedRowHeight = 140.0
        //tableView.rowHeight = UITableViewAutomaticDimension
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
        let cell = tableView.dequeueReusableCellWithIdentifier("reviewCell", forIndexPath: indexPath) as! ReviewTableViewCell
        let review = self.reviewArray[indexPath.row]
        cell.configureCell(review as! NSDictionary)
        
        cell.layoutMargins = UIEdgeInsetsMake(10, 0, 10, 0)
        return cell

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }

}

func getDayOfWeek()->Int? {
    
    let date = NSDate()
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([.Day , .Month , .Year], fromDate: date)
    
    let today = String(format: "%04d", components.year) + "-" + String(format: "%02d", components.month) + "-" + String(format: "%02d", components.day)
    
    let formatter  = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    
    if let todayDate = formatter.dateFromString(today) {
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let myComponents = myCalendar.components(.Weekday, fromDate: todayDate)
        let weekDay = myComponents.weekday
        return weekDay - 1
    } else {
        return nil
    }
}
