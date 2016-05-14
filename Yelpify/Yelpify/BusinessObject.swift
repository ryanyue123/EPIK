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
    var businessPhone: String! = ""
    var businessPhotoReference: String! = ""
    var businessLatitude: Double! = -1
    var businessLongitude: Double! = -1
    var businessRating: Double! = -1
    var businessTypes: NSMutableArray! = []
    var businessStatus: Bool! = nil
    var gPlaceID: String! = ""

    func getDictionary() -> NSDictionary{
        let businessDict = NSMutableDictionary()
        businessDict["id"] = gPlaceID
        businessDict["name"] = businessName
        businessDict["address"] = businessAddress
        businessDict["photoReference"] = businessPhotoReference
        businessDict["latitude"] = businessLatitude
        businessDict["longitude"] = businessLongitude
        businessDict["rating"] = businessRating
        businessDict["types"] = businessTypes
        businessDict["phone"] = businessPhone
        
        return businessDict
    }

}

struct GooglePlaceDetail {
    var name: String! = "" //
    var address: String! = ""
    var phone: String! = ""
    var website: String! = ""
    var hours: NSMutableArray! = []
    var priceRating: Int! = 0
    var rating: Double! = 0
    var reviews: NSMutableArray! = []
    var photos: NSMutableArray! = []
    var types: NSMutableArray! = []
    
    var longitude: Double! = -1 //
    var latitude: Double! = -1 //
    
    func convertToBusiness() -> Business{
        var business = Business()
        business.businessAddress = self.address
        business.businessLatitude = self.latitude
        business.businessLongitude = self.longitude
        business.businessName = self.name
        business.businessAddress = self.address
        business.businessPhone = self.phone
        if self.photos.count > 0 {
            business.businessPhotoReference = self.photos[0] as! String
        }
        business.businessTypes = self.types
        
        return business
    }
}