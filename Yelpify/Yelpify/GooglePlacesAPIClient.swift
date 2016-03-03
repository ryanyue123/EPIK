//
//  GooglePlacesAPIClient.swift
//  Yelpify
//
//  Created by Jonathan Lam on 2/19/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import Foundation
import Alamofire

class GooglePlacesAPIClient: NSObject {
    
    var photoParameters = [
        "key" : "AIzaSyAZ1KUrHPxY36keuRlZ4Yu6ZMBNhyLcgfs",
        "photoreference" : "...",
        "maxheight" : "800"
    ]
    
    override init() {
        super.init()
    }
    
    func searchPlacesWithParameters(searchParameters: Dictionary<String, String>, completion: (result: NSDictionary) -> Void){
        
        Alamofire.request(.GET, buildURLString(searchParameters))
            .responseJSON { response in
//                print(self.parameters)
//                print(response.request)  // original URL request
//                print(response.response) // URL response
//                print(response.data)     // server data
//                print(response.result)   // result of response serialization
                
                do { let data = try NSJSONSerialization.JSONObjectWithData(response.data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    completion(result: data!)
                }catch{}
        }
    }
    
    func searchPlaceWithName(nameString: String, completion: (result: NSDictionary) -> Void){
        var parameters = [
            "key" : "AIzaSyAZ1KUrHPxY36keuRlZ4Yu6ZMBNhyLcgfs",
            "keyword": nameString,
            "location" : "33.64496794563093,-117.83725295740864",
            //"radius" : "50000", // DO NOT USE RADIUS IF RANKBY = DISTANCE
            "rankby": "distance"
            //"query" : "pizza"
        ]

        Alamofire.request(.GET, buildURLString(parameters))
            .responseJSON { response in
                //                print(self.parameters)
                //                print(response.request)  // original URL request
                //                print(response.response) // URL response
                //                print(response.data)     // server data
                //                print(response.result)   // result of response serialization
                
                do { let data = try NSJSONSerialization.JSONObjectWithData(response.data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    completion(result: data!)
                }catch{}
        }
    }
    
    func getImageFromPhotoReference(photoReference: String, completion: (photo: UIImage, error: NSError?) -> Void){
        let photoRequestParams = ["key": "AIzaSyAZ1KUrHPxY36keuRlZ4Yu6ZMBNhyLcgfs", "photoreference": photoReference, "maxheight": "800"]
        
        let photoRequestURL = NSURL(string: buildPlacePhotoURLString(photoRequestParams))!
        
        
        self.getDataFromUrl(photoRequestURL) { (data, response, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                guard let data = NSData(contentsOfURL: photoRequestURL) where error == nil else { return }
                let imageFile = UIImage(data: data)!
                
                completion(photo: imageFile, error: error)
            })
        }
    }
    
    private func getDataFromUrl(url: NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func buildURLString(parameters: Dictionary<String, String>) -> String!{
        var result = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        //"https://maps.googleapis.com/maps/api/place/textsearch/json?"
        for (key, value) in parameters{
            let addString = key + "=" + value + "&"
            result += addString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        }
        // print(result)
        return result
    }
    
    func buildPlacePhotoURLString(parameters: Dictionary<String, String>) -> String{
        var result = "https://maps.googleapis.com/maps/api/place/photo?"
        for (key, value) in parameters{
            let addString = key + "=" + value + "&"
            result += addString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        }
        return result

    }
    
}