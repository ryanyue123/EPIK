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

enum StringConversionError: ErrorType {
    case CannotConvertError
}

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
    
    var photoRefs = [String]()
    
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
        self.directionsButton.enabled = false
        self.callButton.enabled = false
        self.webButton.enabled = false
        self.title = "Details"
        
        APIClient.performDetailedSearch(object.gPlaceID!) { (detailedGPlace) in
            self.nameLabel.text = self.object.businessName
            self.addressLabel.text = detailedGPlace.address
            self.directionsButton.enabled = true
            self.callButton.enabled = true
            
            self.object.businessPhone = detailedGPlace.phone!
            
            print("Hours: ", detailedGPlace.hours!, "\n")
            print("Phone: ", detailedGPlace.phone!, "\n")
            print("Photos: ", detailedGPlace.photos!, "\n")
            print("Price Rating: ", detailedGPlace.priceRating!, "\n")
            print("Rating: ", detailedGPlace.rating!, "\n")
            //print("Reviews: ", detailedGPlace.reviews, "\n")
            print("Website: ", detailedGPlace.website!, "\n")
            
            self.gpClient.getImageFromPhotoReference(detailedGPlace.photos![0] as! String, completion: { (key) in
                self.cache.fetch(key: detailedGPlace.photos![0] as! String){ (imageData) in
                    print("Grabbing image")
                    self.placePhotoImageView.image = UIImage(data: imageData)
                }
            })
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

}
