//
//  APIDataHandler.swift
//  Yelpify
//
//  Created by Jonathan Lam on 2/19/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import Foundation

struct debugPrint{
    static var RAW_JSON = false
    static var BUSINESS_ARRAY = false
    static var BUSINESS_DICT = true
}

class APIDataHandler {
    
    // DEBUG OPTIONS
    let PRINT_JSON = true
    
    var gpClient = GooglePlacesAPIClient()
    var yelpClient = YelpAPIClient()
    //var locuClient = LocuAPIClient()
    
    /*
    
    FLOW
    1) Take parameters for both APIs
    2) Pass parameters to individual APIs and recieve JSON data
    3) Parse the data into arrays of businesses from APIs
    4) Compare both arrays and match up businesses
    5) If match is good, combine data into one business object
    6) Return the array of business objects that contains data from all APIs used
    
    */
    
    func performAPISearch(yelpParameters: Dictionary<String, String>, gpParameters: Dictionary<String, String>, completion: (businessObject: [NSDictionary]) -> Void) {
        
        var finalBusinessesArray: NSArray!
        var yBusinessArray: NSArray!
        var gPlacesArray: NSArray!
        
        // result is NSDictionary

        yelpClient.searchPlacesWithParameters(yelpParameters) { (result) -> Void in
            
            self.parseYelpJSON(result) { (yelpBusinessArray) -> Void in
                yBusinessArray = yelpBusinessArray
            }
            
            if debugPrint.RAW_JSON == true{
                print("YELP JSON:\n", result)
            }
            
            self.gpClient.searchPlacesWithParameters(gpParameters) { (result) -> Void in
                
                self.parseGPlacesJSON(result) { (googlePlacesArray) -> Void in
                    gPlacesArray = googlePlacesArray
                }
                
                if debugPrint.RAW_JSON == true{
                    print("GOOGLE PLACES JSON:\n", result)
                }
                
                // Create business object
                self.combineJSONData(yBusinessArray, googlePlaceArray: gPlacesArray, completion: { (businessObject) -> Void in
                    finalBusinessesArray = businessObject
                    
                    if debugPrint.BUSINESS_DICT == true{
                        print(finalBusinessesArray)
                    }
                    
                })
                
            }
        }
        
        
        completion(businessObject: [])
    }
    
    private func parseYelpJSON(data: NSDictionary, completion: (yelpBusinessArray: NSArray) -> Void){
        if data.count > 0 {
            
            var arrayOfYelpBusinesses: NSMutableArray! = []
            
            if let businesses = data["businesses"] as? NSArray {
                if businesses.count > 0{
                    for business in businesses {
                        // Handle Address
                        
                        let businessID = business["id"] as! String
                        
                        var businessAddress = ""
                        if let businessLocation = business["location"] as? NSDictionary{
                            businessAddress = businessLocation["address"]![0] as! String
                        }
                        
                        // Handle Name
                        let businessName = business["name"] as! String
                        
//                        // Handle ImageURL
//                        let businessImageURL = business["image_url"] as! String
                        
                        arrayOfYelpBusinesses.addObject(["businessID": businessID, "address": businessAddress, "name": businessName])
                    }
                    
                    if debugPrint.BUSINESS_ARRAY == true{
                        print("Yelp Businesses")
                        print(arrayOfYelpBusinesses)
                    }
                    
                    completion(yelpBusinessArray: arrayOfYelpBusinesses)
                        
                }
            }
        }
    }
    
    private func parseGPlacesJSON(data: NSDictionary, completion: (googlePlacesArray: NSArray) -> Void){
        if data.count > 0 {
            
            var arrayOfGPlaces: NSMutableArray! = []
            
            if let places = data["results"] as? NSArray {
                if places.count > 0{
                    for place in places {
                        let placeID = place["place_id"] as! String
                        let placeName = place["name"] as! String
                        let placeAddress = place["vicinity"] as! String
                        
                        var placePhotoRef = ""
                        if let photos = place["photos"] as? NSArray{
                            placePhotoRef = photos[0]["photo_reference"] as! String
                        }
                        
                       arrayOfGPlaces.addObject(["placeID": placeID ,"address": placeAddress, "name": placeName, "placePhotoReference": placePhotoRef])
                    }
                    
                    if debugPrint.BUSINESS_ARRAY == true{
                        print("Google Places")
                        print(arrayOfGPlaces)
                    }
                    
                    completion(googlePlacesArray: arrayOfGPlaces)
                }
                
            }
        }
    }
    
    // This function takes the two dictionarys from the APIs and compares them, favoring the YELP API over GP
    // Also used to add in the image reference links from GPlaces API to form a uniform Business Object
    private func combineJSONData(yelpBusinessArray: NSArray, googlePlaceArray: NSArray, completion: (businessObject: NSArray) -> Void){
        
        var grandBusinessArray: NSMutableArray! = []
        var businessDict: NSMutableDictionary!
        businessDict = NSMutableDictionary()
        
        // Comparing business statements
        for business in yelpBusinessArray{
            for place in googlePlaceArray{
                let businessAddress = business["address"] as! String
                let placeAddress = place["address"] as! String
                let placePrefix = String(placeAddress.characters.prefix(4))
                
                if businessAddress.hasPrefix(placePrefix){
                    let businessID = business["businessID"] as! String
                    //businessDict.setValue(["name": String(business["name"])], forKey: "businessID")
                    businessDict["\(businessID)"] = ["name": String(business["name"])]
                    grandBusinessArray.addObject(businessDict)
                }
            }
        }
        completion(businessObject: grandBusinessArray)
        
        
        
//        parseYelpJSON(yelpBusinessDict) { (yelpBusinessArray) -> Void in
//            yelpBusinesses = yelpBusinessArray
//            
//            self.parseGPlacesJSON(googlePlaceDict) { (googlePlacesArray) -> Void in
//                googlePlaces = googlePlacesArray
//                
//                var businessDict: NSMutableDictionary!
//                
//                // Comparing business statements
//                for business in yelpBusinesses{
//                    for place in googlePlaces{
//                        let businessAddress = business["address"] as! String
//                        let placeAddress = place["address"] as! String
//                        let placePrefix = String(placeAddress.characters.prefix(5))
//                        
//                        if businessAddress.hasPrefix(placePrefix){
//                            let businessID = business["id"] as! String
//                            businessDict[businessID] = ["name": String(business["name"])]
//                        }
//                    }
//                }
//                completion(businessObject: businessDict)
//                
//            }
//        }
        
        
    }
    
}