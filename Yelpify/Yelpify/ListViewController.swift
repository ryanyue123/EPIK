//
//  ListViewController.swift
//  Lyster
//
//  Created by Jonathan Lam on 8/25/16.
//  Copyright © 2016 Limitless. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit
import Parse
import Async
import MGSwipeTableCell
import XLActionController
import CZPicker

class ListViewController: UIViewController, Dimmable {
    
    enum ListMode{
        case view, edit
    }
    
    @IBOutlet var topView: UIView!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var indicatorView: UIView!
    @IBOutlet var pullDownBar: UIView!
    
    @IBOutlet var bannerImageView: UIImageView!
    @IBOutlet var listTypeLabel: UILabel!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var numPlacesLabel: UILabel!
    @IBOutlet var placesLabel: UILabel!
    
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var listTableView: UITableView!
    
    @IBOutlet var addPlaceButton: UIButton!
    
    
    var object: PFObject!
    var playlistArray = [Business]()
    
    var itemReceived: Array<AnyObject> = []
    var sortMethod:String!
    var addToOwnPlaylists: [PFObject]!
    var playlist_swiped: String!
    
    var placeArray = [GooglePlaceDetail]()
    var placeIDs = [String]()
    var apiClient = APIDataHandler()
    
    let imagePicker = UIImagePickerController()
    
    var mode: ListMode! = .view
    
