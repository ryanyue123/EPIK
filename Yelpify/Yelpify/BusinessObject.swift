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
    
    init(name: String, address: String, imageURL: String, photoRef: String, latitude:Double, longitude:Double){
        businessName = name
        businessAddress = address
        businessImageURL = imageURL
        businessPhotoReference = photoRef
        businessLatitude = latitude
        businessLongitude = longitude
    }
    
}