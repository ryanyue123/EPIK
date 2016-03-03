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
    var businessObjects: [Business] = [Business(name: "Fresh Brothers", address: "1616 San Miguel Dr", imageURL: "https://s3-media2.fl.yelpcdn.com/bphoto/UIBKCAVDSdx8u-Qyrl2Xfg/ms.jpg", photoRef: "CmRdAAAAvwm52TM1oZ1v8gtwOC7DxhJjEPCL1R9IDLptTSqhT-1bVwyXZqaPIZKN2m4xqWbMdUfb3Q-IBaVMb16daG_0_WRl8KWssOU9dcd3DCYht_xd2_icEvFJo579bTJV7kjLEhA9I5PcIh0DD74Tvlb2KezIGhSu-YfA2nTKTGqAr8dsf6FSPWOfsg"),
        Business(name: "Newport Coast First Class Pizza", address: "21117 Newport Coast Dr", imageURL: "https://s3-media4.fl.yelpcdn.com/bphoto/4v3Dgx8xp4aMi6qTDgoGoQ/ms.jpg", photoRef: "CmRdAAAAsVyiakROPdNouYulqiU0ZrW05rPwStdWyAOt-L3BGwdsKeyN6k68St-cJYO23vhMl1Mz3u5643Ku_PNYKdWZ1bjH4-poSAS5hBdbnGa-_yQYqpEbOaltX-JDIVFYmPjSEhBCmfIQVNxz7hXHCtzIC2IgGhScfCUnxQL46A0CVaBohMwI-__dNw"),
        Business(name: "MOD Pizza", address: "3965 Alton Pkwy", imageURL: "https://s3-media2.fl.yelpcdn.com/bphoto/S7FCA2wKpcrIkrwGBMQjqQ/ms.jpg", photoRef: "CmRdAAAAtQBVhS7B4OvE328cyxa6xdQchDdaeu_xG1UuJX3l4CASAzJ6IJfKxA5MmNiV438sUz7IbKSihSFAToSHOamQV10s4N-DdD452to8NYqXouxPhFWF2Gv4PAnB0OwXlqmVEhAiPochFgLm4DxBbMNOFss5GhSSt0ZrlJwe8ECDq1SDus5Lzqoi0Q"),
        Business(name: "Flippin\' Pizza", address: "17933 MacArthur Blvd", imageURL: "https://s3-media4.fl.yelpcdn.com/bphoto/Xg79VF1ykG0fJtgBN4S6Eg/ms.jpg", photoRef: "CmRdAAAAfWFuv7Jfn5IXxvcHNvW2tZV_6Ob9CJ0luk4wNwzf-zo5y9CkOOHGzSRY0VIsRj3zfct_mCXoIvw2Fmvk8jplhiImbXZwr6GJVmcp5zSI0Ik23imhX5w6_AOxGSHE6duzEhB04QulijAnzJqbyQADKl9vGhRVMsRxXKCUUgtNwZcxfGiNuEhDlw"),
        Business(name: "Ray\'s Pizza", address: "4199 Campus Dr", imageURL: "https://s3-media3.fl.yelpcdn.com/bphoto/-wJiuGzFsoTVHNMQJ61EFg/ms.jpg", photoRef: ""),
        Business(name: "Gina\'s Pizza & Pastaria", address: "4533 Campus Dr", imageURL: "https://s3-media1.fl.yelpcdn.com/bphoto/iwMENoQgJQpzzz9EYuRr-w/ms.jpg", photoRef: "CmRdAAAAo4_76ETE0s6WtMwJzCDZngDRWMiR-7hcCRD1vl-8bJgSOg_-P82fHQPnakTcIyVIqN99-fl3cUcyxzzDqqCAryGe06LI-tIdNVb9s_dI-Fs0Y24Gt5PT6nPnyu2xl1kDEhCRYcvXzWcwS5ynm4QgVe-4GhT_Zg8l5JQgi7UjFZL74RRyIjWP1g"),
        Business(name: "Johnny\'s Real New York Pizza", address: "1320 Bison Ave", imageURL: "https://s3-media1.fl.yelpcdn.com/bphoto/CKNBaIFhYBlXpL4t1nnsdw/ms.jpg", photoRef: ""),
        Business(name: "Mad Pie", address: "19530 Jamboree Rd", imageURL: "https://s3-media4.fl.yelpcdn.com/bphoto/EDiGA6scvADOYik8X21Zbw/ms.jpg", photoRef: ""),
        Business(name: "Ameci Pizza & Pasta", address: "18068 Culver Dr", imageURL: "https://s3-media1.fl.yelpcdn.com/bphoto/FYB2xHH5RjbSog17RaJgZg/ms.jpg", photoRef: "CmRdAAAADzxIZmrD3rIQvIkc1l_TLlWi9xELRRVByj38K7WH6IYA_9Dbd91lQ_QHcsxXqGg2ZO_JanR-mfGc9PWEPjQq0Y75SA_A_Oc9UlBUCo7KUXl9UMizI0AlE4JuJrLtI2q4EhCnqufSOf6dVA8TxUIQkau4GhRENmEZGoqe5bgiQ7U54p3D3CLO4A"),
        Business(name: "Zpizza", address: "17655 Harvard Ave", imageURL: "https://s3-media2.fl.yelpcdn.com/bphoto/mSOq2BRqVkZPHLUzWmosAA/ms.jpg", photoRef: "CmRdAAAAD0L9v5-KsZ2vq40mvg_C1wcfPoMZyccMnhphr1llB6C27f1CzovOH8kOYQqRKlZutwt17rHz27YG4rEr2GeiFMojf-5lUhoZNX0beLM3QtxO_5GtT3X7rLGDD0rGL7R_EhDp2PqyMYSJrcUB9SQAO1r9GhSh3AJeo24vF7kksMA5bJV0XZsa_A"),
        Business(name: "Zpizza", address: "2549 Eastbluff Dr", imageURL: "https://s3-media1.fl.yelpcdn.com/bphoto/Y0qWJU2qvrUqeN1s6jrqBg/ms.jpg", photoRef: "CmRdAAAAD0L9v5-KsZ2vq40mvg_C1wcfPoMZyccMnhphr1llB6C27f1CzovOH8kOYQqRKlZutwt17rHz27YG4rEr2GeiFMojf-5lUhoZNX0beLM3QtxO_5GtT3X7rLGDD0rGL7R_EhDp2PqyMYSJrcUB9SQAO1r9GhSh3AJeo24vF7kksMA5bJV0XZsa_A")]
    var index: NSIndexPath!
    var playlistObject:PFObject!
    var playlistArray = [String]()
    var businessShown: [Bool] = []

    var yelpSearchParameters = [
        "ll": "33.64496794563093,-117.83725295740864",
        "term": "pizza",
        "radius_filter": "10000",
        "sort": "1"]
    
