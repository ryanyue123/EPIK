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
    var businessLongitude: Double
    var businessLatitude: Double
    init(name: String, address: String, imageURL: String, longitude: Double, latitude: Double){
        businessName = name
        businessAddress = address
        businessImageURL = imageURL
        businessLongitude = longitude
        businessLatitude = latitude
    }
    
}