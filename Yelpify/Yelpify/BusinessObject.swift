//
//  BusinessObject.swift
//
//
//  Created by Jonathan Lam on 2/17/16.
//
//

import Foundation
import UIKit

struct Business {
    
    var businessName: String? = ""
    var businessAddress: String? = ""
    var businessCity: String? = ""
    var businessZip: String? = ""
    var businessPhone: String? = ""
    var businessImageURL: String? = ""
    var businessPhotoReference: String? = ""
    var businessLatitude: Double? = -1
    var businessLongitude: Double? = -1
    var businessDistance: Double? = -1
    var businessRating: Double? = -1
    var businessCategories: NSArray? = []
    var businessStatus: Bool? = nil
    var yelpID: String? = ""
    var gPlaceID: String? = ""
    
    init(name: String?, address: String?, city: String? = "", zip: String? = "", phone: String? = "", imageURL: String? = "", photoRef: String?, latitude: Double?, longitude: Double?, distance: Double? = nil, rating: Double? = nil, categories: NSArray? = nil, status: Bool? = nil, businessID: String? = nil, placeID: String?){
        businessName = name
        businessAddress = address
        businessImageURL = imageURL
        businessPhotoReference = photoRef
        businessLatitude = latitude
        businessLongitude = longitude
        businessDistance = distance
        businessRating = rating
        businessCategories = categories
        businessCity = city
        businessZip = zip
        businessPhone = phone
        businessStatus = status
        gPlaceID = placeID
        yelpID = businessID
    }
    
    func getDictionary() -> NSDictionary{
        let businessDict = NSMutableDictionary()
        businessDict["id"] = gPlaceID
        businessDict["name"] = businessName
        businessDict["address"] = businessAddress
        businessDict["imageURL"] = businessImageURL
        businessDict["photoReference"] = businessPhotoReference
        businessDict["latitude"] = businessLatitude
        businessDict["longitude"] = businessLongitude
        businessDict["distance"] = businessDistance
        businessDict["rating"] = businessRating
        businessDict["categories"] = businessCategories
        businessDict["city"] = businessCity
        businessDict["zip"] = businessZip
        businessDict["phone"] = businessPhone
        businessDict["status"] = businessStatus
        
        return businessDict
    }
}

struct YelpBusiness{
    var businessID: String? = ""
    var businessName: String? = ""
    var businessAddress: String? = ""
    var businessCity: String? = ""
    var businessZip: String? = ""
    var businessPhone: String? = nil
    var businessImageURL: String? = ""
    var businessLatitude: Double? = -1
    var businessLongitude: Double? = -1
    var businessDistance: Double? = -1
    var businessRating: Double? = -1
    var businessCategories: NSArray? = []
    var businessStatus: Bool? = nil
    
    init(id: String?, name: String?, address: String?, city: String?, zip: String?, phone: String?, imageURL: String?, latitude: Double?, longitude: Double?, distance: Double?, rating: Double?, categories: NSArray?, status: Bool?){
        businessID = id
        businessName = name
        businessAddress = address
        businessImageURL = imageURL
        businessLatitude = latitude
        businessLongitude = longitude
        businessDistance = distance
        businessRating = rating
        businessCategories = categories
        businessCity = city
        businessZip = zip
        businessPhone = phone
        businessStatus = status
    }
}

struct GooglePlace {
    var placeID: String? = ""
    var placeName: String? = ""
    var placeAddress: String? = ""
    var placePhotoReference: String? = ""
    
    init(id: String?, name: String?, address: String?, photoRef: String?){
        placeID = id
        placeName = name
        placeAddress = address
        placePhotoReference = photoRef
    }
}

//completion(detailedGPlaceDict: ["phone": placePhone, "address": placeFormattedAddress, "website": placeWebsite, "priceRating": placePrice, "hours": placeWeekdayText, "placePhotos": placePhotoRefArray, "rating": placeRating, "reviews": placeReviews])

struct GooglePlaceDetail {
    var address: String? = ""
    var phone: String? = ""
    var website: String? = ""
    var hours: NSArray? = []
    var priceRating: Int? = 0
    var rating: Double? = 0
    var reviews: NSArray? = []
    var photos: NSArray? = []
    
    init(_address: String?, _phone: String?, _website: String?, _hours: NSArray?, _priceRating: Int?, _rating: Double?, _reviews: NSArray?, _photos: NSArray?){
        address = _address
        phone = _phone
        website = _website
        hours = _hours
        priceRating = _priceRating
        rating = _rating
        reviews = _reviews
        photos = _photos
        
    }
}