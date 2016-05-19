import UIKit
import GoogleMaps
import Async

enum SearchType {
    case City
    case Address
    case Place
}

class LocationSearchViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var resultsTableView: UITableView!
    
    @IBOutlet weak var outterView: UIView!
    @IBOutlet var modalView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var mainSearchTextField: UITextField!
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBAction func pressedCancel(sender: AnyObject) {
        performSegueWithIdentifier("unwindToSearchCancel", sender: self)
    }
    
    @IBAction func pressedSearch(sender: AnyObject) {
        print("searching")
    }
    
    
    var shouldShowSearchResults = false
    var tableDataSource: GMSAutocompleteTableDataSource?
    
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
    
    @IBAction func mainSearchEditingDidEnd(sender: AnyObject) {
        //performSegueWithIdentifier("unwindFromNewLocation", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.resultsTableView.tableHeaderView?.transform = CGAffineTransformMakeScale(0, 0)
        
        self.mainSearchTextField.text = currentCity
        
        self.outterView.layer.cornerRadius = 20.0
        self.outterView.clipsToBounds = true
        
        mainSearchTextField.delegate = self
        
        configureTableDataSource()
        configureFilterType()

    }
    
    override func viewDidAppear(animated: Bool) {
        print(currentLocationCoordinates)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.mainSearchTextField.text = searchQuery
        self.mainSearchTextField.becomeFirstResponder()
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
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.destinationViewController.isKindOfClass(SearchBusinessViewController){
//            let searchBusinessVC: SearchBusinessViewController! = segue.destinationViewController as! SearchBusinessViewController
//        }
//    }
//    
}

extension LocationSearchViewController: GMSAutocompleteTableDataSourceDelegate {
    func tableDataSource(tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWithPlace place: GMSPlace) {
        
        // Do something with the selected place.
        if searchType == .Address{
            mainSearchTextField.resignFirstResponder()
            mainSearchTextField.text = place.formattedAddress
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
        if let _ = self.parentViewController as? SearchPagerTabStrip{
            performSegueWithIdentifier("unwindFromNewLocation", sender: self)
        }else{
            performSegueWithIdentifier("unwindToSearch", sender: self)
        }
    }
    
    func tableDataSource(tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: NSError) {
        // TODO: Handle the error.
        print("Error: \(error.description)")
    }
    
    func tableDataSource(tableDataSource: GMSAutocompleteTableDataSource, didSelectPrediction prediction: GMSAutocompletePrediction) -> Bool {
        return true
    }
}