    @IBAction func unwindToSinglePlaylist(_ segue: UIStoryboardSegue)
    {
        print(segue.identifier)
        if(segue.identifier != nil) {
            if(segue.identifier == "unwindToPlaylist") {
                if let sourceVC = segue.source as? SearchBusinessViewController
                {
                    playlistArray.append(contentsOf: sourceVC.businessArray)
                    placeIDs.append(contentsOf: sourceVC.placeIDs)
                    
                    // Appends empty GooglePlaceDetail Objects to make list parallel to placeIDs and playlistArray
                    for _ in 0..<(placeIDs.count - placeArray.count){
                        placeArray.append(GooglePlaceDetail())
                    }
                    
                    // Update Info
//                    self.numOfPlacesLabel.text = "\(placeIDs.count)"
//                    self.getAveragePrice({ (avg) in
//                        self.setPriceRating(avg)
//                    })
                    self.listTableView.reloadData()
                }
            }
        }
    }

    
    @IBAction func pressedAddPlacesButton(_ sender: AnyObject) {
        performSegue(withIdentifier: "tapImageButton", sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.resetTopBars(0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        self.bannerImageView.addShadow(offset: CGSize(width: 0, height: 5))
        self.addPlaceButton.addShadow()
        self.bottomView.addShadow()
        self.indicatorView.addShadow(opacity: 0.2, offset: CGSize(width: 0, height: 5))
        self.indicatorView.hideShadow()
        self.pullDownBar.layer.cornerRadius = 3
        self.pullDownBar.addShadow()
        
        self.loadData()

        configureRecognizers()
        
        self.listTableView.delegate = self
        self.listTableView.dataSource = self
        
        let rightButton = UIBarButtonItem(image: UIImage(named: "more_icon"), style: .plain, target: self, action: #selector(self.showActionsMenu(_:)))
        navigationItem.rightBarButtonItem = rightButton
    }
    

    func loadData(){
        func updateBusinessesFromIDs(_ ids:[String], reloadIndex: Int = 0){
            if ids.count > 0{
                apiClient.performDetailedSearch(ids[0]) { (detailedGPlace) in
                    self.mapView.addMarker(detailedGPlace.latitude, long: detailedGPlace.longitude)
                    
                    self.placeArray[reloadIndex] = detailedGPlace
                    self.playlistArray[reloadIndex] = detailedGPlace.convertToBusiness()
                    
                    if reloadIndex == self.placeArray.count - 1 {
                        self.mapView.initializeMap()
                    }
                    
                    let idsSlice = Array(ids[1..<ids.count])
                    let index = IndexPath(row: reloadIndex, section: 0)
                    self.listTableView.reloadRows(at: [index], with: .fade) // CHANGE
                    let newIndex = reloadIndex + 1
                    updateBusinessesFromIDs(idsSlice, reloadIndex: newIndex)
                }
            }
        }

        
        // Register Nibs
        self.listTableView.register(UINib(nibName: "BusinessCell", bundle: Bundle.main), forCellReuseIdentifier: "businessCell")
        
        Async.main{
            let placeIDs = self.object["place_id_list"] as! [String]
            self.placeIDs = placeIDs
            self.configureHeader()
            }.main{
                // Get Array of IDs from Parse
                for _ in 0..<self.placeIDs.count{
                    self.placeArray.append(GooglePlaceDetail())
                    self.playlistArray.append(Business())
                }
                self.listTableView.reloadData()
            }.main{
                updateBusinessesFromIDs(self.placeIDs)
        }
    }
    
    // MARK: - Set Up Header View With Info
    func configureHeader() {
        
        let pushAlpha: Double = 1.0
        let pushDuration: Double = 0.7
        let pushBeginScale: CGFloat = 1.0
        let pushAllScale: CGFloat = 1.1
        
        // Set List Name
        if let name = object["playlistName"] as? String{
            self.titleTextField.fadeIn(name, duration: pushDuration, beginScale: pushBeginScale)
        }
        
        // Set BG if custom BG exists in Parse
        if let bg = object["custom_bg"] as? PFFile{
            bg.getDataInBackground(block: { (data, error) in
                if error == nil{
                    let image = UIImage(data: data!)
                    self.bannerImageView.fadeIn(image!, endAlpha: 0.5, beginScale: 1.2)
                }
            })
        }else{
            self.bannerImageView.fadeIn(UIImage(named: "default_list_bg")!, endAlpha: 0.5, beginScale: 1.2)
        }
        
        // Set Number of Places
        self.numPlacesLabel.text = String(self.placeIDs.count) + " Places"
    }

    
    func activateEditMode() {
        
        // Make Title Text Editable
        self.titleTextField.enable()
        self.titleTextField.delegate = self
        
        // Show Change BG Image Button
        //self.changePlaylistImageButton.hidden = false
        
        // Replace More Button With Cancel Button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.deactivateEditMode))
        
        // Animate and Show Add Place Button
        self.addPlaceButton.isHidden = false
        UIView.animate(withDuration: 0.3,delay: 0.0,options: UIViewAnimationOptions.beginFromCurrentState,animations: {
            self.addPlaceButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)},
                                   completion: { finish in
                                    UIView.animate(withDuration: 0.6, animations: {self.addPlaceButton.transform = CGAffineTransform.identity})
        })
        
        // Set Editing to True
        self.setEditing(true, animated: true)
        
        // Set Edit Mode
        self.mode = .edit
        
        // Replace Back Button with Done
        self.navigationItem.setHidesBackButton(true, animated: true)
        let backButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.savePlaylistToParse(_:)))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    func deactivateEditMode() {
        
        // Make Title Text Editable
        self.titleTextField.disable()
        self.titleTextField.delegate = nil
        
        // Hide Change BG Image Button
        //self.changePlaylistImageButton.hidden = true
        
        // Restore More Icon to Right Side of Nav Bar
        let rightButton = UIBarButtonItem(image: UIImage(named: "more_icon"), style: .plain, target: self, action: #selector(ListViewController.showActionsMenu(_:)))
        navigationItem.rightBarButtonItem = rightButton
        
        // Restore Back Button
        self.navigationItem.setHidesBackButton(false, animated: true)
        self.navigationItem.leftBarButtonItem = nil
        
        // Set Editing to False
        self.setEditing(false, animated: true)
        
        // Hide Add Place Button
        self.addPlaceButton.isHidden = true
        // Change to View Mode
        self.mode = .view
    }

    
    
    // MARK: - SAVE PLAYLIST
    func savePlaylistToParse(_ sender: UIBarButtonItem)
    {
        
        func getAveragePrice(_ completion:(_ avg: Int) -> Void){
            var total = 0.0
            var numOfPlaces = 0.0
            for place in self.placeArray{
                if place.priceRating != -1{
                    total += Double(place.priceRating)
                    numOfPlaces += 1
                }
            }
            if numOfPlaces > 0{
                completion(Int(round(total/numOfPlaces)))
            }else{
                completion(-1)
            }
        }

        self.deactivateEditMode()
        
        let saveobject = object
        
        Async.main{
//            // Save Background Image
//            if self.customImage != nil{
//                let imageData: NSData! = UIImageJPEGRepresentation(self.customImage, 1.0)
//                
//                let fileName = self.playlistInfoName.text
//                
//                let imageFile: PFFile! = PFFile(name: fileName, data: imageData)
//                do{ try imageFile.save() }catch{}
//                
//                saveobject["custom_bg"] = imageFile
//            }
            
            // Saves List Name
            saveobject["playlistName"] = self.titleTextField.text
            
            if self.placeIDs.count > 0{
                
                // Save Location of First Object
                if let lat = self.playlistArray[0].businessLatitude
                {
                    if let long = self.playlistArray[0].businessLongitude
                    {
                        saveobject["location"] = PFGeoPoint(latitude: lat, longitude: long)
                    }
                }
                
                // Saves Number of Places
                saveobject["num_places"] = self.placeIDs.count
                
                
                // Saves Average Price
                getAveragePrice({ (avg) in
                    saveobject["average_price"] = avg
                })
                
                
                // Saves Businesses to Parse as [String] Ids
                saveobject["place_id_list"] = self.placeIDs
            }
            
            }.utility{
                saveobject.saveInBackgroundWithBlock { (success, error)  -> Void in
                    if (error == nil){
                        print("saved")
                    }
                    else{
                        print(error?.description)
                    }
                }
        }
        
        
        self.navigationItem.setHidesBackButton(false, animated: true)
        self.navigationItem.leftBarButtonItem = nil
        self.listTableView.reloadData()
    }

    func configureRecognizers(){
        self.originalFrame = self.bottomView.frame
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGR(_:)))
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.handleTapGR(_:)))
        tapGR.delegate = self
        self.bottomView.addGestureRecognizer(panGR)
        self.bottomView.addGestureRecognizer(tapGR)
    }
    
    var originalFrame: CGRect!
    
    func handleTapGR(_ recognizer: UITapGestureRecognizer){
        if self.bottomView.y != (self.view.frame.height * 7/10){
    
        }
    }
    
    func handlePanGR(_ recognizer: UIPanGestureRecognizer){
        let translation = recognizer.translation(in: self.view)
        
        let viewTranslation = originalFrame.origin.y + translation.y
        
        if (viewTranslation > (self.view.height * 1/5)) && (viewTranslation < (self.view.height * 7/10)) {
            self.bottomView.y = originalFrame.origin.y + translation.y
        }
        
        if recognizer.state == .ended{
            
            let velocity = recognizer.velocity(in: self.view)
            let slideMultiplier = velocity.y / 200
            
            let slideFactor: CGFloat = 4 //Increase for more of a slide
            
            var finalY = self.bottomView.y + (slideFactor * slideMultiplier)
            //print(slideFactor * slideMultiplier)
            
            if finalY < (self.view.frame.height * 1/5) || velocity.y < -2000{
                finalY = (self.view.frame.height * 1/5)
            }
            
            if finalY > (self.view.frame.height * 7/10) || velocity.y > 2000{
                finalY = (self.view.frame.height * 7/10)
            }
            
            if finalY > self.view.frame.height * 1/5 {
                self.listTableView.isScrollEnabled = false
            }else{
                self.listTableView.isScrollEnabled = true
            }
            
            
            UIView.animate(withDuration: Double(slideFactor/10), delay: 0, usingSpringWithDamping: 3, initialSpringVelocity: 4, options: .curveEaseOut, animations: {
                recognizer.view!.y = finalY
                }, completion: { (_) in
                    self.originalFrame = self.bottomView.frame
            })
        }
        
        //print("location", location)
        //print("translation", translation)
        
        //print("velocity", velocity, "magnitude", magnitude)
    }
    
    func handleTouchRemoved(_ view: UIView){
        originalFrame = self.bottomView.frame
    }
    
    func configureSwipeButtons(_ cell: MGSwipeTableCell, mode: ListMode){
        if mode == .view{
            let routeButton = MGSwipeButton(title: "ROUTE", icon: UIImage(named: "swipe_route")!.imageWithColor(appDefaults.color),backgroundColor: UIColor.clear, padding: 25)
            routeButton.setEdgeInsets(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 0))
            routeButton.centerIconOverText()
            routeButton.titleLabel?.font = appDefaults.font
            routeButton.titleLabel?.textColor = appDefaults.color
            
            let addButton = MGSwipeButton(title: "ADD", icon: UIImage(named: "swipe_add")!.imageWithColor(appDefaults.color) ,backgroundColor: UIColor.clear, padding: 25)
            addButton.setEdgeInsets(UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 15))
            addButton.centerIconOverText()
            addButton.titleLabel?.font = appDefaults.font
            addButton.titleLabel?.textColor = appDefaults.color
            
            cell.rightButtons = [addButton]
            cell.rightSwipeSettings.transition = MGSwipeTransition.clipCenter
            cell.rightExpansion.buttonIndex = 0
            cell.rightExpansion.fillOnTrigger = false
            cell.rightExpansion.threshold = 1
            
            cell.leftButtons = [routeButton]
            cell.leftSwipeSettings.transition = MGSwipeTransition.clipCenter
            cell.leftExpansion.buttonIndex = 0
            cell.leftExpansion.fillOnTrigger = true
            cell.leftExpansion.threshold = 1
            
        }else if mode == .edit{
            cell.rightButtons.removeAll()
            cell.leftButtons.removeAll()
            let deleteButton = MGSwipeButton(title: "Delete",icon: UIImage(named: "location_icon"),backgroundColor: UIColor.red,padding: 25)
            deleteButton?.centerIconOverText()
            cell.leftButtons = [deleteButton]
            cell.leftSwipeSettings.transition = MGSwipeTransition.clipCenter
            cell.leftExpansion.buttonIndex = 0
            cell.leftExpansion.fillOnTrigger = true
            cell.leftExpansion.threshold = 1
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showBusinessDetail"){
            let upcoming: BusinessDetailViewController = segue.destination as! BusinessDetailViewController
            
            let index = (listTableView.indexPathForSelectedRow! as NSIndexPath).row
            print(index)
            
            // IF NO NEW PLACE IS ADDED
            if placeArray[index].name != ""{
                let gPlaceObject = placeArray[index]
                upcoming.gPlaceObject = gPlaceObject
                upcoming.index = index
            }else{
                // IF NEW PLACES ARE ADDED
                let businessObject = playlistArray[index]
                upcoming.object = businessObject
                upcoming.index = index
            }
            
            self.listTableView.deselectRow(at: listTableView.indexPathForSelectedRow!, animated: true)
        }else if (segue.identifier == "tapImageButton"){
            let nav = segue.destination as! UINavigationController
            let upcoming = nav.childViewControllers[0] as! SearchBusinessViewController
            upcoming.currentView = .addPlace
            upcoming.searchTextField = upcoming.addPlaceSearchTextField
        }
    }

    func getIDsFromArrayOfBusiness(_ business: [Business], completion: (_ result:[String])->Void){
        var result:[String] = []
        for b in business{
            result.append(b.gPlaceID)
        }
        completion(result)
    }
    
    func sortMethods(_ businesses: Array<Business>, type: String)->[Business]{
        var sortedBusinesses: Array<Business> = []
        if type == "name"{
            sortedBusinesses = businesses.sorted{$0.businessName < $1.businessName}
        } else if type == "rating"{
            sortedBusinesses = businesses.sorted{$0.businessRating > $1.businessRating}
        }
        return sortedBusinesses
    }
    
    func sortGooglePlaces(_ gPlaces: [GooglePlaceDetail],type:String) -> [GooglePlaceDetail]{
        var sortedBusinesses: Array<GooglePlaceDetail> = []
        if type == "name"{
            sortedBusinesses = gPlaces.sorted{$0.name < $1.name}
        } else if type == "rating"{
            sortedBusinesses = gPlaces.sorted{$0.rating > $1.rating}
        }
        return sortedBusinesses
        
    }

    
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlistArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128.5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let businessCell = tableView.dequeueReusableCell(withIdentifier: "businessCell", for: indexPath) as! BusinessTableViewCell
        businessCell.selectionStyle = .none
        
        //businessCell.delegate = self
        configureSwipeButtons(businessCell, mode: .view)
        
        DispatchQueue.main.async(execute: {
            businessCell.configureCellWith(self.playlistArray[(indexPath as NSIndexPath).row], mode: .more) {
                return businessCell
            }
        })
        return businessCell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showBusinessDetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell  = tableView.cellForRow(at: indexPath) as! BusinessTableViewCell
        cell.mainView.backgroundColor = UIColor.selectedGray()
        cell.businessBackgroundImage.alpha = 0.8
        cell.BusinessRating.backgroundColor = UIColor.selectedGray()
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell  = tableView.cellForRow(at: indexPath) as! BusinessTableViewCell
        cell.mainView.backgroundColor = UIColor.white
        cell.businessBackgroundImage.alpha = 1
        cell.BusinessRating.backgroundColor = UIColor.clearColor()
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if self.mode == .edit{
            return true
        }else{
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        let itemToMove = playlistArray[(fromIndexPath as NSIndexPath).row]
        let placeItemToMove = placeArray[(fromIndexPath as NSIndexPath).row]
        let idOfItemToMove = placeIDs[(fromIndexPath as NSIndexPath).row]
        
        playlistArray.remove(at: (fromIndexPath as NSIndexPath).row)
        placeArray.remove(at: (fromIndexPath as NSIndexPath).row)
        placeIDs.remove(at: (fromIndexPath as NSIndexPath).row)
        
        playlistArray.insert(itemToMove, at: (toIndexPath as NSIndexPath).row)
        placeArray.insert(placeItemToMove, at: (toIndexPath as NSIndexPath).row)
        placeIDs.insert(idOfItemToMove, at: (toIndexPath as NSIndexPath).row)
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            playlistArray.remove(at: (indexPath as NSIndexPath).row)
            placeArray.remove(at: (indexPath as NSIndexPath).row)
            placeIDs.remove(at: (indexPath as NSIndexPath).row)
            self.listTableView.deleteRows(at: [indexPath], with: .fade)
            self.listTableView.reloadData()
        }
        
    }

    
}

