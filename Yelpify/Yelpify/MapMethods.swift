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

extension MKMapView{
    func initializeMap(radiusOfMapArea: Double = 100){
        
        let zoomRect = rectForAnnotations(self.annotations)
        let padding: CGFloat = 40
        self.mapType = .Standard
        self.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsetsMake(padding, padding, padding, padding), animated: true)
    }
    
    func rectForAnnotations(annotations: [MKAnnotation]) -> MKMapRect {
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
    
    func addMarker(lat: Double, long: Double){
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.addAnnotation(annotation)
    }
}