//    var gPlacesParameters = [
//        "key" : "AIzaSyAZ1KUrHPxY36keuRlZ4Yu6ZMBNhyLcgfs",
//        "keyword": "pizza",
//        "location" : "33.64496794563093,-117.83725295740864",
//        //"radius" : "50000", // DO NOT USE RADIUS IF RANKBY = DISTANCE
//        "rankby": "distance"
//        //"query" : "pizza"
//    ]
    
    // MARK: - TABLEVIEW FUNCTIONS
    
    @IBOutlet weak var addToPlaylist: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
//    
//    func updateImages(cell: BusinessTableViewCell, indexPath: NSIndexPath, business: NSDictionary){
//        
//        let photoReference = business["photoReference"] as! String
//        
//        googlePlacesClient.getImageFromPhotoReference(photoReference, completion: { (photo) -> Void in
//            dispatch_async(dispatch_get_main_queue()) { () -> Void in
//                cell.businessBackgroundImage.image = photo
//            }
//            print("grabbed photo")
//        })
//    }
    
//    func updateImages(cell: BusinessTableViewCell, indexPath: NSIndexPath, business: Business){
//        
//        let photoReference = business.businessPhotoReference
//        
//        googlePlacesClient.getImageFromPhotoReference(photoReference, completion: { (photo, error) -> Void in
//            
//            if error != nil {
//                print(error)
//                cell.businessBackgroundImage.image = UIImage(named: "restaurantImage - InNOut")
//            }
//            
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//            
//            //if(cell.tag == indexPath.row) {
//                cell.businessBackgroundImage.image = photo
//                cell.setNeedsLayout() // need to reload the view, which won't happen otherwise since this is in an async call
//                
//                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//                print("Grabbed Image")
//            //}
//            })
//        })
//
//    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businessObjects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "businessCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! BusinessTableViewCell
        
        if businessShown[indexPath.row] != true{
            if self.businessObjects.count >= indexPath.row{
                let business = self.businessObjects[indexPath.row]
                
                print(business)
                
                cell.configureCellWith(business)
                
//                if let cellToUpdate = self.tableView?.cellForRowAtIndexPath(indexPath) as? BusinessTableViewCell{
//                    cellToUpdate.businessTitleLabel.text = business.businessName
//                    updateImages(cellToUpdate, indexPath: indexPath, business: business)
//                }
                
            }
            businessShown[indexPath.row] = true
        }
        

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
        //getCurrentLocation()
        for _ in 0...10{
            self.businessShown.append(false)
        }
        
        // Performs an API search and returns a master array of businesses (as dictionaries)
        dataHandler.performAPISearch(yelpSearchParameters) { (masterBusinessArray, masterBusinessObjArray) -> Void in
            self.businesses = masterBusinessArray as! [NSDictionary]
            self.businessObjects = masterBusinessObjArray
            for _ in masterBusinessObjArray{
                self.businessShown.append(false)
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
        
        
        //playlistObject = PFObject(className: (PFUser.currentUser()?.username)!)
        //playlistArray.removeAll()
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

