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
}

class APIDataHandler {
    
    // DEBUG OPTIONS
    let PRINT_JSON = true
    
    var gpClient = GooglePlacesAPIClient()
    var yelpClient = YelpAPIClient()
    //var locuClient = LocuAPIClient()
    
    /*
    
    FLOW
    1) Search through the Yelp, Google, and Locu API
    2) Create a master Business Object with data from API
    3) Return Business Object
    
    */
    
    func performAPISearch(yelpParameters: Dictionary<String, String>, gpParameters: Dictionary<String, String>, completion: (businessObject: [NSDictionary]) -> Void) {

        yelpClient.searchPlacesWithParameters(yelpParameters) { (result) -> Void in
            
            self.parseYelpJSON(result) { (yelpBusinessArray) -> Void in
                
            }
            
            if debugPrint.RAW_JSON == true{
                print("YELP JSON:\n", result)
            }
        }
        
        gpClient.searchPlacesWithParameters(gpParameters) { (result) -> Void in
            
            self.parseGPlacesJSON(result) { (googlePlacesArray) -> Void in
                
            }
            
            if debugPrint.RAW_JSON == true{
                print("GOOGLE PLACES JSON:\n", result)
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
    private func combineJSONData(yelpBusinessDict: NSDictionary, googlePlaceDict: NSDictionary, completion: (businessObject: Business) -> Void){
        
        var yelpBusinesses: NSArray! = []
        var googlePlaces: NSArray! = []
        
        parseYelpJSON(yelpBusinessDict) { (yelpBusinessArray) -> Void in
            yelpBusinesses = yelpBusinessArray
        }
        
        parseGPlacesJSON(googlePlaceDict) { (googlePlacesArray) -> Void in
            googlePlaces = googlePlacesArray
        }
        
        // Comparing business statements
        
    }
    
}