extension ListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0{
            self.indicatorView.showShadow(0.2)
        }else{
            self.indicatorView.hideShadow()
        }
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        self.indicatorView.hideShadow()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y < 0{
            self.indicatorView.hideShadow()
        }
    }
}

extension ListViewController: MKMapViewDelegate{
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        print("done finished loading")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't want to show a custom image if the annotation is the user's location.
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView = av
        }
        
        if let annotationView = annotationView {
            // Configure your annotation view here
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "annotation")
        }
        
        return annotationView
    }

}

extension ListViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer {
            let location = touch.location(in: self.listTableView)
            return (self.listTableView.indexPathForRow(at: location) == nil)
        }
        return true
    }
}

extension ListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
}

extension ListViewController: ModalViewControllerDelegate{
    
    func sendValue(_ value: AnyObject){
        itemReceived.append(value as! NSObject)
        
        for item in itemReceived{
            if (item as! NSObject) as! String == "Alphabetical"{
                self.playlistArray = self.sortMethods(self.playlistArray, type: "name")
                getIDsFromArrayOfBusiness(self.playlistArray, completion: { (result) in
                    self.placeIDs = result
                    self.placeArray = self.sortGooglePlaces(self.placeArray, type: "name")
                    print("sorting")
                    self.listTableView.reloadData()
                })
            }else if (item as! NSObject) as! String == "Rating"{
                self.playlistArray = self.sortMethods(self.playlistArray, type: "rating")
                getIDsFromArrayOfBusiness(self.playlistArray, completion: { (result) in
                    self.placeIDs = result
                    self.placeArray = self.sortGooglePlaces(self.placeArray, type: "rating")
                    self.listTableView.reloadData()
                })
                
            }
            else {
                let index = item as! Int
                var playlist = addToOwnPlaylists[index]["place_id_list"] as! [String]
                print(playlist)
                playlist.append(self.playlist_swiped)
                print(playlist)
                
                addToOwnPlaylists[index]["num_places"] = playlist.count
                addToOwnPlaylists[index]["place_id_list"] = playlist
                addToOwnPlaylists[index].saveInBackground(block: { (success, error) in
                    if (error == nil) {
                        print("Saved")
                    }
                })
            }
            itemReceived = []
        }
        
        
    }

