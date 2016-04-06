//
//  PlaylistObject.swift
//  Yelpify
//
//  Created by Jonathan Lam on 4/1/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import Foundation
import UIKit

struct PlaylistObject {
    
    var name: String?
    var creator: String?
    var contributors: NSArray? = []
    var placeCount: Int?
    var description: String?
    var city: String?
    var priceLevel: Int?
    var followerCount: Int?
    var followers: NSArray? = []
    var tags: NSArray? = []
    var comments: NSArray? = []
    
    var placesArray: [Business] = []
    
    init(_name: String, _creator: String, _contributors: NSArray, _placeCount: Int, _description: String, _city: String, _priceLevel: Int, _followerCount: Int, _followers: NSArray, _tags: NSArray, _comments: NSArray, _places: [Business]){
        
        name = _name
        creator = _creator
        contributors = _contributors
        placeCount = _placeCount
        priceLevel = _priceLevel
        description = _description
        city = _city
        followerCount = _followerCount
        followers = _followers
        tags = _tags
        comments = _comments
        
        placesArray = _places
        
    }
    
    func convertPlacesArrayToDictionary(){
        var placeDict = [String: NSDictionary]()
        for business in self.placesArray{
            placeDict[business.gPlaceID!] = business.getDictionary()
        }
    }
    
    
}