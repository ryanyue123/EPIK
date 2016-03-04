//
//  GooglePlacesAPIClient.swift
//  Yelpify
//
//  Created by Jonathan Lam on 2/19/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import Foundation
import Alamofire
import Haneke

class GooglePlacesAPIClient: NSObject {
    
    let cache = Shared.imageCache
    
    let googleAPIKey = "AIzaSyDkxzICx5QqztP8ARvq9z0DxNOF_1Em8Qc"
    
//    var photoParameters = [
//        "key" : googleAPIKey,
//        "photoreference" : "...",
//        "maxheight" : "800"
//    ]
    
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
    
    func searchPlaceWithNameAndCoordinates(name: String, coordinates: NSArray, completion: (JSONdata: NSDictionary) -> Void) {
        
        let location = String(coordinates[0]) + "," + String(coordinates[1])
        let parameters = [
            "key" : googleAPIKey,
            "query": name,
            "location" : location,
            "radius" : "100" ]
        
        Alamofire.request(.GET, buildURLString(parameters))
            .responseJSON { response in
                do { let data = try NSJSONSerialization.JSONObjectWithData(response.data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    completion(JSONdata: data!)
                    
                    if debugPrint.RAW_GOOGLE_JSON == true{
                        print("GOOGLE JSON")
                        print(data)
                    }
                }catch{}
            }
    }
//    
//    func searchPlaceWithName(nameString: String, completion: (result: NSDictionary) -> Void){
//        var parameters = [
//            "key" : googleAPIKey,
//            "keyword": nameString,
//            "location" : "33.64496794563093,-117.83725295740864",
//            //"radius" : "50000", // DO NOT USE RADIUS IF RANKBY = DISTANCE
//            "rankby": "distance"
//            //"query" : "pizza"
//        ]
//
//        Alamofire.request(.GET, buildURLString(parameters))
//            .responseJSON { response in
//                //                print(self.parameters)
//                //                print(response.request)  // original URL request
//                //                print(response.response) // URL response
//                //                print(response.data)     // server data
//                //                print(response.result)   // result of response serialization
//                
//                do { let data = try NSJSONSerialization.JSONObjectWithData(response.data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
//                    completion(result: data!)
//                }catch{}
//        }
//    }
    
    func getImageFromPhotoReference(photoReference: String, completion: (key: String) -> Void){
        
        let photoParameters = [
            "key" : googleAPIKey,
            "photoreference" : photoReference,
            "maxheight" : "800"
        ]
        
        let URLString = self.buildPlacePhotoURLString(photoParameters)
        let URL = NSURL(string: URLString)!
        
        let fetcher = NetworkFetcher<UIImage>(URL: URL)
        cache.fetch(fetcher: fetcher).onSuccess { image in
            
            self.cache.set(value: image, key: photoReference)
            
            completion(key: photoReference)
        }
    }
    
    private func getDataFromUrl(url: NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func buildURLString(parameters: Dictionary<String, String>) -> String!{
        var result = "https://maps.googleapis.com/maps/api/place/textsearch/json?"
        //"https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        for (key, value) in parameters{
            let addString = key + "=" + value + "&"
            result += addString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        }
        //print(result)
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