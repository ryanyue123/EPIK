//
//  APIDataHandler.swift
//  Yelpify
//
//  Created by Jonathan Lam on 2/19/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import Foundation

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
    
    func performAPISearch(yelpParameters: Dictionary<String, String>, completion:(businessObjectArray: [Business]) -> Void) {

        yelpClient.searchPlacesWithParameters(yelpParameters) { (result) -> Void in
            
            self.parseYelpJSON(result, completion: { (yelpBusinessArray) -> Void in
                self.matchYelpBusinessesWithGPlaces(yelpBusinessArray, completion: { (businessObjects) -> Void in
                    completion(businessObjectArray: businessObjects)
                    
                    if debugPrint.GRAND_BUSINESS_ARRAY == true{
                        for business in businessObjects{
                            print(business.businessName)
                        }
                    }
                })
            })
            
            if debugPrint.RAW_JSON == true{
                print("YELP JSON:\n", result)
            }
        
        }
    }
    
    private func parseYelpJSON(data: NSDictionary, completion: (yelpBusinessArray: [YelpBusiness]) -> Void){
        
        if data.count > 0 {
            
            var arrayOfYelpBusinesses: [YelpBusiness] = []
            
            if let businesses = data["businesses"] as? NSArray {
                if businesses.count > 0{
                    for business in businesses {
                        // Handle Address
                        
                        let businessID = business["id"] as! String
                        let businessName = business["name"] as! String
                        let businessImageURL = business["image_url"] as! String
                        
                        var businessAddress = ""
                        
                        var businessLongitude: Double!
                        var businessLatitude: Double!
                        
                        if let businessLocation = business["location"] as? NSDictionary{
                            let displayAddress = businessLocation["address"] as? NSArray
                            businessAddress = displayAddress![0] as! String
                            
                            if let businessCoordinate = businessLocation["coordinate"] as? NSDictionary{
                                businessLatitude = businessCoordinate["latitude"] as! Double
                                businessLongitude = businessCoordinate["longitude"] as! Double
                            }
            
                        }
                        
                        let businessPhone = business["phone"] as! String
                        var businessZip = ""
                        var businessCity = ""
                        if let businessLocation = business["location"] as? NSDictionary{
                            businessZip = business["postal_code"] as! String
                            businessCity = businiess["city"] as! String
                        }
                        let businessDistance = business["distance"] as! String
                        let businessCategory = business["categories"] as? NSArray
                        let businessRating = business["rating"] as! Double
                        var businessStatus: Bool!
                        
                        if let businessAvail = String(business["is_claimed"]){
                            if businessAvail == String(1){
                                businessStatus = true
                            }else{
                                businessStatus = false
                            }
                        }

                
                        let yelpBusinessObject = YelpBusiness(id: businessID, name: businessName, address: businessAddress, city: businessCity, zip: businessZip, phone: businessPhone, imageURL: businessImageURL, latitude: businessLatitude, longitude: businessLongitude, distance: businessDistance, rating: businessRating, categories: businessCategory, status: businessStatus)
                        
                        arrayOfYelpBusinesses.append(yelpBusinessObject)
                    }
                    
                    if debugPrint.BUSINESS_ARRAY == true{
                        
                        print("Yelp Businesses")
                        for business in arrayOfYelpBusinesses{
                            print(business.businessName)
                            print("\n")
                        }
                    }
                    
                    completion(yelpBusinessArray: arrayOfYelpBusinesses)
                        
                }else{
                    // Do this if no businesses show up
                }
            }
        }
    }
    
    private func parseGPlacesJSON(data: NSDictionary, completion: (googlePlacesArray: [GooglePlace]) -> Void){
        if data.count > 0 {
            var arrayOfGPlaces: [GooglePlace] = []
            
            if let places = data["results"] as? NSArray{
                if places.count > 0 {
                    for place in places{
                        
                        let placeID = place["place_id"] as! String
                        let placeName = place["name"] as! String
                        let placeAddress = place["formatted_address"] as! String
                        
                        var placePhotoRef = ""
                        if let photos = place["photos"] as? NSArray{
                            placePhotoRef = photos[0]["photo_reference"] as! String
                        }
                        
                        // Create GooglePlace Object
                        let placeObject = GooglePlace(id: placeID, name: placeName, address: placeAddress, photoRef: placePhotoRef)
                        
                        arrayOfGPlaces.append(placeObject)
                    }
                }
                
                completion(googlePlacesArray: arrayOfGPlaces)
                
//                if debugPrint.BUSINESS_ARRAY == true{
//                    print(arrayOfGPlaces)
//                }
                
            }else{
                // Do this if no places found in data
                completion(googlePlacesArray: arrayOfGPlaces)
            }
            
        }
        
    }
    
    private func matchYelpBusinessesWithGPlaces(yelpBusinessArray: [YelpBusiness], completion: (businessObjects: [Business]) -> Void){
        
        var arrayOfBusinesses: [Business] = []
        
        for (index, element) in yelpBusinessArray.enumerate(){
            let business = element
            
            let searchName = business.businessName
            let coordinates = [business.businessLatitude, business.businessLongitude]
            
            gpClient.searchPlaceWithNameAndCoordinates(searchName, coordinates: coordinates, completion: { (JSONdata) -> Void in
                self.parseGPlacesJSON(JSONdata, completion: { (googlePlacesArray) -> Void in
                    
                    if googlePlacesArray.count > 0{
                        
                        let place = googlePlacesArray[0]
                        
                        if searchName.characters.count > 5{
                            let charIndex = searchName.startIndex.advancedBy(5)
                            let nameSubstring = searchName.substringToIndex(charIndex)
                            
                            if place.placeName.hasPrefix(nameSubstring){
                                
                                self.mergeYelpAndGoogleObjects(place, business: business, completion: { (businessObject) -> Void in
                                    
                                    arrayOfBusinesses.append(businessObject)
                                    
                                    if index == (yelpBusinessArray.count - 1){
                                        completion(businessObjects: arrayOfBusinesses)
                                    }
                                })
                                
                            }
                        }else{
                            // ADD: If name is less than 5 characters, do this
                            print("no match")
                        }

//                        for place in googlePlacesArray{
//                            if searchName.characters.count > 5{
//                                let index = searchName.startIndex.advancedBy(5)
//                                let nameSubstring = searchName.substringToIndex(index)
//                                
//                                if place.placeName.hasPrefix(nameSubstring){
//                                    
//                                    self.mergeYelpAndGoogleObjects(place, business: business, completion: { (businessObject) -> Void in
//                                        
//                                        arrayOfBusinesses.append(businessObject)
//                                        
//                                    })
//                                    
//                                }
//                            }else{
//                                // ADD: If name is less than 5 characters, do this
//                            }
//                        }
                        //completion(businessObjects: arrayOfBusinesses)
                        
                    } else{
                        // ADD: If google search turns up empty, return empty values for GPlaces
                        
                        //completion(businessObjects: arrayOfBusinesses)
                    }
                })

            })
            
        }
    
    }
    
    private func createBusinessObjectFromGoogleMatches(gPlaceArray: [GooglePlace], searchName: String, coordinates: NSArray){
        
    }
    
    private func mergeYelpAndGoogleObjects(place: GooglePlace, business: YelpBusiness, completion: (businessObject: Business) -> Void){
        
        let yelpID = business.businessID
        let yelpAddress = business.businessAddress
        let yelpName = business.businessName
        let yelpImageURL = business.businessImageURL
        let yelpLat = business.businessLatitude
        let yelpLong = business.businessLongitude
        let yelpDist = business.businessDistance
        let yelpZip = business.businessZip
        let yelpCity = business.businessCity
        let yelpCategor = business.businessCategories
        let yelpStatus = business.businessStatus
        let yelpRating = business.businessRating
        let gPlaceID = place.placeID
        let gPlacePhotoRef = place.placePhotoReference
        
        let businessObject = Business(name: yelpName, address: yelpAddress, city: yelpCity, zip: yelpZip, phone: yelpPhone, imageURL: yelpImageURL, photoRef: gPlacePhotoRef, latitude: yelpLat, longitude: yelpLong, distance: yelpDist, rating: yelpRating, categories: yelpCategor, status: yelpStatus, businessID: yelpID, placeID: gPlaceID)
        
        completion(businessObject: businessObject)
        
    }
    
    var iterationCount = 0
    
    private func binarySearch(arrayOfInt: [Int], searchInt: Int, counterOn: Bool) -> Int{
        var updatedList = arrayOfInt.sort()
        var indexList: [Int] = []
        
        for item in 0...(updatedList.count - 1){
            indexList.append(item)
        }
        
        while true {
            if updatedList.count > 1{
                let middleIndex: Int = Int(round(Double(updatedList.count/2)))
                
                if updatedList[middleIndex] == searchInt {
                    return indexList[middleIndex]
                    
                }else if searchInt > updatedList[middleIndex]{
                    updatedList = Array(updatedList[middleIndex..<updatedList.count])
                    indexList = Array(indexList[middleIndex..<indexList.count])
                    iterationCount++
                    
                }else if searchInt < updatedList[middleIndex]{
                    updatedList = Array(updatedList[0..<middleIndex])
                    indexList = Array(indexList[0..<middleIndex])
                    iterationCount++
                }
                
            }else if searchInt == updatedList[0]{
                return 0
            }else{
                return -1
            }

        }
    }
    
}