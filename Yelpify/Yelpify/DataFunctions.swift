//
//  DataFunctions.swift
//  Yelpify
//
//  Created by Jonathan Lam on 5/7/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import SwiftLocation

struct DataFunctions {
    static func getLocation(completion: (coordinates: CLLocationCoordinate2D) -> Void){
        
        Location.getLocation(withAccuracy: .Any, onSuccess: { (foundLocation) in
            completion(coordinates: foundLocation.coordinate)
            }) { (lastValidLocation, error) in
                completion(coordinates: (lastValidLocation?.coordinate)!)
                print(error)
        }
    }
}
