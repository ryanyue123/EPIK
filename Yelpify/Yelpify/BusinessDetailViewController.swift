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

class BusinessDetailViewController: UITableViewController {

    @IBOutlet weak var placePhotoImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    
    //var placePhoto: UIImage? = UIImage(named: "default_restaurant")
    let cache = Shared.dataCache
    var object: Business!
    var index: Int!
    
    var APIClient = APIDataHandler()
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
        self.directionsButton.enabled = false
        self.callButton.enabled = false
        self.webButton.enabled = false
        self.title = "Details"
        
        APIClient.performDetailedSearch(object.gPlaceID!) { (detailedGPlace) in
            self.nameLabel.text = self.object.businessName
            self.addressLabel.text = detailedGPlace.address
            self.directionsButton.enabled = true
            self.callButton.enabled = true
        }
        
        cache.fetch(key: object.businessPhotoReference!) { (imageData) in
            
        }
        
//        yelpClient.retrieveYelpBusinessFromBusinessObject(object) { (yelpBusinessObject) -> Void in
//            self.yelpObj = yelpBusinessObject
//            self.nameLabel.text = self.object.businessName
//            self.addressLabel.text = self.object.businessAddress
//            self.directionsButton.enabled = true
//            self.callButton.enabled = true
//            if(self.object.businessPhone != nil)
//            {
//                self.callButton.enabled = true
//            }
////            if(self.object.businessURL != nil)
////            {
////                self.webButton.enabled = true
////            }
//        }
        //nameLabel.text = object.businessName
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addItemToPlaylist(sender: UIBarButtonItem) {
        performSegueWithIdentifier("unwindFromDetail", sender: self)
    }
    
    @IBAction func openInMaps(sender: UIButton) {
        let latitude = self.object.businessLatitude!
        let longitude = self.object.businessLongitude!
        
        if (UIApplication.sharedApplication().canOpenURL(NSURL(string: "comgooglemaps://")!))
        {
            let name = self.object.businessName?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            print(name!)
            let url = NSURL(string: "comgooglemaps://?saddr=&daddr=\(name!)&center=\(latitude),\(longitude)&directionsmode=driving")
            print(url)
            UIApplication.sharedApplication().openURL(url!)
        }
        else
        {
            print("not allowed")
        }
    }
    
    @IBAction func openInPhone(sender: UIButton)
    {
        let telnum = self.object.businessPhone!
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
