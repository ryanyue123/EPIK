//
//  APIDataHandler.swift
//  Yelpify
//
//  Created by Jonathan Lam on 2/19/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//


// Grab Data from Google API
// Save data to Business Object

import Foundation
import UIKit
import SwiftyJSON

struct debugPrint{
    static var RAW_GOOGLE_JSON = false
    static var RAW_JSON = false
    static var BUSINESS_ARRAY = false
    static var GRAND_BUSINESS_ARRAY = false
}

class APIDataHandler {
    
    // DEBUG OPTIONS
    let PRINT_JSON = true
    
    var gpClient = GooglePlacesAPIClient()
    //var yelpClient = YelpAPIClient()
    //var locuClient = LocuAPIClient()
    
    /*
    NEW FLOW
    1) Take parameters for Google Places API
    2) Pass parameters to search in Google Places API
    3) Parse data into array of business objects
    4) Return array
    
    */
    
    func performAPISearch(googleParameters: Dictionary<String, String>, completion:(businessObjectArray: [Business]) -> Void) {
        
        gpClient.searchPlacesWithParameters(googleParameters) { (result) -> Void in
            self.parseGPlacesJSON(result, completion: { (businessArray) -> Void in
                completion(businessObjectArray: businessArray)
            })
        }
        
    }
    
    func performDetailedSearch(googleID: String, completion: (detailedGPlace: GooglePlaceDetail) -> Void){
        self.gpClient.searchPlaceWithID(googleID) { (JSONdata) in
            self.parseGoogleDetailedData(JSONdata, completion: { (detailedGPlace) in
                completion(detailedGPlace: detailedGPlace)
            })
        }
    }
    
    // MARK: - DETAILED REQUEST HANDLING (for use when cell in searchBusinessVC is clicked)
    
    func updateBusinessObject(business: Business, completion: (updatedBusinessObject: Business) -> Void){
        
        // GOOGLE API
        // Step 1 - Request Data from Google API by ID
        gpClient.searchPlaceWithID(business.gPlaceID!) { (JSONdata) -> Void in
            // Step 2 - Parse Google Detailed JSON
            self.parseGoogleDetailedData(JSONdata, completion: { (detailedGPlaceDict) -> Void in
                
            })
        }
        
//        // YELP API
//        // Step 1 - Retrive Yelp ID
//        self.getYelpID(business) { (yelpID) -> Void in
//            // Step 2 - Request Data from Yelp API by ID
//            self.yelpClient.getBusinessInformationOf(yelpID, successSearch: { (data, response) -> Void in
//                // Step 3 - Parse Yelp Detailed JSON
//                
//                }, failureSearch: { (error) -> Void in
//                    print(error)
//            })
//        }
//        // YELP API
//        // Step 1 - Request Data from Yelp API
//        yelpClient.searchBusinessesWithCoordinateAndAddress(String(business.businessLatitude), longitude: String(business.businessLongitude), address: business.businessAddress!) { (JSONdata) -> Void in
//            
//            
//            // Step 2 - Parse Yelp JSON for first result
//            
//        }
//        
        // When finished, merge both
    }
    
    // Step 1 - Retrived Data
    // Handled in GoogleAPIClient

