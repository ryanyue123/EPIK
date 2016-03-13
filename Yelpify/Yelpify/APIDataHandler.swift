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
        
//        yelpClient.searchPlacesWithParameters(yelpParameters) { (result) -> Void in
//            
//            self.parseYelpJSON(result, completion: { (yelpBusinessArray) -> Void in
//                
//                self.matchYelpBusinessesWithGPlaces(yelpBusinessArray, completion: { (businessObjects) -> Void in
//                    completion(businessObjectArray: businessObjects)
//                    
//                    if debugPrint.GRAND_BUSINESS_ARRAY == true{
//                        print("GRAND BUSINESS ARRAY")
//                        for business in businessObjects{
//                            print(business.businessName)
//                        }
//                    }
//                })
//            })
//            
//            if debugPrint.RAW_JSON == true{
//                print("YELP JSON:\n", result)
//            }
//            
//        }
    }
    func retrieveYelpBusinessFromBusinessObject(business:Business, completion: (yelpBusinessObject: YelpBusiness) -> Void){
        getSingleYelpBusiness(createYelpParameters(business)) { (yelpBusinessObject) -> Void in
            completion(yelpBusinessObject: yelpBusinessObject)
        
        }
    }
    
    func createYelpParameters(businessObject: Business) -> Dictionary<String, String>{
        let ll = String(businessObject.businessLatitude!) + "," + String(businessObject.businessLongitude!)
        let name = businessObject.businessName!
        return [
            "ll": ll,
            "term": name,
            "radius_filter": "500",
            "sort": "1"]
    }
    
    
    func getSingleYelpBusiness(yelpParameters: Dictionary<String, String>, completion: (yelpBusinessObject: YelpBusiness)-> Void){
        
        yelpClient.searchPlacesWithParameters(yelpParameters) { (result) -> Void in
            self.parseSingleYelpBusiness(result, completion: { (yelpBusinessObject) -> Void in
                completion(yelpBusinessObject: yelpBusinessObject)
            })
        }
    }
    
    func parseSingleYelpBusiness(data: NSDictionary, completion: (yelpBusinessObject: YelpBusiness) -> Void){
        if data.count > 0 {
            
            if let businesses = data["businesses"] as? NSArray {
                
                if businesses.count > 0{
                    // Handle Address
                    
                    let business = businesses[0]
                    
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
                    
                    completion(yelpBusinessObject: yelpBusinessObject)
                    
                    
                }else{
                    // Do this if no businesses show up
                    let yelpBusinessObject = YelpBusiness(id: nil, name: nil, address: nil, city: nil, zip: nil, phone: nil, imageURL: nil, latitude: nil, longitude: nil, distance: nil, rating: nil, categories: nil, status: nil)
                    completion(yelpBusinessObject: yelpBusinessObject)
                }
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
                        let businessObject = Business(name: placeName, address: placeAddress, city: nil, zip: nil, phone: nil, imageURL: nil, photoRef: placePhotoRef, latitude: placeLat, longitude: placeLng, distance: nil, rating: nil, categories: nil, status: nil, businessID: nil, placeID: placeID)
                        
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
//    
//    private func matchYelpBusinessesWithGPlaces(yelpBusinessArray: [YelpBusiness], completion: (businessObjects: [Business]) -> Void){
//        
//        var arrayOfBusinesses: [Business] = []
//        
//        // businessChecked makes sure that if there is a match, the for loop is broken out of
//        var businessAdded: [Bool] = []
//        
//        for business in yelpBusinessArray{
//            arrayOfBusinesses.append(convertYelpObjectToBusinessObject(business))
//            businessAdded.append(false)
//        }
//        
//        for (index, business) in yelpBusinessArray.enumerate(){
//            
//            let searchName = business.businessName!
//            let coordinates = [business.businessLatitude!, business.businessLongitude!]
//            
//            //            arrayOfBusinesses.append(self.convertYelpObjectToBusinessObject(business))
//            //
//            //            if index == yelpBusinessArray.count - 1{
//            //                completion(businessObjects: arrayOfBusinesses)
//            //            }
//            
//            gpClient.searchPlaceWithNameAndCoordinates(searchName, coordinates: coordinates, completion: { (JSONdata) -> Void in
//                self.parseGPlacesJSON(JSONdata, completion: { (googlePlacesArray) -> Void in
//                    
//                    self.iterateThroughGPlacesArray(business, googlePlacesArray: googlePlacesArray, completion: { (businessObject) -> Void in
//                        arrayOfBusinesses[index] = businessObject
//                        //arrayOfBusinesses.insert(businessObject, atIndex: index)
//                        
//                        businessAdded[index] = true
//                        
//                        // Returns once all businesses have been added
//                        if !businessAdded.contains(false){
//                            completion(businessObjects: arrayOfBusinesses)
//                        }
//                    })
//                })
//                
//            })
//            
//        }
//        
//    }
//    
//    private func iterateThroughGPlacesArray(business: YelpBusiness, googlePlacesArray: [GooglePlace], completion:(businessObject: Business) -> Void){
//        if googlePlacesArray.count > 0{
//            
//            var placeAdded = false
//            
//            for place in googlePlacesArray{
//                
//                if placeAdded == false{
//                    self.checkIfNamesAreSimilar(business, place: place, completion: { (namesMatch) -> Void in
//                        
//                        if namesMatch == true{
//                            self.mergeYelpAndGoogleObjects(place, business: business, completion: { (businessObject) -> Void in
//                                
//                                completion(businessObject: businessObject)
//                                placeAdded = true
//                            })
//                            
//                        }else{
//                            let businessObject = self.convertYelpObjectToBusinessObject(business)
//                            completion(businessObject: businessObject)
//                            placeAdded = true
//                        }
//                    })
//                }else{
//                    break
//                }
//                
//            } // for loop closure
//            
//        }else{
//            // NO MATCH : There are no results by Google Places API
//            let businessObject = self.convertYelpObjectToBusinessObject(business)
//            completion(businessObject: businessObject)
//            //print("no results, empty place added")
//        }
//    }
//    
//    private func checkIfNamesAreSimilar(business: YelpBusiness, place: GooglePlace, completion:(namesMatch:Bool) -> Void){
//        
//        let yelpBusinessName = business.businessName!
//        
//        if yelpBusinessName.characters.count > 5{
//            let charIndex = yelpBusinessName.startIndex.advancedBy(5)
//            let nameSubstring = yelpBusinessName.substringToIndex(charIndex)
//            
//            if place.placeName!.hasPrefix(nameSubstring){
//                
//                completion(namesMatch: true)
//                
//            }else{
//                // NO MATCH : The prefix is not matching
//                completion(namesMatch: false)
//            }
//            
//        }else{
//            // NO MATCH : The character count is less than 5
//            completion(namesMatch: false)
//        }
//        
//    }
//    
//    private func convertYelpObjectToBusinessObject(business: YelpBusiness) -> Business{
//        
//        let yelpID = business.businessID
//        let yelpAddress = business.businessAddress
//        let yelpName = business.businessName
//        let yelpImageURL = business.businessImageURL
//        let yelpLat = business.businessLatitude
//        let yelpLong = business.businessLongitude
//        
//        let gPlaceID = ""
//        let gPlacePhotoRef = ""
//        
//        let businessObject = Business(name: yelpName, address: yelpAddress, city: "", zip: "", phone: "", imageURL: yelpImageURL, photoRef: gPlacePhotoRef, latitude: yelpLat, longitude: yelpLong, distance: 0, rating: 0, categories: [], status: true, businessID: yelpID, placeID: gPlaceID)
//        
//        return businessObject
//        
//    }
//    
//    private func mergeYelpAndGoogleObjects(place: GooglePlace, business: YelpBusiness, completion:(businessObject: Business)-> Void){
//        
//        let yelpID = business.businessID
//        let yelpAddress = business.businessAddress
//        let yelpName = business.businessName
//        let yelpImageURL = business.businessImageURL
//        let yelpLat = business.businessLatitude
//        let yelpLong = business.businessLongitude
//        let yelpDist = business.businessDistance
//        let yelpZip = business.businessZip
//        let yelpPhone = business.businessPhone
//        let yelpCity = business.businessCity
//        let yelpCategor = business.businessCategories
//        let yelpStatus = business.businessStatus
//        let yelpRating = business.businessRating
//        
//        let gPlaceID = place.placeID
//        let gPlacePhotoRef = place.placePhotoReference
//        
//        let businessObject = Business(name: yelpName, address: yelpAddress, city: yelpCity, zip: yelpZip, phone: yelpPhone, imageURL: yelpImageURL, photoRef: gPlacePhotoRef, latitude: yelpLat, longitude: yelpLong, distance: yelpDist, rating: yelpRating, categories: yelpCategor, status: yelpStatus, businessID: yelpID, placeID: gPlaceID)
//        
//        completion(businessObject: businessObject)
//        
//    }
//    
//    var iterationCount = 0
//    
//    private func binarySearch(arrayOfInt: [Int], searchInt: Int, counterOn: Bool) -> Int{
//        var updatedList = arrayOfInt.sort()
//        var indexList: [Int] = []
//        
//        for item in 0...(updatedList.count - 1){
//            indexList.append(item)
//        }
//        
//        while true {
//            if updatedList.count > 1{
//                let middleIndex: Int = Int(round(Double(updatedList.count/2)))
//                
//                if updatedList[middleIndex] == searchInt {
//                    return indexList[middleIndex]
//                    
//                }else if searchInt > updatedList[middleIndex]{
//                    updatedList = Array(updatedList[middleIndex..<updatedList.count])
//                    indexList = Array(indexList[middleIndex..<indexList.count])
//                    iterationCount++
//                    
//                }else if searchInt < updatedList[middleIndex]{
//                    updatedList = Array(updatedList[0..<middleIndex])
//                    indexList = Array(indexList[0..<middleIndex])
//                    iterationCount++
//                }
//                
//            }else if searchInt == updatedList[0]{
//                return 0
//            }else{
//                return -1
//            }
//            
//        }
//    }
    
}