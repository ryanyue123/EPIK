//
//  BusinessObject.swift
//
//
//  Created by Jonathan Lam on 2/17/16.
//
//

import Foundation
import UIKit
import SwiftyJSON

struct Business {
    
    var businessName: String! = ""
    var businessAddress: String! = ""
    //var businessCity: String! = ""
    //var businessZip: String! = ""
    var businessPhone: String! = ""
    //var businessImageURL: String! = ""
    var businessPhotoReference: String! = ""
    var businessLatitude: Double! = -1
    var businessLongitude: Double! = -1
    //var businessDistance: Double! = -1
    var businessRating: Double! = -1
    //var businessCategories: NSArray! = []
    var businessStatus: Bool! = nil
    //var yelpID: String! = ""
    var gPlaceID: String! = ""
    
    init(){
        
    }
    
    func getDictionary() -> NSDictionary{
        let businessDict = NSMutableDictionary()
        businessDict["id"] = gPlaceID
        businessDict["name"] = businessName
        businessDict["address"] = businessAddress
        //businessDict["imageURL"] = businessImageURL
        businessDict["photoReference"] = businessPhotoReference
        businessDict["latitude"] = businessLatitude
        businessDict["longitude"] = businessLongitude
        //businessDict["distance"] = businessDistance
        businessDict["rating"] = businessRating
        //businessDict["categories"] = businessCategories
        //businessDict["city"] = businessCity
        //businessDict["zip"] = businessZip
        businessDict["phone"] = businessPhone
        businessDict["status"] = businessStatus
        
        return businessDict
    }

}


//completion(detailedGPlaceDict: ["phone": placePhone, "address": placeFormattedAddress, "website": placeWebsite, "priceRating": placePrice, "hours": placeWeekdayText, "placePhotos": placePhotoRefArray, "rating": placeRating, "reviews": placeReviews])

struct GooglePlaceDetail {
    var address: String! = ""
    var phone: String! = ""
    var website: String! = ""
    var hours: NSArray! = []
    var priceRating: Int! = 0
    var rating: Double! = 0
    var reviews: NSMutableArray! = []
    var photos: NSMutableArray! = []
    
    init(){
        
    }
}