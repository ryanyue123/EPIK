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
    
    func performAPISearch(yelpParameters: Dictionary<String, String>, completion: (masterBusinessArray: NSArray, masterBusinessObjArray: [Business]) -> Void) {
        
        var yBusinessArray: NSArray!
        //var gPlacesDict: NSDictionary!
        var resultBusinessArray: NSArray!
        var resultBusinessObjectArray: [Business]!
        
        // result is NSDictionary

        yelpClient.searchPlacesWithParameters(yelpParameters) { (result) -> Void in
            
            self.parseYelpJSON(result) { (yelpBusinessArray) -> Void in
                yBusinessArray = yelpBusinessArray
            }
            
            if debugPrint.RAW_JSON == true{
                print("YELP JSON:\n", result)
            }
            
            self.matchYelpBusinessesWithGPlaces(yBusinessArray, completion: { (businessArray, businessObjectArray) -> Void in
                resultBusinessArray = businessArray
                resultBusinessObjectArray = businessObjectArray
                
                completion(masterBusinessArray: resultBusinessArray, masterBusinessObjArray: resultBusinessObjectArray)
    
                
                if debugPrint.GRAND_BUSINESS_ARRAY == true{
                    print(resultBusinessArray)
                }
            })
            
//            self.gpClient.searchPlacesWithParameters(gpParameters) { (result) -> Void in
//                
//                self.parseGPlacesJSON(result) { (googlePlacesArray) -> Void in
//                    gPlacesDict = googlePlacesArray
//                }
//                
//                if debugPrint.RAW_JSON == true{
//                    print("GOOGLE PLACES JSON:\n", result)
//                }
//                
////                // Create business object
////                self.combineJSONData(yBusinessArray, googlePlaceDict: gPlacesDict, completion: { (businessObject) -> Void in
////                    let masterBusinessArray = businessObject
////                    
////                    completion(masterBusinessArray: masterBusinessArray as! [NSDictionary])
////                    
////                    if debugPrint.GRAND_BUSINESS_ARRAY == true{
////                        print(masterBusinessArray)
////                    }
////                    
////                })
//                
//            }
//        }
        }
    }
    
    private func parseYelpJSON(data: NSDictionary, completion: (yelpBusinessArray: NSArray) -> Void){
        if data.count > 0 {
            
            var arrayOfYelpBusinesses: NSMutableArray! = []
            
            if let businesses = data["businesses"] as? NSArray {
                if businesses.count > 0{
                    for business in businesses {
                        // Handle Address
                        
                        let businessID = business["id"] as! String
                        
                        let businessImageURL = business["image_url"] as! String
                        
                        var businessAddress = ""
                        
                        var businessLongitude: Double!
                        var businessLatitude: Double!
                        var businessLatPlusLong: Double!
                        
                        var businessPrefixInt: Int!
                        if let businessLocation = business["location"] as? NSDictionary{
                            businessAddress = businessLocation["address"]![0] as! String
                            let businessPref = String(businessAddress.characters.prefix(4))
                            if let businessPrefInt = Int(businessPref){
                                businessPrefixInt = businessPrefInt
                            }else{
                                businessPrefixInt = -1
                            }
                            if let businessCoordinate = businessLocation["coordinate"] as? NSDictionary{
                                businessLatitude = businessCoordinate["latitude"] as! Double
                                businessLongitude = businessCoordinate["longitude"] as! Double
                                businessLatPlusLong = businessLatitude + businessLongitude
                            }
            
                        }
                        
                        // Handle Name
                        let businessName = business["name"] as! String
                        
                        
                        arrayOfYelpBusinesses.addObject(["businessPrefixInt": businessPrefixInt, "businessID": businessID, "address": businessAddress, "name": businessName, "businessLatLong": [businessLatitude, businessLongitude], "businessLatPlusLong": businessLatPlusLong, "businessImageURL": businessImageURL])
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
    
    private func parseGPlacesJSON(data: NSDictionary, completion: (googlePlaceDictionary: NSDictionary) -> Void){
        if data.count > 0 {
            var dictOfGPlace = NSMutableDictionary()
            
            if let places = data["results"] as? NSArray {
                if places.count > 0 {
                    let place = places[0]
                    
                    let placeID = place["place_id"] as! String
                    let placeName = place["name"] as! String
                    let placeAddress = place["vicinity"] as! String
                    let placePrefix = String(placeAddress.characters.prefix(4))

                    var placePhotoRef = ""
                    if let photos = place["photos"] as? NSArray{
                        placePhotoRef = photos[0]["photo_reference"] as! String
                    }

                    var placeLatitude: Double!
                    var placeLongitude: Double!
                    var placeLatPlusLong: Double!

                    if let placeGeometry = place["geometry"] as? NSDictionary{
                        if let placeLocation = placeGeometry["location"] as? NSDictionary{
                            placeLatitude = placeLocation["lat"] as! Double
                            placeLongitude = placeLocation["lng"] as! Double
                            placeLatPlusLong = placeLatitude + placeLongitude

                        }
                    }
                    
                    dictOfGPlace = ["placeID": placeID ,"address": placeAddress, "name": placeName, "placePhotoReference": placePhotoRef, "placeLatLong": [placeLatitude, placeLongitude], "placeLatPlusLong": placeLatPlusLong]
                    
                    if debugPrint.BUSINESS_ARRAY == true{
                        print(dictOfGPlace)
                        
                    }
                    
                    completion(googlePlaceDictionary: dictOfGPlace)
                }
            }
        }
    }
    
    private func matchYelpBusinessesWithGPlaces(yelpBusinessArray: NSArray, completion: (businessArray: NSArray, businessObjectArray: [Business]) -> Void){
        
        let arrayOfBusinesses = NSMutableArray()
        var arrayOfBusinessObjects = [Business]()
        
        for businessIndex in 0...(yelpBusinessArray.count - 1){
            //let address = business["address"] as! String
            
            let business = yelpBusinessArray[businessIndex]
            
            let name = business["name"] as! String
            //let finalAddress = address + name
            
            gpClient.searchPlaceWithName(name, completion: { (result) -> Void in
                self.parseGPlacesJSON(result, completion: { (googlePlaceDictionary) -> Void in
                    
                    //print(googlePlaceDictionary)
                    self.mergeDataOfSingleBusiness(business as! NSDictionary, googlePlaceDict: googlePlaceDictionary, completion: { (businessObject, businessObj) -> Void in
                        
                        arrayOfBusinesses.addObject(businessObject)
                        arrayOfBusinessObjects.append(businessObj)
                        
                        if businessIndex == (yelpBusinessArray.count - 1){
                            completion(businessArray: arrayOfBusinesses, businessObjectArray: arrayOfBusinessObjects)
                        }
                    })
                })
            })
    
            
        }
    }
    
    // example of businessObject -> {yelp-id : { name: McDonalds, address: 123 Hamburger St. } }
    private func mergeDataOfSingleBusiness(yelpBusinessDict: NSDictionary, googlePlaceDict: NSDictionary, completion: (businessObject: NSDictionary, businessObj: Business) -> Void){
        
        let businessDict = NSMutableDictionary()
        
        let yelpID = yelpBusinessDict["businessID"] as! String
        let yelpAddress = yelpBusinessDict["address"] as! String
        let yelpName = yelpBusinessDict["name"] as! String
        let yelpImageURL = yelpBusinessDict["businessImageURL"] as! String
        
        let gPlaceID = googlePlaceDict["placeID"] as! String
        let gPlaceAddress = googlePlaceDict["address"] as! String
        let gPlaceName = googlePlaceDict["name"] as! String
        let gPlacePhotoRef = googlePlaceDict["placePhotoReference"] as! String
        
        businessDict["\(yelpID)"] = ["address": yelpAddress, "name": yelpName, "photoReference": gPlacePhotoRef, "gPlaceID": gPlaceID, "gPlaceName": gPlaceName, "gPlaceAddress": gPlaceAddress]
        
        let businessObj = Business(name: yelpName, address: yelpAddress, imageURL: yelpImageURL, photoRef: gPlacePhotoRef)
        
        
        completion(businessObject: businessDict, businessObj: businessObj)
    }
    
    
//    private func parseGPlacesJSON(data: NSDictionary, completion: (googlePlacesArray: NSDictionary) -> Void){
//        if data.count > 0 {
//            
//            // var arrayOfGPlaces: NSMutableArray! = []
//            var dictOfGPlaces = NSMutableDictionary()
//            
//            if let places = data["results"] as? NSArray {
//                if places.count > 0{
//                    for place in places {
//                        let placeID = place["place_id"] as! String
//                        let placeName = place["name"] as! String
//                        let placeAddress = place["vicinity"] as! String
//                        let placePrefix = String(placeAddress.characters.prefix(4))
//                        
//                        var placePhotoRef = ""
//                        if let photos = place["photos"] as? NSArray{
//                            placePhotoRef = photos[0]["photo_reference"] as! String
//                        }
//                        
//                        var placeLatitude: Double!
//                        var placeLongitude: Double!
//                        var placeLatPlusLong: Double!
//                        
//                        if let placeGeometry = place["geometry"] as? NSDictionary{
//                            if let placeLocation = placeGeometry["location"] as? NSDictionary{
//                                placeLatitude = placeLocation["lat"] as! Double
//                                placeLongitude = placeLocation["lng"] as! Double
//                                placeLatPlusLong = placeLatitude + placeLongitude
//    
//                            }
//                        }
//                        
//                        dictOfGPlaces["\(placePrefix)"] = ["placeID": placeID ,"address": placeAddress, "name": placeName, "placePhotoReference": placePhotoRef, "placeLatLong": [placeLatitude, placeLongitude], "placeLatPlusLong": placeLatPlusLong]
//                    }
//                    
//                    if debugPrint.BUSINESS_ARRAY == true{
//                        print("Google Places")
//                        print(dictOfGPlaces)
//                    }
//                    
//                    completion(googlePlacesArray: dictOfGPlaces)
//                }
//                
//            }
//        }
//    }
    
//    // This function takes the two dictionarys from the APIs and compares them, favoring the YELP API over GP
//    // Also used to add in the image reference links from GPlaces API to form a uniform Business Object
//    private func combineJSONData(yelpBusinessArray: NSArray, googlePlaceDict: NSDictionary, completion: (businessObject: NSArray) -> Void){
//        
//        var grandBusinessArray: NSMutableArray! = []
//        
//        var gPlacePrefixes = (googlePlaceDict.allKeys as! [String]).sort(<)
//        var gPlacePreInt: [Int] = []
//        
//        for placePre in gPlacePrefixes{
//            if let preToInt = Int(placePre){
//                gPlacePreInt.append(preToInt)
//            }
//        }
//        
//
//        for business in 0...(yelpBusinessArray.count - 1){
//            
//            var businessDict: NSMutableDictionary!
//            businessDict = NSMutableDictionary()
//            
//            let businessObject = yelpBusinessArray[business] as! NSDictionary
//            let yelpPrefix = businessObject["businessPrefixInt"] as! Int
//            
//            let matchedIndex = binarySearch(gPlacePreInt, searchInt: yelpPrefix, counterOn: false)
//            
//            if matchedIndex != -1{
//                
//                let matchedPrefix = String(gPlacePreInt[matchedIndex])
//                let googlePlace = googlePlaceDict[matchedPrefix] as! NSDictionary
//                
//                let businessID = businessObject["businessID"] as! String
//                businessDict["\(businessID)"] = ["name": businessObject["name"] as! String, "photoReference": googlePlace["placePhotoReference"] as! String]
//
//                grandBusinessArray.addObject(businessDict)
//                //gPlacePreInt.removeAtIndex(matchedIndex)
//            }
//            
//        }
//        print(iterationCount, "iterations")
//        
//        completion(businessObject: grandBusinessArray)
//    }
    
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