import UIKit
import GoogleMaps
import GooglePlaces
import Async

enum SearchType {
    case city
    case address
    case place
}

class LocationSearchViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var resultsTableView: UITableView!
    
    @IBOutlet weak var outterView: UIView!
    @IBOutlet var modalView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var mainSearchTextField: UITextField!
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBAction func pressedCancel(_ sender: AnyObject) {
        performSegue(withIdentifier: "unwindToSearchCancel", sender: self)
    }
    
    @IBAction func pressedSearch(_ sender: AnyObject) {
        print("searching")
    }
    
    
    var shouldShowSearchResults = false
    var tableDataSource: GMSAutocompleteTableDataSource?
    
    var searchType: SearchType = .address
    
    var currentLocation: String! = "Current Location"
    var currentLocationCoordinates: String! = "-33.0,180.0"
    var currentCity: String! = ""
    
    var searchQuery: String! = ""

    @IBAction func mainSearchEditingDidChange(_ sender: AnyObject) {
        let searchText = mainSearchTextField.text
        
        searchQuery = searchText
        
        print(searchQuery)
        if searchQuery.characters.count > 0{
            searchType = .city
            do{
                if let _ =  try Int(searchText![0]){
                    print("is int")
                    searchType = .address
                }
            }catch{}
        }
        
        configureFilterType()
        tableDataSource?.sourceTextHasChanged(searchText)
        resultsTableView.reloadData()
    }
    
    @IBAction func mainSearchEditingDidEnd(_ sender: AnyObject) {
        //performSegueWithIdentifier("unwindFromNewLocation", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.resultsTableView.tableHeaderView?.transform = CGAffineTransformMakeScale(0, 0)
        
        self.mainSearchTextField.text = currentCity
        
        self.resultsTableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        
        self.outterView.layer.cornerRadius = 20.0
        self.outterView.clipsToBounds = true
        
        mainSearchTextField.delegate = self
        
        configureTableDataSource()
        configureFilterType()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(currentLocationCoordinates)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.mainSearchTextField.text = searchQuery
        self.mainSearchTextField.becomeFirstResponder()
    }
    
    func configureFilterType(){
        let filter = GMSAutocompleteFilter()
        filter.type = GMSPlacesAutocompleteTypeFilter.address
        
        switch searchType{
            case .address:
                filter.type = GMSPlacesAutocompleteTypeFilter.address
            case .city:
                filter.type = GMSPlacesAutocompleteTypeFilter.city
            default:
                filter.type = GMSPlacesAutocompleteTypeFilter.noFilter
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
    
    func didUpdateAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        // Turn the network activity indicator off.
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        // Reload table data.
        resultsTableView.reloadData()
    }
    
    func didRequestAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        // Turn the network activity indicator on.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
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
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace) {
        
        // Do something with the selected place.
        if searchType == .address{
            mainSearchTextField.resignFirstResponder()
            mainSearchTextField.text = place.formattedAddress
        }else if searchType == .place{
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
        if let _ = self.parent as? SearchPagerTabStrip{
            performSegue(withIdentifier: "unwindFromNewLocation", sender: self)
        }else{
            performSegue(withIdentifier: "unwindToSearch", sender: self)
        }
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: NSError) {
        // TODO: Handle the error.
        print("Error: \(error.description)")
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didSelect prediction: GMSAutocompletePrediction) -> Bool {
        return true
    }
}

