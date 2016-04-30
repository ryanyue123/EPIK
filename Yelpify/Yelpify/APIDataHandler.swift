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
    
    
    private func getDataFromUrl(url: NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    
//    
//    // Gets Yelp ID with Business Object // Returns ID
//    func getYelpID(business: Business, completion: (yelpID: String) -> Void){
//        yelpClient.searchBusinessesWithCoordinateAndAddress(String(business.businessLatitude), longitude: String(business.businessLongitude), address: business.businessAddress!) { (JSONdata) -> Void in
//            self.parseYelpForID(JSONdata, completion: { (yelpID) -> Void in
//                completion(yelpID: yelpID)
//            })
//        }
//    }
//    
//    // Parse Yelp for ID of FIRST BUSINESS // Returns ID
//    private func parseYelpForID(JSONdata: NSDictionary, completion: (yelpID: String) -> Void) {
//        if JSONdata.count > 0{
//            if let businesses = JSONdata["businesses"] as? NSArray {
//                let business = businesses[0]
//                let businessID = business["id"] as! String
//                
//                completion(yelpID: businessID)
//            }else{
//                // DO THIS WHEN THERE ARE NO RESULTS
//            }
//        }
//    }
//    
//    // Parse Yelp Business JSON // Returns YelpBusiness Object with [id, rating, phone, url, is_closed, review_count, categories, reviews[id, rating, exerpt, user[name]], 
//    private func parseYelpBusinessData(data: NSDictionary, completion: (yelpBusiness: YelpBusiness) -> Void){
//        
//    }
//    
//    // END DETAILED
//    
//    
//    func retrieveYelpBusinessFromBusinessObject(business:Business, completion: (yelpBusinessObject: YelpBusiness) -> Void){
//        getSingleYelpBusiness(createYelpParameters(business)) { (yelpBusinessObject) -> Void in
//            completion(yelpBusinessObject: yelpBusinessObject)
//        
//        }
//    }
//    
//    func createYelpParameters(businessObject: Business) -> Dictionary<String, String>{
//        let ll = String(businessObject.businessLatitude!) + "," + String(businessObject.businessLongitude!)
//        let name = businessObject.businessName!
//        return [
//            "ll": ll,
//            "term": name,
//            "radius_filter": "500",
//            "sort": "1"]
//    }
//    
//    
//    func getSingleYelpBusiness(yelpParameters: Dictionary<String, String>, completion: (yelpBusinessObject: YelpBusiness)-> Void){
//        
//        yelpClient.searchPlacesWithParameters(yelpParameters) { (result) -> Void in
//            self.parseSingleYelpBusiness(result, completion: { (yelpBusinessObject) -> Void in
//                completion(yelpBusinessObject: yelpBusinessObject)
//            })
//        }
//    }
    
//    func parseSingleYelpBusiness(data: NSDictionary, completion: (yelpBusinessObject: YelpBusiness) -> Void){
//        if data.count > 0 {
//            
//            if let businesses = data["businesses"] as? NSArray {
//                
//                if businesses.count > 0{
//                    // Handle Address
//                    
//                    let business = businesses[0]
//                    
//                    let businessID = business["id"] as! String
//                    let businessName = business["name"] as! String
//                    
//                    var businessImageURL = ""
//                    
//                    if let imageURL = business["image_url"] as? String{
//                        businessImageURL = imageURL
//                    }
//                    
//                    var businessAddress = ""
//                    
//                    var businessLongitude: Double!
//                    var businessLatitude: Double!
//                    
//                    if let businessLocation = business["location"] as? NSDictionary{
//                        if let addressArray = businessLocation["address"] as? NSArray{
//                            if addressArray.count > 0{
//                                businessAddress = addressArray[0] as! String
//                            }else{
//                                if let displayAdressArray = businessLocation["display_address"] as? NSArray{
//                                    businessAddress = displayAdressArray[0] as! String
//                                }
//                            }
//                        }
//                        if let businessCoordinate = businessLocation["coordinate"] as? NSDictionary{
//                            businessLatitude = businessCoordinate["latitude"] as? Double
//                            businessLongitude = businessCoordinate["longitude"] as? Double
//                        }
//                        
//                    }
//                    
//                    var businessZip = ""
//                    var businessCity = ""
//                    if let businessLocation = business["location"] as? NSDictionary{
//                        businessZip = businessLocation["postal_code"] as! String
//                        businessCity = businessLocation["city"] as! String
//                    }
//                    
//                    let businessPhone = business["phone"] as? String
//                    let businessDistance = business["distance"] as! Double
//                    let businessCategory = business["categories"] as? NSArray
//                    let businessRating = business["rating"] as! Double
//                    
//                    
//                    var businessStatus: Bool? = true
//                    
//                    if let businessAvail = business["is_closed"] as? Int{
//                        if businessAvail == 0{
//                            businessStatus = true
//                        }else{
//                            businessStatus = false
//                        }
//                    }
//                    
//                    
//                    let yelpBusinessObject = YelpBusiness(id: businessID, name: businessName, address: businessAddress, city: businessCity, zip: businessZip, phone: businessPhone, imageURL: businessImageURL, latitude: businessLatitude, longitude: businessLongitude, distance: businessDistance, rating: businessRating, categories: businessCategory!, status: businessStatus!)
//                    
//                    completion(yelpBusinessObject: yelpBusinessObject)
//                    
//                    
//                }else{
//                    // Do this if no businesses show up
//                    let yelpBusinessObject = YelpBusiness(id: nil, name: nil, address: nil, city: nil, zip: nil, phone: nil, imageURL: nil, latitude: nil, longitude: nil, distance: nil, rating: nil, categories: nil, status: nil)
//                    completion(yelpBusinessObject: yelpBusinessObject)
//                }
//            }
//        }
//        
//    }

//
//    func parseYelpJSON(data: NSDictionary, completion: (yelpBusinessArray: [YelpBusiness]) -> Void){
//        
//        if data.count > 0 {
//            
//            var arrayOfYelpBusinesses: [YelpBusiness] = []
//            
//            if let businesses = data["businesses"] as? NSArray {
//                
//                if businesses.count > 0{
//                    for business in businesses {
//                        // Handle Address
//                        
//                        let businessID = business["id"] as! String
//                        let businessName = business["name"] as! String
//                        
//                        var businessImageURL = ""
//                        
//                        if let imageURL = business["image_url"] as? String{
//                            businessImageURL = imageURL
//                        }
//                        
//                        var businessAddress = ""
//                        
//                        var businessLongitude: Double!
//                        var businessLatitude: Double!
//                        
//                        if let businessLocation = business["location"] as? NSDictionary{
//                            if let addressArray = businessLocation["address"] as? NSArray{
//                                if addressArray.count > 0{
//                                    businessAddress = addressArray[0] as! String
//                                }else{
//                                    if let displayAdressArray = businessLocation["display_address"] as? NSArray{
//                                        businessAddress = displayAdressArray[0] as! String
//                                    }
//                                }
//                            }
//                            if let businessCoordinate = businessLocation["coordinate"] as? NSDictionary{
//                                businessLatitude = businessCoordinate["latitude"] as? Double
//                                businessLongitude = businessCoordinate["longitude"] as? Double
//                            }
//                            
//                        }
//                        
//                        var businessZip = ""
//                        var businessCity = ""
//                        if let businessLocation = business["location"] as? NSDictionary{
//                            businessZip = businessLocation["postal_code"] as! String
//                            businessCity = businessLocation["city"] as! String
//                        }
//                        
//                        let businessPhone = business["phone"] as? String
//                        let businessDistance = business["distance"] as! Double
//                        let businessCategory = business["categories"] as? NSArray
//                        let businessRating = business["rating"] as! Double
//                        
//                        
//                        var businessStatus: Bool? = true
//                        
//                        if let businessAvail = business["is_closed"] as? Int{
//                            if businessAvail == 0{
//                                businessStatus = true
//                            }else{
//                                businessStatus = false
//                            }
//                        }
//                        
//                        
//                        let yelpBusinessObject = YelpBusiness(id: businessID, name: businessName, address: businessAddress, city: businessCity, zip: businessZip, phone: businessPhone, imageURL: businessImageURL, latitude: businessLatitude, longitude: businessLongitude, distance: businessDistance, rating: businessRating, categories: businessCategory!, status: businessStatus!)
//                        
//                        arrayOfYelpBusinesses.append(yelpBusinessObject)
//                    }
//                    
//                    if debugPrint.BUSINESS_ARRAY == true{
//                        
//                        print("Yelp Businesses")
//                        for business in arrayOfYelpBusinesses{
//                            print(business.businessName)
//                        }
//                    }
//                    
//                    completion(yelpBusinessArray: arrayOfYelpBusinesses)
//                    
//                }else{
//                    // Do this if no businesses show up
//                    
//                    completion(yelpBusinessArray: arrayOfYelpBusinesses)
//                }
//            }
//        }
//    }
    
    func parseGPlacesJSON(data: NSDictionary, completion: (businessArray: [Business]) -> Void){
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
                        
                        let placeRating = place["rating"] as? Double
                        
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
        
    }
    
    private func convertGooglePlaceObjectToBusinessObject(googlePlaceObject: GooglePlace) -> Business{
        let placeID = googlePlaceObject.placeID
        let placeAddress = googlePlaceObject.placeAddress
        let placeName = googlePlaceObject.placeName
        let photoRef = googlePlaceObject.placePhotoReference
        
        let businessObject = Business(name: placeName, address: placeAddress, city: nil, zip: nil, phone: nil, imageURL: nil, photoRef: photoRef, latitude: nil, longitude: nil, distance: nil, rating: nil, categories: nil, status: nil, businessID: nil, placeID: placeID)
        
        return businessObject
    }
}