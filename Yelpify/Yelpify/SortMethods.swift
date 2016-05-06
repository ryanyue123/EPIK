//
//  SortMethods.swift
//  Yelpify
//
//  Created by Kay Lab on 4/1/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import Foundation


var business1 = Business(name: "Z Pizza", address: "4567 Caballos Rd.", city: "Santa Ana", zip: "92345", phone: "", imageURL: "", photoRef: "", latitude: 45, longitude: 34, distance: 15, rating: 4, categories: [], status: true, businessID: "", placeID: "")
var business2 = Business(name: "Carlo's Pizza", address: "4555 Osono Ave", city: "Cerritos", zip: "93453", phone: "", imageURL: "", photoRef: "", latitude: 45, longitude: 34, distance: 15, rating: 4, categories: [], status: true, businessID: "", placeID: "")
var business3 = Business(name: "Patrick's Pizza", address: "3544 Swag Rd.", city: "Alhambra", zip: "95683", phone: "", imageURL: "", photoRef: "", latitude: 45, longitude: 34, distance: 15, rating: 4, categories: [], status: true, businessID: "", placeID: "")


func sortMethods(businesses: Array<Business>, type: String)->Array<Business>{
    var sortedBusinesses: Array<Business> = []
    if type == "name"{
        sortedBusinesses = businesses.sort{$0.businessName < $1.businessName}
    } else if (type == "distance"){
        sortedBusinesses = businesses.sort{$0.businessDistance < $1.businessDistance}
    } else if type == "rating"{
        sortedBusinesses = businesses.sort{$0.businessRating > $1.businessRating}
    }
    return sortedBusinesses
    
}
