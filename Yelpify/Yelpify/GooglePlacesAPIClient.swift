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
    
    func searchPlacesWithParameters(_ searchParameters: Dictionary<String, String>, completion: @escaping (_ result: Data) -> Void){
        
        Alamofire.request(buildURLString(searchParameters))
            .responseJSON { response in
//                print(self.parameters)
//                print(response.request)  // original URL request
//                print(response.response) // URL response
//                print(response.data)     // server data
//                print(response.result)   // result of response serialization
                
                completion(response.data!)
                
//                do { let data = try NSJSONSerialization.JSONObjectWithData(response.data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
//                    completion(result: data!)
//                }catch{}
        }
    }
    
    func searchPlaceWithID(_ id: String, completion: @escaping (_ data: Data) -> Void){
        let parameters = ["key": googleAPIKey, "placeid": id]
        
        Alamofire.request(self.buildDetailedURLString(parameters))
            .responseJSON { response in
                completion(response.data!)
        }
        
    }
    
    
//    func searchPlaceWithID(id: String, completion: (JSONdata: NSDictionary) -> Void){
//        let parameters = ["key": googleAPIKey, "placeid": id]
//        
//        Alamofire.request(.GET, self.buildDetailedURLString(parameters))
//            .responseJSON { response in
//                do { let data = try NSJSONSerialization.JSONObjectWithData(response.data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
//                    completion(JSONdata: data!)
//                }catch{}
//        }
//
//    }
    
    func searchPlaceWithNameAndCoordinates(_ name: String, coordinates: NSArray, completion: @escaping (_ JSONdata: NSDictionary) -> Void) {
        
        let location = String(describing: coordinates[0]) + "," + String(describing: coordinates[1])
        let parameters = [
            "key" : googleAPIKey,
            "query": name,
            "location" : location,
            "radius" : "50" ]
        
        Alamofire.request(buildURLString(parameters))
            .responseJSON { response in
                do { let data = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    completion(data!)
                    
                    if debugPrint.RAW_GOOGLE_JSON == true{
                        print("GOOGLE JSON")
                        print(data)
                    }
                }catch{}
            }
    }
    
    func getImageFromPhotoReference(_ photoReference: String, completion: @escaping (_ key: String) -> Void){
        
        let photoParameters = [
            "key" : googleAPIKey,
            "photoreference" : photoReference,
            "maxheight" : "800"
        ]
        
        let URLString = self.buildPlacePhotoURLString(photoParameters)

        
        Alamofire.download(URLString).responseData { response in
            if let data = response.result.value {
                let image = UIImage(data: data)!
                
                self.cache.set(value: image, key: photoReference)
                completion(photoReference)
            }
        }
    }

    
    func getImage(_ ref: String, completion: @escaping (_ image: UIImage) -> Void){
        let photoParameters = [ "key" : googleAPIKey, "photoreference" : ref, "maxheight" : "800" ]
        let URL = Foundation.URL(string: self.buildPlacePhotoURLString(photoParameters))!
        
        let fetcher = NetworkFetcher<UIImage>(URL: URL as NSURL)
        cache.fetch(fetcher: fetcher).onSuccess { image in completion( image ) }
    }
    
//    fileprivate func getDataFromUrl(_ url: URL, completion: @escaping ((_ data: Data?, _ response: URLResponse?, _ error: NSError? ) -> Void)) {
//        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
//            completion(data, response, error)
//            }) .resume()
//    }
    
    fileprivate func buildURLString(_ parameters: Dictionary<String, String>) -> String!{
        var result = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        // "https://maps.googleapis.com/maps/api/place/textsearch/json?"
        for (key, value) in parameters{
            let addString = key + "=" + value + "&"
            result += addString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        }
        return result
    }
    
    
    fileprivate func buildDetailedURLString(_ parameters: Dictionary<String, String>) -> String!{
        var result = "https://maps.googleapis.com/maps/api/place/details/json?"
        for (key, value) in parameters{
            let addString = key + "=" + value + "&"
            result += addString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        }
        return result
    }
    
    func buildPlacePhotoURLString(_ parameters: Dictionary<String, String>) -> String{
        var result = "https://maps.googleapis.com/maps/api/place/photo?"
        for (key, value) in parameters{
            let addString = key + "=" + value + "&"
            result += addString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        }
        return result

    }
    
}
