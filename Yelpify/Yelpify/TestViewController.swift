//
//  TestViewController.swift
//  Yelpify
//
//  Created by Jonathan Lam on 2/19/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var yelpSearchParameters = [
        "ll": "33.64496794563093,-117.83725295740864",
        "term": "pizza",
        "radius_filter": "10000",
        "sort": "1"]
    
    var gpParameters = [
        "key" : "AIzaSyAZ1KUrHPxY36keuRlZ4Yu6ZMBNhyLcgfs",
        "keyword": "pizza",
        "location" : "33.64496794563093,-117.83725295740864",
        //"radius" : "50000", // DO NOT USE RADIUS IF RANKBY = DISTANCE
        "rankby": "distance"
        //"query" : "pizza"
    ]
    
    var GPClient = GooglePlacesAPIClient()
    var yelpClient = YelpAPIClient()
    var APIClient = APIDataHandler()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        APIClient.performAPISearch(self.yelpSearchParameters, gpParameters: gpParameters) { (businessObject) -> Void in
            
        }
        
        
        //updateImages(GPClient.pullPlacePhotoURL())
        
        // Do any additional setup after loading the view.
    }
    
//    
    // MARK: - DOWNLOAD IMAGES
    
    func updateImages(imageURL: String){
        let url = NSURL(string: imageURL)!
        var imageFile: UIImage! = UIImage(named: "restaurantImage - InNOut")
        
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = NSData(contentsOfURL: url) where error == nil else { return }
                imageFile = UIImage(data: data)!
                self.imageView.image = imageFile
            }
        }
    }
    
    func getDataFromUrl(url: NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
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
