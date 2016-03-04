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
    
    var businessName: String
    var businessAddress: String
    var businessImageURL: String
    var businessPhotoReference: String
    var businessLatitude: Double
    var businessLongitude: Double
    var yelpID: String
    var gPlaceID: String
    
    init(name: String, address: String, imageURL: String, photoRef: String, latitude:Double, longitude:Double, businessID: String, placeID: String){
        businessName = name
        businessAddress = address
        businessImageURL = imageURL
        businessPhotoReference = photoRef
        businessLatitude = latitude
        businessLongitude = longitude
        gPlaceID = placeID
        yelpID = businessID
    }

    
}

struct YelpBusiness{
    var businessID: String
    var businessName: String
    var businessAddress: String
    var businessImageURL: String
    var businessLatitude: Double
    var businessLongitude: Double
    
    init(id: String, name: String, address: String, imageURL: String, latitude: Double, longitude: Double){
        businessID = id
        businessName = name
        businessAddress = address
        businessImageURL = imageURL
        businessLatitude = latitude
        businessLongitude = longitude
    }

}

struct GooglePlace {
    var placeID: String
    var placeName: String
    var placeAddress: String
    var placePhotoReference: String
    
    init(id: String, name: String, address: String, photoRef: String){
        placeID = id
        placeName = name
        placeAddress = address
        placePhotoReference = photoRef
        
    }
}