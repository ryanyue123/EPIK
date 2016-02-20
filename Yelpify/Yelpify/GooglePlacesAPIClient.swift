//
//  GooglePlacesAPIClient.swift
//  Yelpify
//
//  Created by Jonathan Lam on 2/19/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import Foundation
import OAuthSwift
import Alamofire

class GooglePlacesAPIClient: NSObject {
    
    var photoParameters = [
        "key" : "AIzaSyAZ1KUrHPxY36keuRlZ4Yu6ZMBNhyLcgfs",
        "photoreference" : "...",
        "maxheight" : "1600"
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
    
    private func buildURLString(parameters: Dictionary<String, String>) -> String!{
        var result = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        //"https://maps.googleapis.com/maps/api/place/textsearch/json?"
        for (key, value) in parameters{
            let addString = key + "=" + value + "&"
            result += addString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        }
        // print(result)
        return result
    }
    
    private func buildPlacePhotoURLString(parameters: Dictionary<String, String>) -> String{
        var result = "https://maps.googleapis.com/maps/api/place/photo?"
        for (key, value) in parameters{
            let addString = key + "=" + value + "&"
            result += addString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        }
        return result

    }
    
}