//
//  LocationSearchViewController.swift
//  Yelpify
//
//  Created by Jonathan Lam on 3/7/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import GoogleMaps

class LocationSearchViewController: UIViewController, UISearchDisplayDelegate{
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        let leftBound = CLLocationCoordinate2D(latitude: 33.3, longitude: -117.9)
        let rightBound = CLLocationCoordinate2D(latitude: 33.8, longitude: -117.7)
        let filter = GMSAutocompleteFilter()
        filter.type = GMSPlacesAutocompleteTypeFilter.Address
        resultsViewController?.autocompleteBounds = GMSCoordinateBounds(coordinate: leftBound, coordinate: rightBound)
        resultsViewController?.autocompleteFilter = filter
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        self.navigationItem.titleView = searchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        self.definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
    }
    
    
//    func placeAutocomplete(query: String) {
//        // 33.64496794563093,-117.83725295740864
//        let leftBound = CLLocationCoordinate2D(latitude: 33.64496794563093, longitude: -117.83725295740864)
//        let rightBound = CLLocationCoordinate2D(latitude: 34.64496794563093, longitude: -116.83725295740864)
//        let bounds = GMSCoordinateBounds(coordinate: leftBound, coordinate: rightBound)
//        let filter = GMSAutocompleteFilter()
//        filter.type = GMSPlacesAutocompleteTypeFilter.City
//        placesClient.autocompleteQuery(query, bounds: bounds, filter: filter, callback: { (results, error: NSError?) -> Void in
//            guard error == nil else {
//                print("Autocomplete error \(error)")
//                return
//            }
//            
//            for result in results! {
//                print("Result \(result.attributedFullText) with placeID \(result.placeID)")
//            }
//        })
//    }
}



// Handle the user's selection.
extension LocationSearchViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(resultsController: GMSAutocompleteResultsViewController!,
        didAutocompleteWithPlace place: GMSPlace!) {
            searchController?.active = false
            // Do something with the selected place.
            print("Place name: ", place.name)
            print("Place address: ", place.formattedAddress)
            print("Place attributions: ", place.attributions)
    }
    
    func resultsController(resultsController: GMSAutocompleteResultsViewController!,
        didFailAutocompleteWithError error: NSError!){
            // TODO: handle the error.
            print("Error: ", error.description)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController!) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController!) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}
