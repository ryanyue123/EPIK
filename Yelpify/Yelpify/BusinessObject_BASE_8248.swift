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
    
    init(name: String, address: String, imageURL: String){
        businessName = name
        businessAddress = address
        businessImageURL = imageURL
    }
    
}