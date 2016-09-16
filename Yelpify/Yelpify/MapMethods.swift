//
//  MapMethods.swift
//  Yelpify
//
//  Created by Jonathan Lam on 9/2/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import Foundation
import MapKit
import UIKit

private var xoAssociationKey: UInt8 = 0

extension MKMapView{
    func initializeMap(_ radiusOfMapArea: Double = 100){
        
        let zoomRect = rectForAnnotations(self.annotations)
        let padding: CGFloat = 40
        self.mapType = .standard
        self.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsetsMake(padding, padding, padding, padding), animated: true)
    }
    
    func rectForAnnotations(_ annotations: [MKAnnotation]) -> MKMapRect {
        var zoomRect = MKMapRectNull
        for annotation in annotations {
            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
            let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0)
            if MKMapRectIsNull(zoomRect) {
                zoomRect = pointRect
            }
            else {
                zoomRect = MKMapRectUnion(zoomRect, pointRect)
            }
        }
        return zoomRect
    }
    
    func addMarker(_ lat: Double, long: Double, title: String, row: Int){
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        annotation.title = title
        annotation.cellRow = row
        self.addAnnotation(annotation)
    }
    
    func getCitiesFromCoordinates(_ coordinates: [CLLocationCoordinate2D], completion: @escaping (_ cities: [String:Int]) -> Void){
        
        let grabCityGroup = DispatchGroup()
        
        var cities: [String: Int] = [:]
        for coordinate in coordinates{
            let geoCoder = CLGeocoder()
            grabCityGroup.enter()
            coordinate.getCity(geoCoder, completion: { (city) in
                if city != nil{
                    if cities.keys.contains(city!){
                        cities.updateValue(cities[city!]! + 1, forKey: city!)
                    }else{
                        cities[city!] = 1
                    }
                }
                grabCityGroup.leave()
            })
        }
        
        grabCityGroup.notify(queue: DispatchQueue.main) {
            completion(cities)
        }
    }
}

extension MKAnnotation {
    var cellRow: Int! {
        get {
            return objc_getAssociatedObject(self, &xoAssociationKey) as? Int
        }
        set(row) {
            objc_setAssociatedObject(self, &xoAssociationKey, row, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}

extension CLLocationCoordinate2D {
    
    func getCity(_ geoCoder: CLGeocoder, completion: @escaping (_ city: String?) -> Void){
        let location = CLLocation(latitude: self.latitude, longitude: self.longitude)
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // Address dictionary
            //            print(placeMark.addressDictionary)
            
            // City
            if let city = placeMark.addressDictionary!["City"] as? String {
                completion(city)
            }
            
        })
    }
}


