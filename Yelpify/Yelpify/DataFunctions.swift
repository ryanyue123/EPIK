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
import Parse
import Async

struct DataFunctions {
    static func getLocation(_ completion: @escaping (_ coordinates: CLLocationCoordinate2D) -> Void){
        Location.getLocation(withAccuracy: .block, frequency: .oneShot, timeout: 30, onSuccess: { (foundLocation) in
            completion(foundLocation.coordinate)
            
        }) { (lastValidLocation, error) in
            print(error)
            if lastValidLocation != nil{
                completion((lastValidLocation?.coordinate)!)
            }
        }
    }
}
