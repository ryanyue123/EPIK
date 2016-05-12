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
        LocationManager.shared.observeLocations(.Block, frequency: .OneShot, onSuccess: { location in
            // Save Location to NSUserDefaults
            print("Got Current Location \(location.coordinate)")
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject([location.coordinate.latitude, location.coordinate.longitude], forKey: "coordinates")
            completion(coordinates: location.coordinate)
        }) { error in
            // If error, return last known location
            print(error)
            let userDefaults = NSUserDefaults.standardUserDefaults()
            if let coords = userDefaults.arrayForKey("coordinate") as? [Double]{
                print("Could not get current location, loading from defaults \(coords)")
                completion(coordinates: CLLocationCoordinate2D(latitude: coords[0], longitude: coords[1]))
            }else{
                // If no known location saved, return own
                print("Could not get location from defaults, loaded preset location.")
                let coordinate = CLLocationCoordinate2D(latitude: 37.361622, longitude: -121.927902)
                completion(coordinates: coordinate)
            }
        }
    }
}