    // Step 2 - Parse Detailed Info // Returns a NSDictionary containing [phone, price, rating, reviews]
    func parseGoogleDetailedData(data: NSDictionary, completion: (detailedGPlace: GooglePlaceDetail) -> Void){
        if data.count > 0 {
            if let place = data["result"] as? NSDictionary{
                if place.count > 0{
                    
                    var placeCity = ""
                    if let addressComponents = place["address_components"] as? NSArray{
                        //let addressCity = addressComponents[2] as! NSDictionary
                    }
                    
                    let placeFormattedAddress = place["formatted_address"] as! String
                    
                    let placePhone = place["formatted_phone_number"] as! String
                    let placeIntlPhone = place["international_phone_number"] as! String
                    
                    var placeWeekdayText = []
                    if let placeHours = place["opening_hours"] as? NSDictionary{
                        placeWeekdayText = placeHours["weekday_text"] as! NSArray
                        // let placePermanentlyClosed = place["permanently_closed"] as! Bool
                    }
                    
                    var placePhotoRefArray: [String] = []
                    if let placePhotoArray = place["photos"] as? NSArray{
                        for photo in placePhotoArray{
                            placePhotoRefArray.append(photo["photo_reference"] as! String)
                        }
                        //placePhotoRefArray = placePhotoArray
                    }
                    
                    let placePrice = place["price_level"] as? Int
                    let placeRating = place["rating"] as? Double
                    
                    let placeReviews = place["reviews"] as? NSArray
                    
                    let placeTypes = place["types"] as? NSArray
                    
                    let placeWebsite = place["url"] as? String
                    
                    completion(detailedGPlace: GooglePlaceDetail(_address: placeFormattedAddress, _phone: placePhone, _website: placeWebsite, _hours: placeWeekdayText, _priceRating: placePrice, _rating: placeRating, _reviews: placeReviews, _photos: placePhotoRefArray))
                }
            }
        
        }
    }
    


    
    func parseGPlacesJSON(data: NSData, completion: (businessArray: [Business]) -> Void){
        let json = JSON(data: data)
        if let places = json["results"].array{
            if places.count > 0{
                
                var arrayOfBusinesses: [Business] = []
                
                for place in places{
                    var businessObject = Business()
                    
                    if let id = place["place_id"].string{
                        businessObject.gPlaceID = id
                    }
                    if let name = place["name"].string{
                        businessObject.businessName = name
                    }
                    if let address = place["vicinity"].string{
                        businessObject.businessAddress = address
                    }
                    if let photoRef = place["photos"][0]["photo_reference"].string{
                        businessObject.businessPhotoReference = photoRef
                    }
                    if let rating = place["rating"].double{
                        businessObject.businessRating = rating
                    }
                    
                    if let placeLocation = place["geometry"]["location"].dictionary{
                        if let placeLat = placeLocation["lat"]!.double{
                            businessObject.businessLatitude = placeLat
                        }
                        if let placeLng = placeLocation["lng"]!.double{
                            businessObject.businessLongitude = placeLng
                        }
                    }
                    
                    arrayOfBusinesses.append(businessObject)
                }
                
                completion(businessArray: arrayOfBusinesses)
            }
        }
    }
    
    /*func parseGPlacesJSON(data: NSDictionary, completion: (businessArray: [Business]) -> Void){
        if data.count > 0 {
            //var arrayOfGPlaces: [GooglePlace] = []
            var arrayOfBusinesses: [Business] = []
            
            if let places = data["results"] as? NSArray{
                if places.count > 0 {
                    for place in places{
                        
                        let placeID = place["place_id"] as! String
                        let placeName = place["name"] as! String
                        let placeAddress = place["vicinity"] as! String
                        
                        var placePhotoRef = ""
                        if let photos = place["photos"] as? NSArray{
                            placePhotoRef = photos[0]["photo_reference"] as! String
                        }
                        
                        var placeRating = place["rating"] as? Double
                        
                        
                        var placeLat: Double?
                        var placeLng: Double?
                        if let placeGeometry = place["geometry"] as? NSDictionary{
                            if let placeLocation = placeGeometry["location"] as? NSDictionary{
                                placeLat = placeLocation["lat"] as? Double
                                placeLng = placeLocation["lng"] as? Double
                            }
                        }
                        
                        // Create GooglePlace Object
                        //let placeObject = GooglePlace(id: placeID, name: placeName, address: placeAddress, photoRef: placePhotoRef)
                        
                        // Create Business Object
                        let businessObject = Business(name: placeName, address: placeAddress, city: nil, zip: nil, phone: nil, imageURL: nil, photoRef: placePhotoRef, latitude: placeLat, longitude: placeLng, distance: nil, rating: placeRating, categories: nil, status: nil, businessID: nil, placeID: placeID)
                        
                        arrayOfBusinesses.append(businessObject)
                        
                        //arrayOfGPlaces.append(placeObject)
                    }
                }else{
                    // If there are no results
                    completion(businessArray: arrayOfBusinesses)
                }
                
                completion(businessArray: arrayOfBusinesses)
                
                //                if debugPrint.BUSINESS_ARRAY == true{
                //                    print(arrayOfGPlaces)
                //                }
                
            }else{
                // Do this if no places found in data
                completion(businessArray: arrayOfBusinesses)
            }
            
        }
        
    }*/
    
//    private func convertGooglePlaceObjectToBusinessObject(googlePlaceObject: GooglePlace) -> Business{
//        let placeID = googlePlaceObject.placeID
//        let placeAddress = googlePlaceObject.placeAddress
//        let placeName = googlePlaceObject.placeName
//        let photoRef = googlePlaceObject.placePhotoReference
//        
//        let businessObject = Business(name: placeName, address: placeAddress, city: nil, zip: nil, phone: nil, imageURL: nil, photoRef: photoRef, latitude: nil, longitude: nil, distance: nil, rating: nil, categories: nil, status: nil, businessID: nil, placeID: placeID)
//        
//        return businessObject
//    }
}