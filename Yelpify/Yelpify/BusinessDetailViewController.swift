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
import Async
import SwiftPhotoGallery

class BusinessDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwiftPhotoGalleryDelegate, SwiftPhotoGalleryDataSource {

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
    @IBOutlet weak var segmentedTabBar: UIView!
    
    var statusBarView: UIView!
    var navBarShadowView: UIView!
    var loadedStatusBar = false
    var loadedNavBar = false
    
    var contentToDisplay: ContentTypes = .Places
    
    //var placePhoto: UIImage? = UIImage(named: "default_restaurant")
    let cache = Shared.dataCache
    var object: Business!
    var gPlaceObject: GooglePlaceDetail!
    
    var index: Int!
    
    var fromSearchTab: Bool = false
    
    var photoRefs = [String]()
    var reviewArray = NSArray()
    var infoArray = [("detail_location", ""), ("detail_phone", ""), ("detail_hours", "")]//, ("detail_web", "")] //[(UIImage, String)]()
    
    var APIClient = APIDataHandler()
    let gpClient = GooglePlacesAPIClient()
    
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var webButton: UIButton!
    
    @IBOutlet weak var addButtonImage: UIImageView!
    @IBOutlet weak var routeButtonImage: UIImageView!
    @IBOutlet weak var callButtonImage: UIImageView!
    
