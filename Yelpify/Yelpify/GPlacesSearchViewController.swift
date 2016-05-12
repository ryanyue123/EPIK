import UIKit
import GoogleMaps

class GPlacesSearchViewController: UIViewController, UISearchBarDelegate, UISearchControllerDelegate, UITableViewDelegate, CustomSearchControllerDelegate{
    
    @IBOutlet weak var resultsTableView: UITableView!
    
    @IBOutlet weak var mainSearchTextField: UITextField!
    
    var shouldShowSearchResults = false
    var customSearchBar: CustomSearchBar!
    var tableDataSource: GMSAutocompleteTableDataSource?
    
    var customSearchController: CustomSearchController!
    //var customSearchPlaceController : CustomSearchController!
    
    var searchType: String! = "Location"
    
    var currentLocation: String! = "Current Location"
    var currentLocationCoordinates: String! = "-33.0,180.0"
    
    var searchQuery: String! = ""
    
    @IBAction func mainSearchEditingDidChange(sender: AnyObject) {
        let searchText = mainSearchTextField.text
        
        searchQuery = searchText
        
        searchType = "Business"
        configureFilterType()
        tableDataSource?.sourceTextHasChanged(searchText)
        resultsTableView.reloadData()
    }
    @IBAction func mainSearchEditingEnded(sender: AnyObject) {
        performSegueWithIdentifier("unwindToSearch", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableDataSource()
        configureFilterType()
        //configureCustomSearchController()

    }
    
    override func viewDidAppear(animated: Bool) {
        print(currentLocationCoordinates)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.mainSearchTextField.text = searchQuery
        self.mainSearchTextField.becomeFirstResponder()
        
        //self.customSearchController.customSearchBar.placeholder = currentLocationCoordinates
    }
    
    func configureFilterType(){
        let filter = GMSAutocompleteFilter()
        filter.type = GMSPlacesAutocompleteTypeFilter.Address
        
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
        
        let coordArray = currentLocationCoordinates.characters.split{$0 == ","}.map(String.init)
        let currentLat = Double(coordArray[0])!
        let currentLng = Double(coordArray[1])!
        
    
        let northEastBound = CLLocationCoordinate2D(latitude: currentLat + 0.1, longitude: currentLng + 0.1)
        let southWestBound = CLLocationCoordinate2D(latitude: currentLat - 0.1, longitude: currentLng - 0.1)
        
        //print(northEastBound.latitude, northEastBound.longitude)
        //print(southWestBound.latitude, southWestBound.longitude)
        
        tableDataSource?.autocompleteBounds = GMSCoordinateBounds(coordinate: northEastBound, coordinate: southWestBound)
        
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
        
    }
    
    func didStartSearching() {
        searchType = "Location"
        configureFilterType()
        customSearchController.customSearchBar.placeholder = "Search Location"
        
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController.isKindOfClass(SearchBusinessViewController){
            let searchBusinessVC: SearchBusinessViewController! = segue.destinationViewController as! SearchBusinessViewController
        }
    }
    
}

extension GPlacesSearchViewController: GMSAutocompleteTableDataSourceDelegate {
    func tableDataSource(tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWithPlace place: GMSPlace) {
        customSearchController?.active = false
        
        // Do something with the selected place.
        if searchType == "Location"{
            currentLocation = place.formattedAddress!
            customSearchController.customSearchBar.resignFirstResponder()
            customSearchController.customSearchBar.text = ""
            customSearchController.customSearchBar.placeholder = place.formattedAddress!
        }else if searchType == "Business"{
            mainSearchTextField.resignFirstResponder()
            mainSearchTextField.text = place.name
        }
        
        //print("Place name: \(place.name)")
        //print("Place address: \(place.formattedAddress)")
        //print("Place attributions: \(place.attributions)")
        
        let placeCoordinate = place.coordinate
        currentLocationCoordinates = "\(placeCoordinate.latitude),\(placeCoordinate.longitude)"
        performSegueWithIdentifier("unwindToSearch", sender: self)
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

