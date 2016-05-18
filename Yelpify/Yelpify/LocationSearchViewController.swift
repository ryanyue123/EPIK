import UIKit
import GoogleMaps
import Async

enum SearchType {
    case City
    case Address
    case Place
}

class LocationSearchViewController: UIViewController, UISearchBarDelegate, UISearchControllerDelegate, UITableViewDelegate, CustomSearchControllerDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var resultsTableView: UITableView!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var mainSearchTextField: UITextField!
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBAction func pressedCancel(sender: AnyObject) {
        performSegueWithIdentifier("unwindFromLocation", sender: self)
    }
    
    @IBAction func pressedSearch(sender: AnyObject) {
        print("searching")
    }
    
    
    var shouldShowSearchResults = false
    var customSearchBar: CustomSearchBar!
    var tableDataSource: GMSAutocompleteTableDataSource?
    
    var customSearchController: CustomSearchController!
    
    var searchType: SearchType = .Address
    
    var currentLocation: String! = "Current Location"
    var currentLocationCoordinates: String! = "-33.0,180.0"
    var currentCity: String! = ""
    
    var searchQuery: String! = ""
    
    @IBAction func mainSearchEditingDidChange(sender: AnyObject) {
        let searchText = mainSearchTextField.text
        
        searchQuery = searchText
        
        print(searchQuery)
        if searchQuery.characters.count > 0{
            searchType = .City
            do{
                if let _ =  try Int(searchText![0]){
                    print("is int")
                    searchType = .Address
                }
            }catch{}
        }
        
        configureFilterType()
        tableDataSource?.sourceTextHasChanged(searchText)
        resultsTableView.reloadData()
    }
    @IBAction func mainSearchEditingEnded(sender: AnyObject) {
        performSegueWithIdentifier("unwindFromNewLocation", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainSearchTextField.delegate = self
        
        Async.main{
            self.configureHeaderView()
        }
        
        configureTableDataSource()
        configureFilterType()
        //configureCustomSearchController()

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateHeaderView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderView()
    }
    
    func updateHeaderView(){
        let headerRect = CGRect(x: 0, y: 0, width: resultsTableView.frame.size.width, height: resultsTableView.frame.size.height)
        //resultsTableView.tableHeaderView?.frame = headerRect
        resultsTableView.frame = headerRect
    }
//
    private var headerHeight: CGFloat = 50.0
    
    func configureHeaderView(){
        //self.playlistInfoName.font = UIFont(name: "Montserrat-Regular", size: 32.0)
        resultsTableView.tableHeaderView = nil
        resultsTableView.addSubview(headerView)
        resultsTableView.contentInset = UIEdgeInsets(top: headerHeight, left: 0, bottom: 0, right: 0)
        resultsTableView.contentOffset = CGPoint(x: 0, y: 0)
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
            case .Address:
                filter.type = GMSPlacesAutocompleteTypeFilter.Address
            case .City:
                filter.type = GMSPlacesAutocompleteTypeFilter.City
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
    
//    
//    func configureCustomSearchController() {
//        customSearchController = CustomSearchController(searchResultsController: self, searchBarFrame: CGRectMake(0.0, 0.0, resultsTableView.frame.size.width, 35.0), searchBarFont: UIFont(name: "Futura", size: 12.0)!, searchBarTextColor: UIColor.orangeColor(), searchBarTintColor: UIColor.blackColor())
//        
////        customSearchController.customSearchBar.showsCancelButton = false
////        customSearchController.customSearchBar.showsScopeBar = false
////        customSearchController.customSearchBar.placeholder = "Current Location"
//        
//        // CHANGE MAGNIFYING GLASS IMAGE HERE
//        //customSearchController.customSearchBar.setImage(UIImage(), forSearchBarIcon: UISearchBarIcon.Search, state: UIControlState.Normal)
//        
//        resultsTableView.tableHeaderView = customSearchController.customSearchBar
//        
//        customSearchController.customDelegate = self
//        
//    }
//    
    func didStartSearching() {
        searchType = .Address
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

extension LocationSearchViewController: GMSAutocompleteTableDataSourceDelegate {
    func tableDataSource(tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWithPlace place: GMSPlace) {
        customSearchController?.active = false
        
        // Do something with the selected place.
        if searchType == .Address{
            mainSearchTextField.resignFirstResponder()
            mainSearchTextField.text = place.formattedAddress
//            customSearchController.customSearchBar.resignFirstResponder()
//            customSearchController.customSearchBar.text = ""
//            customSearchController.customSearchBar.placeholder = place.formattedAddress!
        }else if searchType == .Place{
            mainSearchTextField.resignFirstResponder()
            mainSearchTextField.text = place.name
        }
        
        //print("Place name: \(place.name)")
        //print("Place address: \(place.formattedAddress)")
        //print("Place attributions: \(place.attributions)")
        
        let placeCoordinate = place.coordinate
        currentLocationCoordinates = "\(placeCoordinate.latitude),\(placeCoordinate.longitude)"
        
        for component in place.addressComponents!{
            if component.type == "locality"{
                currentCity = component.name
                break
            }
        }
        performSegueWithIdentifier("unwindFromNewLocation", sender: self)
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