    @IBAction func showBusinessList(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.addTapToActions()
        
        // Register Nibs
        self.tableView.registerNib(UINib(nibName: "ReviewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "reviewCell")
        self.tableView.registerNib(UINib(nibName: "InfoCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "infoCell")
        self.tableView.registerNib(UINib(nibName: "ImageCarousel", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "imageCarousel")
        
        self.navBarShadowView = ConfigureFunctions.configureNavigationBar(self.navigationController!, outterView: self.view)
        
        self.tableView.separatorStyle = .None
        
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
                
                self.gPlaceObject = detailedGPlace
        
                // Set up Info Array
                self.setInfo(detailedGPlace)
                
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
            
            self.setInfo(gPlaceObject)
            
            // Set Types
            self.setTypeIcon(gPlaceObject.types)
            
            // Set Name
            self.nameLabel.text = gPlaceObject.name
            
            // Set Rating
            self.cosmosRating.rating = gPlaceObject.rating
            
            // Set Price Rating
            setPriceRating(gPlaceObject.priceRating)
            //self.priceRatingLabel.text = String(gPlaceObject.priceRating)
            
            // Set Hours
            if gPlaceObject.hours.count == 7{
                self.hoursLabel.text = getHours(gPlaceObject.hours)
            }else{
                self.hoursLabel.text = "No Hours Availible"
            }
            
            // Set Background Image
            if gPlaceObject.photos.count > 0{
                self.setCoverPhoto(gPlaceObject.photos[0] as! String)
            }
            
            // Set Reviews
            self.reviewArray = gPlaceObject.reviews
            self.tableView.reloadData()
            
            // Set Price Rating
            self.setPriceRating(gPlaceObject.priceRating)
            
            self.directionsButton.enabled = true
            self.callButton.enabled = true
        }
    
        self.tableView.reloadData()
    
    }
    
    func addTapToActions(){
        let add = UITapGestureRecognizer(target: self, action: "pressedAdd")
        let route = UITapGestureRecognizer(target: self, action: "pressedRoute")
        let call = UITapGestureRecognizer(target: self, action: "pressedCall")
        self.addButtonImage.addGestureRecognizer(add)
        self.routeButtonImage.addGestureRecognizer(route)
        self.callButtonImage.addGestureRecognizer(call)
    }
    
    func setInfo(place: GooglePlaceDetail){
        self.infoArray[0] = ("detail_location", place.address as String)
        self.infoArray[1] = ("detail_phone", place.phone as String)
        if gPlaceObject.hours.count == 7{
            self.infoArray[2] = ("detail_hours", getHours(place.hours))
        }else{
            self.infoArray[2] = ("detail_hours", "No Hours Availible")
        } // CHANGE
        
        self.tableView.reloadData()
    }
    
    func pressedAdd(){
        
    }
    
    func pressedRoute(){
        PlaceActions.openInMaps(nil, place: gPlaceObject)
    }
    
    func pressedCall(){
        PlaceActions.openInPhone(nil, place: gPlaceObject)
    }
    
    func getHours(hoursArray: NSMutableArray) -> String{
        let dayDict = [0: "Sunday", 1: "Monday", 2: "Tuesday", 3: "Wednesday", 4: "Thursday", 5: "Friday", 6: "Saturday"]
        
        let hoursArr = hoursArray
        print(hoursArr)
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
        if fromSearchTab == true{
            
        }
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
            if result != ""{
                self.priceRatingLabel.text = result
            }else{
                let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "-$-")
                attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
                self.priceRatingLabel.attributedText = attributeString
            }
        }else{
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "-$-")
            attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
            self.priceRatingLabel.attributedText = attributeString
        }
    }
    
    func setTypeIcon(businessTypes: NSArray){
        // Set Icon
        let businessList = ["restaurant","food","amusement","bakery","bar","beauty_salon","bowling_alley","cafe","car_rental","car_repair","clothing_store","department_store","grocery_or_supermarket","gym","hospital","liquor_store","lodging","meal_takeaway","movie_theater","night_club","police","shopping_mall"]
        
        if businessTypes.count != 0 && businessList.contains(String(businessTypes[0])){
            self.typeIconImageView.transform = CGAffineTransformMakeScale(1.2, 1.2)
            self.typeIconImageView.image = UIImage(named: String(businessTypes[0]) + "_Icon")!
        }else{
            self.typeIconImageView.transform = CGAffineTransformMakeScale(1.2, 1.2)
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
        self.navigationItem.title = object.businessName
        
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
            frame: CGRect(x: 0.0, y: 0.0, width: self.tableView.frame.size.width, height: 40),
            titles: ["Info", "Reviews"],
            index: 0,
            backgroundColor: appDefaults.color,
            titleColor: UIColor.whiteColor(),
            indicatorViewBackgroundColor: appDefaults.color,
            selectedTitleColor: .whiteColor())
        control.autoresizingMask = [.FlexibleWidth]
        control.panningDisabled = true
        control.titleFont = UIFont(name: "Montserrat", size: 12.0)!
        control.addTarget(self, action: "switchContentType", forControlEvents: .ValueChanged)
        control.alpha = 0
        self.segmentedView.addSubview(control)
        UIView.animateWithDuration(0.3) {
            control.alpha = 1
            self.segmentedView.bringSubviewToFront(self.segmentedTabBar)
        }
    }
    
    
    func switchContentType(){
        if self.contentToDisplay == .Places{
            self.contentToDisplay = .Comments
            
            let tX = self.view.frame.width / 2
            
            UIView.animateWithDuration(0.2, animations: {
                self.segmentedTabBar.transform = CGAffineTransformMakeTranslation(tX, 0)
            })
            
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
        }else{
            self.contentToDisplay = .Places
            
            let tX = self.view.frame.width / 2
            UIView.animateWithDuration(0.2, animations: {
                self.segmentedTabBar.transform = CGAffineTransformMakeTranslation(0, 0)
            })
            
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
        }
        
    }

    
//    func configureSegmentedBar(){
//        let control = BetterSegmentedControl(
//            frame: CGRect(x: 0.0, y: 0.0, width: self.headerView.frame.size.width, height: 40),
//            titles: ["Info", "Reviews"],
//            index: 0,
//            backgroundColor: appDefaults.color,
//            titleColor: UIColor.whiteColor(),
//            indicatorViewBackgroundColor: appDefaults.color_darker,
//            selectedTitleColor: .whiteColor())
//        control.autoresizingMask = [.FlexibleWidth]
//        control.panningDisabled = true
//        control.titleFont = UIFont(name: "Montserrat", size: 12.0)!
//        control.addTarget(self, action: "switchContentType", forControlEvents: .ValueChanged)
//        control.alpha = 0
//        self.segmentedView.addSubview(control)
//        UIView.animateWithDuration(0.3) {
//            control.alpha = 1
//        }
//    }

    
    func configureTableView(){
        //tableView.layoutMargins = UIEdgeInsetsMake(20, 0, 20, 0)
        //tableView.separatorInset = UIEdgeInsetsMake(20, 0, 20, 0)
        //tableView.estimatedRowHeight = 140.0
        //tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: - SwiftPhotoGallery Delegate Methods
    
    func configureCarouselGallery(){
        let gallery = SwiftPhotoGallery(delegate: self, dataSource: self)
        gallery.backgroundColor = appDefaults.color_bg
        gallery.pageIndicatorTintColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        gallery.currentPageIndicatorTintColor = appDefaults.color_darker
    }
    
    let imageNames = ["face", "temp_profile", "default_restaurant"]
    
    func numberOfImagesInGallery(gallery: SwiftPhotoGallery) -> Int {
        return imageNames.count
    }
    
    func imageInGallery(gallery: SwiftPhotoGallery, forIndex: Int) -> UIImage? {
        return UIImage(named: imageNames[forIndex])
    }
    
    func galleryDidTapToClose(gallery: SwiftPhotoGallery) {
        // do something cool like:
        dismissViewControllerAnimated(true, completion: nil)
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
        PlaceActions.openInMaps(nil, place: gPlaceObject)
    }
    
    @IBAction func openInPhone(sender: UIButton)
    {
        if object != nil{
            PlaceActions.openInPhone(object)
        }else{
            PlaceActions.openInPhone(nil, place: gPlaceObject)
        }
    }
    
    @IBAction func addPlaceButtonPressed(sender: AnyObject) {
        
    }
    
//    @IBAction func openInWeb(sender: UIButton)
//    {
//        let url = NSURL(string: "")
//        if (UIApplication.sharedApplication().canOpenURL(url!))
//        {
//            UIApplication.sharedApplication().openURL(url!)
//        }
//    }
    
//    func switchContentType(){
//        if self.contentToDisplay == .Places{
//            self.contentToDisplay = .Comments
//            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
//        }else{
//            self.contentToDisplay = .Places
//            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
//        }
//    }
//    
    // MARK: - Table View Functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch contentToDisplay {
        case .Places:
            return 4
        case .Comments:
            return self.reviewArray.count
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if contentToDisplay == .Places{
            if indexPath.row != 3{
                return 60.0
            }else{
                return 223.0
            }
        }else{
            return 140.0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // IF SEGMENTED IS ON PLACES (INFO)
        if self.contentToDisplay == .Places{
            if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2{
                let infoCell = tableView.dequeueReusableCellWithIdentifier("infoCell", forIndexPath: indexPath) as! InfoTableViewCell
                
                infoCell.configureCell(UIImage(named: self.infoArray[indexPath.row].0)!, label: self.infoArray[indexPath.row].1)
                
                return infoCell
            }else{
                // IMAGE CAROUSEL
                let imageCarouselCell = tableView.dequeueReusableCellWithIdentifier("imageCarousel", forIndexPath: indexPath) as! ImageCarouselTableViewCell
                
                if gPlaceObject != nil{
                    if gPlaceObject.photos.count > 0{
                        imageCarouselCell.setImages(gPlaceObject)
                    }else{
                        //return UITableViewCell()
                    }
                }else{
                    //return UITableViewCell()
                }
                
                return imageCarouselCell
            }
            
            // IF SEGMENTED IS ON COMMENTS (REVIEWS)
        }else if self.contentToDisplay == .Comments{
            let reviewCell = tableView.dequeueReusableCellWithIdentifier("reviewCell", forIndexPath: indexPath) as! ReviewTableViewCell

            self.tableView.rowHeight = 140.0
            
            reviewCell.configureCell(self.reviewArray[indexPath.row] as! NSDictionary)
            
            return reviewCell
        }else{
            return UITableViewCell()
        }
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
