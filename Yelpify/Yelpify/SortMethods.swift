//
//  SortMethods.swift
//  Yelpify
//
//  Created by Kay Lab on 4/1/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import Foundation





func sortMethods(businesses: Array<Business>, type: String)->Array<Business>{
    var sortedBusinesses: Array<Business> = []
    if type == "name"{
        sortedBusinesses = businesses.sort{$0.businessName < $1.businessName}
    } else if type == "rating"{
        sortedBusinesses = businesses.sort{$0.businessRating > $1.businessRating}
    }
    return sortedBusinesses
    
}