    func showActionsMenu(_ sender: AnyObject) {
        let actionController = YoutubeActionController()
        let pickerController = CZPickerViewController()
        //let randomController = RandomPlaceController()
        
//        actionController.addAction(Action(ActionData(title: "Randomize", image: UIImage(named: "action_random")!), style: .Default, handler: { action in
//            if self.playlistArray.count != 0{
//                self.performSegueWithIdentifier("randomPlace", sender: self)
//            }
//            
//        }))
        actionController.addAction(Action(ActionData(title: "Edit", image: UIImage(named: "action_edit")!), style: .Default, handler: { action in
            print("Edit pressed")
            self.activateEditMode()
            self.listTableView.reloadData()
        }))
//        actionController.addAction(Action(ActionData(title: "Make Collaborative", image: UIImage(named: "action_collab")!), style: .Default, handler: { action in
//            self.makeCollaborative()
//        }))
        actionController.addAction(Action(ActionData(title: "Sort", image: UIImage(named: "action_sort")!), style: .Cancel, handler: { action in
            pickerController.headerTitle = "Sort Options"
            pickerController.fruits = ["Alphabetical","Rating"]
            pickerController.showWithFooter(UIViewController)
            pickerController.delegate = self
        }))
        actionController.addAction(Action(ActionData(title: "Cancel", image: UIImage(named: "yt-cancel-icon")!), style: .Cancel, handler: nil))
        
        presentViewController(actionController, animated: true, completion: nil)
    }
}
