import UIKit
import GoogleMaps

class GPlacesSearchViewController: UIViewController, UISearchBarDelegate, UISearchControllerDelegate, UITableViewDelegate, CustomSearchControllerDelegate {
    
    @IBOutlet weak var resultsTableView: UITableView!
    
    @IBOutlet weak var mainSearchTextField: UITextField!
    
    var shouldShowSearchResults = false
    var customSearchBar: CustomSearchBar!
    var tableDataSource: GMSAutocompleteTableDataSource?
    
    var customSearchController: CustomSearchController!
    var customSearchPlaceController : CustomSearchController!
    
    var searchType: String! = "Location"
    
    @IBAction func mainSearchEditingDidChange(sender: AnyObject) {
        let searchText = mainSearchTextField.text
        searchType = "Business"
        configureFilterType()
        tableDataSource?.sourceTextHasChanged(searchText)
        resultsTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableDataSource()
        configureFilterType()
        configureCustomSearchController()

    }
    
    func configureFilterType(){
        
        let filter = GMSAutocompleteFilter()
        switch searchType{
            case "Location":
                filter.type = GMSPlacesAutocompleteTypeFilter.Address
            case "Business":
                filter.type = GMSPlacesAutocompleteTypeFilter.Establishment
            default:
                filter.type = GMSPlacesAutocompleteTypeFilter.NoFilter
        }
        
        tableDataSource?.autocompleteFilter = filter
    }
    
    func configureTableDataSource(){
        tableDataSource = GMSAutocompleteTableDataSource()
        tableDataSource?.delegate = self
        
        let leftBound = CLLocationCoordinate2D(latitude: 33.3, longitude: -117.9)
        let rightBound = CLLocationCoordinate2D(latitude: 33.8, longitude: -117.7)
        
        tableDataSource?.autocompleteBounds = GMSCoordinateBounds(coordinate: leftBound, coordinate: rightBound)
        
        resultsTableView.dataSource = tableDataSource
        resultsTableView.delegate = tableDataSource

    }
    
    func configureCustomSearchController() {
        customSearchController = CustomSearchController(searchResultsController: self, searchBarFrame: CGRectMake(0.0, 0.0, resultsTableView.frame.size.width, 35.0), searchBarFont: UIFont(name: "Futura", size: 12.0)!, searchBarTextColor: UIColor.orangeColor(), searchBarTintColor: UIColor.blackColor())
        
        customSearchController.customSearchBar.showsCancelButton = false
        customSearchController.customSearchBar.showsScopeBar = false
        customSearchController.customSearchBar.placeholder = "Current Location"
        
        // CHANGE MAGNIFYING GLASS IMAGE HERE
        //customSearchController.customSearchBar.setImage(UIImage(), forSearchBarIcon: UISearchBarIcon.Search, state: UIControlState.Normal)
        
        resultsTableView.tableHeaderView = customSearchController.customSearchBar
        
        customSearchController.customDelegate = self
        
//        // NAV SEARCH BAR
//        customSearchPlaceController = CustomSearchController(searchResultsController: self, searchBarFrame: CGRectMake(0.0, 0.0, (self.navigationController?.navigationBar.frame.size.width)!, 44.0), searchBarFont: UIFont(name: "Futura", size: 16.0)!, searchBarTextColor: UIColor.orangeColor(), searchBarTintColor: UIColor.blackColor())
//        
//        customSearchPlaceController.customSearchBar.showsCancelButton = false
//        customSearchPlaceController.customSearchBar.showsScopeBar = false
//        customSearchPlaceController.customSearchBar.placeholder = "Search Places"
//        
//        customSearchPlaceController.customDelegate = self
//        
//        self.navigationItem.titleView = customSearchPlaceController.customSearchBar
        
    }
    
    func didStartSearching() {
        searchType = "Location"
        configureFilterType()
        
        shouldShowSearchResults = true
        resultsTableView.reloadData()
    }
    
    func didTapOnSearchButton() {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            resultsTableView.reloadData()
        }
    }
    
    func didTapOnCancelButton() {
        shouldShowSearchResults = false
        resultsTableView.reloadData()
    }
    
    func didChangeSearchText(searchText: String) {
        tableDataSource?.sourceTextHasChanged(searchText)
        // Reload the tableview.
        resultsTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didUpdateAutocompletePredictionsForTableDataSource(tableDataSource: GMSAutocompleteTableDataSource) {
        // Turn the network activity indicator off.
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        // Reload table data.
        resultsTableView.reloadData()
    }
    
    func didRequestAutocompletePredictionsForTableDataSource(tableDataSource: GMSAutocompleteTableDataSource) {
        // Turn the network activity indicator on.
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        // Reload table data.
        resultsTableView.reloadData()
    }
    
    
}

extension GPlacesSearchViewController: GMSAutocompleteTableDataSourceDelegate {
    func tableDataSource(tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWithPlace place: GMSPlace) {
        customSearchController?.active = false
        // Do something with the selected place.
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String?) -> Bool {
        tableDataSource?.sourceTextHasChanged(searchString)
        return false
    }
    
    func tableDataSource(tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: NSError) {
        // TODO: Handle the error.
        print("Error: \(error.description)")
    }
    
    func tableDataSource(tableDataSource: GMSAutocompleteTableDataSource, didSelectPrediction prediction: GMSAutocompletePrediction) -> Bool {
        return true
    }
}

