//
//  GPlacesSearchViewController.swift
//  Yelpify
//
//  Created by Jonathan Lam on 3/7/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import GoogleMaps

class GPlacesSearchViewController: UIViewController, UISearchDisplayDelegate{
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    var searchType: String!
    
    override func viewDidAppear(animated: Bool) {
        print(searchType)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        let leftBound = CLLocationCoordinate2D(latitude: 33.3, longitude: -117.9)
        let rightBound = CLLocationCoordinate2D(latitude: 33.8, longitude: -117.7)
        let filter = GMSAutocompleteFilter()
        
        switch searchType{
            case "Location":
                filter.type = GMSPlacesAutocompleteTypeFilter.Address
            case "Business":
                filter.type = GMSPlacesAutocompleteTypeFilter.Establishment
            default:
                filter.type = GMSPlacesAutocompleteTypeFilter.Establishment
        }
    
        resultsViewController?.autocompleteBounds = GMSCoordinateBounds(coordinate: leftBound, coordinate: rightBound)
        resultsViewController?.autocompleteFilter = filter
        
        configureSearchController()
        
        // Put the search bar in the navigation bar.
        self.navigationItem.titleView = searchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        self.definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
    }
    
    func configureSearchController() {
        // Initialize and perform a minimum configuration to the search controller.
        searchController = UISearchController(searchResultsController: resultsViewController)
        let searchBar = searchController!.searchBar
        
        searchController?.searchResultsUpdater = resultsViewController
        searchController!.dimsBackgroundDuringPresentation = true
        searchBar.placeholder = "Search " + searchType
        searchBar.sizeToFit()
        searchBar.showsCancelButton = false
//        searchBar.showsScopeBar = false
//        searchBar.showsBookmarkButton = false
        
        // Place the search bar view to the tableview headerview.
        //self.navigationItem.titleView = searchController?.searchBar
    }
    
    deinit{
        searchController!.view.removeFromSuperview()
        resultsViewController?.view.removeFromSuperview()
    }
}


// Handle the user's selection.
extension GPlacesSearchViewController: GMSAutocompleteResultsViewControllerDelegate {
    
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
