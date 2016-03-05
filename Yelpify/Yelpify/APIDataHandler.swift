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
                        print("GRAND BUSINESS ARRAY")
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
    
    func parseYelpJSON(data: NSDictionary, completion: (yelpBusinessArray: [YelpBusiness]) -> Void){
        
        if data.count > 0 {
            
            var arrayOfYelpBusinesses: [YelpBusiness] = []
            
            if let businesses = data["businesses"] as? NSArray {
                
                if businesses.count > 0{
                    for business in businesses {
                        // Handle Address
                        
                        let businessID = business["id"] as! String
                        let businessName = business["name"] as! String
                        
                        var businessImageURL = ""
                        
                        if let imageURL = business["image_url"] as? String{
                            businessImageURL = imageURL
                        }
                        
                        var businessAddress = ""
                        
                        var businessLongitude: Double!
                        var businessLatitude: Double!
                        
                        if let businessLocation = business["location"] as? NSDictionary{
                            if let addressArray = businessLocation["address"] as? NSArray{
                                if addressArray.count > 0{
                                    businessAddress = addressArray[0] as! String
                                }else{
                                    if let displayAdressArray = businessLocation["display_address"] as? NSArray{
                                        businessAddress = displayAdressArray[0] as! String
                                    }
                                }
                            }
                            if let businessCoordinate = businessLocation["coordinate"] as? NSDictionary{
                                businessLatitude = businessCoordinate["latitude"] as? Double
                                businessLongitude = businessCoordinate["longitude"] as? Double
                            }
                            
                        }
                        
                        var businessZip = ""
                        var businessCity = ""
                        if let businessLocation = business["location"] as? NSDictionary{
                            businessZip = businessLocation["postal_code"] as! String
                            businessCity = businessLocation["city"] as! String
                        }
                        
                        let businessPhone = business["phone"] as? String
                        let businessDistance = business["distance"] as! Double
                        let businessCategory = business["categories"] as? NSArray
                        let businessRating = business["rating"] as! Double
                        
                        
                        var businessStatus: Bool? = true
                        
                        if let businessAvail = business["is_closed"] as? Int{
                            if businessAvail == 0{
                                businessStatus = true
                            }else{
                                businessStatus = false
                            }
                        }
                        
                        
                        let yelpBusinessObject = YelpBusiness(id: businessID, name: businessName, address: businessAddress, city: businessCity, zip: businessZip, phone: businessPhone, imageURL: businessImageURL, latitude: businessLatitude, longitude: businessLongitude, distance: businessDistance, rating: businessRating, categories: businessCategory!, status: businessStatus!)
                        
                        arrayOfYelpBusinesses.append(yelpBusinessObject)
                    }
                    
                    if debugPrint.BUSINESS_ARRAY == true{
                        
                        print("Yelp Businesses")
                        for business in arrayOfYelpBusinesses{
                            print(business.businessName)
                        }
                    }
                    
                    completion(yelpBusinessArray: arrayOfYelpBusinesses)
                    
                }else{
                    // Do this if no businesses show up
                    
                    completion(yelpBusinessArray: arrayOfYelpBusinesses)
                }
            }
        }
    }
    
    func parseGPlacesJSON(data: NSDictionary, completion: (googlePlacesArray: [GooglePlace]) -> Void){
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
                }else{
                    // If there are no results
                    completion(googlePlacesArray: arrayOfGPlaces)
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
        
        // businessChecked makes sure that if there is a match, the for loop is broken out of
        var businessAdded: [Bool] = []
        
        for business in yelpBusinessArray{
            arrayOfBusinesses.append(convertYelpObjectToBusinessObject(business))
            businessAdded.append(false)
        }
        
        for (index, business) in yelpBusinessArray.enumerate(){
            
            let searchName = business.businessName!
            let coordinates = [business.businessLatitude!, business.businessLongitude!]
            
            //            arrayOfBusinesses.append(self.convertYelpObjectToBusinessObject(business))
            //
            //            if index == yelpBusinessArray.count - 1{
            //                completion(businessObjects: arrayOfBusinesses)
            //            }
            
            gpClient.searchPlaceWithNameAndCoordinates(searchName, coordinates: coordinates, completion: { (JSONdata) -> Void in
                self.parseGPlacesJSON(JSONdata, completion: { (googlePlacesArray) -> Void in
                    
                    self.iterateThroughGPlacesArray(business, googlePlacesArray: googlePlacesArray, completion: { (businessObject) -> Void in
                        arrayOfBusinesses[index] = businessObject
                        //arrayOfBusinesses.insert(businessObject, atIndex: index)
                        
                        businessAdded[index] = true
                        
                        // Returns once all businesses have been added
                        if !businessAdded.contains(false){
                            completion(businessObjects: arrayOfBusinesses)
                        }
                    })
                })
                
            })
            
        }
        
    }
    
    private func iterateThroughGPlacesArray(business: YelpBusiness, googlePlacesArray: [GooglePlace], completion:(businessObject: Business) -> Void){
        if googlePlacesArray.count > 0{
            
            var placeAdded = false
            
            for place in googlePlacesArray{
                
                if placeAdded == false{
                    self.checkIfNamesAreSimilar(business, place: place, completion: { (namesMatch) -> Void in
                        
                        if namesMatch == true{
                            self.mergeYelpAndGoogleObjects(place, business: business, completion: { (businessObject) -> Void in
                                
                                completion(businessObject: businessObject)
                                placeAdded = true
                            })
                            
                        }else{
                            let businessObject = self.convertYelpObjectToBusinessObject(business)
                            completion(businessObject: businessObject)
                            placeAdded = true
                        }
                    })
                }else{
                    break
                }
                
            } // for loop closure
            
        }else{
            // NO MATCH : There are no results by Google Places API
            let businessObject = self.convertYelpObjectToBusinessObject(business)
            completion(businessObject: businessObject)
            //print("no results, empty place added")
        }
    }
    
    private func checkIfNamesAreSimilar(business: YelpBusiness, place: GooglePlace, completion:(namesMatch:Bool) -> Void){
        
        let yelpBusinessName = business.businessName!
        
        if yelpBusinessName.characters.count > 5{
            let charIndex = yelpBusinessName.startIndex.advancedBy(5)
            let nameSubstring = yelpBusinessName.substringToIndex(charIndex)
            
            if place.placeName!.hasPrefix(nameSubstring){
                
                completion(namesMatch: true)
                
            }else{
                // NO MATCH : The prefix is not matching
                completion(namesMatch: false)
            }
            
        }else{
            // NO MATCH : The character count is less than 5
            completion(namesMatch: false)
        }
        
    }
    
    private func convertYelpObjectToBusinessObject(business: YelpBusiness) -> Business{
        
        let yelpID = business.businessID
        let yelpAddress = business.businessAddress
        let yelpName = business.businessName
        let yelpImageURL = business.businessImageURL
        let yelpLat = business.businessLatitude
        let yelpLong = business.businessLongitude
        
        let gPlaceID = ""
        let gPlacePhotoRef = ""
        
        let businessObject = Business(name: yelpName, address: yelpAddress, city: "", zip: "", phone: "", imageURL: yelpImageURL, photoRef: gPlacePhotoRef, latitude: yelpLat, longitude: yelpLong, distance: 0, rating: 0, categories: [], status: true, businessID: yelpID, placeID: gPlaceID)
        
        return businessObject
        
    }
    
    private func mergeYelpAndGoogleObjects(place: GooglePlace, business: YelpBusiness, completion:(businessObject: Business)-> Void){
        
        let yelpID = business.businessID
        let yelpAddress = business.businessAddress
        let yelpName = business.businessName
        let yelpImageURL = business.businessImageURL
        let yelpLat = business.businessLatitude
        let yelpLong = business.businessLongitude
        let yelpDist = business.businessDistance
        let yelpZip = business.businessZip
        let yelpPhone = business.businessPhone
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