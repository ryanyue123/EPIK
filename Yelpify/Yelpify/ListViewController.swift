//
//  ListViewController.swift
//  Lyster
//
//  Created by Jonathan Lam on 8/25/16.
//  Copyright © 2016 Limitless. All rights reserved.
//

import UIKit
import MapKit
import Parse
import Async
import MGSwipeTableCell
import XLActionController
import CZPicker

class ListViewController: UIViewController, Dimmable {
    
    enum ListMode{
        case View, Edit
    }
    
    @IBOutlet var topView: UIView!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var indicatorView: UIView!
    @IBOutlet var pullDownBar: UIView!
    
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
    
    var mode: ListMode! = .View
    
    @IBAction func unwindToSinglePlaylist(segue: UIStoryboardSegue)
    {
        print(segue.identifier)
        if(segue.identifier != nil) {
            if(segue.identifier == "unwindToPlaylist") {
                if let sourceVC = segue.sourceViewController as? SearchBusinessViewController
                {
                    playlistArray.appendContentsOf(sourceVC.businessArray)
                    placeIDs.appendContentsOf(sourceVC.placeIDs)
                    
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

    
    @IBAction func pressedAddPlacesButton(sender: AnyObject) {
        performSegueWithIdentifier("tapImageButton", sender: self)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.configureTopBar()
//        self.changeTopBarColor(.clearColor())
        
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
        
        // set initial location in Honolulu
        let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
        centerMapOnLocation(initialLocation)
        
        let rightButton = UIBarButtonItem(image: UIImage(named: "more_icon"), style: .Plain, target: self, action: #selector(self.showActionsMenu(_:)))
        navigationItem.rightBarButtonItem = rightButton
    }
    

    func loadData(){
        func updateBusinessesFromIDs(ids:[String], reloadIndex: Int = 0){
            if ids.count > 0{
                apiClient.performDetailedSearch(ids[0]) { (detailedGPlace) in
                    self.placeArray[reloadIndex] = detailedGPlace
                    self.playlistArray[reloadIndex] = detailedGPlace.convertToBusiness()
                    
                    let idsSlice = Array(ids[1..<ids.count])
                    let index = NSIndexPath(forRow: reloadIndex, inSection: 0)
                    self.listTableView.reloadRowsAtIndexPaths([index], withRowAnimation: .Fade) // CHANGE
                    let newIndex = reloadIndex + 1
                    updateBusinessesFromIDs(idsSlice, reloadIndex: newIndex)
                }
            }
        }

        
        // Register Nibs
        self.listTableView.registerNib(UINib(nibName: "BusinessCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "businessCell")
        
        Async.main{
            let placeIDs = self.object["place_id_list"] as! [String]
            self.placeIDs = placeIDs
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
    
    func activateEditMode() {
        
        // Make Title Text Editable
        self.titleTextField.enable()
        self.titleTextField.delegate = self
        
        // Show Change BG Image Button
        //self.changePlaylistImageButton.hidden = false
        
        // Replace More Button With Cancel Button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(self.deactivateEditMode))
        
        // Animate and Show Add Place Button
        self.addPlaceButton.hidden = false
        UIView.animateWithDuration(0.3,delay: 0.0,options: UIViewAnimationOptions.BeginFromCurrentState,animations: {
            self.addPlaceButton.transform = CGAffineTransformMakeScale(0.5, 0.5)},
                                   completion: { finish in
                                    UIView.animateWithDuration(0.6){self.addPlaceButton.transform = CGAffineTransformIdentity}
        })
        
        // Set Editing to True
        self.setEditing(true, animated: true)
        
        // Set Edit Mode
        self.mode = .Edit
        
        // Replace Back Button with Done
        self.navigationItem.setHidesBackButton(true, animated: true)
        let backButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.savePlaylistToParse(_:)))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    func deactivateEditMode() {
        
        // Make Title Text Editable
        self.titleTextField.disable()
        self.titleTextField.delegate = nil
        
        // Hide Change BG Image Button
        //self.changePlaylistImageButton.hidden = true
        
        // Restore More Icon to Right Side of Nav Bar
        let rightButton = UIBarButtonItem(image: UIImage(named: "more_icon"), style: .Plain, target: self, action: "showActionsMenu:")
        navigationItem.rightBarButtonItem = rightButton
        
        // Restore Back Button
        self.navigationItem.setHidesBackButton(false, animated: true)
        self.navigationItem.leftBarButtonItem = nil
        
        // Set Editing to False
        self.setEditing(false, animated: true)
        
        // Hide Add Place Button
        self.addPlaceButton.hidden = true
        // Change to View Mode
        self.mode = .View
    }

    
    
    // MARK: - SAVE PLAYLIST
    func savePlaylistToParse(sender: UIBarButtonItem)
    {
        
        func getAveragePrice(completion:(avg: Int) -> Void){
            var total = 0.0
            var numOfPlaces = 0.0
            for place in self.placeArray{
                if place.priceRating != -1{
                    total += Double(place.priceRating)
                    numOfPlaces += 1
                }
            }
            if numOfPlaces > 0{
                completion(avg: Int(round(total/numOfPlaces)))
            }else{
                completion(avg: -1)
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

    
    let regionRadius: CLLocationDistance = 1000
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
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
    
    func handleTapGR(recognizer: UITapGestureRecognizer){
        if self.bottomView.y != (self.view.frame.height * 7/10){
    
        }
    }
    
    func handlePanGR(recognizer: UIPanGestureRecognizer){
        let translation = recognizer.translationInView(self.view)
        
        let viewTranslation = originalFrame.origin.y + translation.y
        
        if (viewTranslation > (self.view.height * 1/5)) && (viewTranslation < (self.view.height * 7/10)) {
            self.bottomView.y = originalFrame.origin.y + translation.y
        }
        
        if recognizer.state == .Ended{
            
            let velocity = recognizer.velocityInView(self.view)
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
                self.listTableView.scrollEnabled = false
            }else{
                self.listTableView.scrollEnabled = true
            }
            
            
            UIView.animateWithDuration(Double(slideFactor/10), delay: 0, usingSpringWithDamping: 3, initialSpringVelocity: 4, options: .CurveEaseOut, animations: {
                recognizer.view!.y = finalY
                }, completion: { (_) in
                    self.originalFrame = self.bottomView.frame
            })
        }
        
        //print("location", location)
        //print("translation", translation)
        
        //print("velocity", velocity, "magnitude", magnitude)
    }
    
    func handleTouchRemoved(view: UIView){
        originalFrame = self.bottomView.frame
    }
    
    func configureSwipeButtons(cell: MGSwipeTableCell, mode: ListMode){
        if mode == .View{
            let routeButton = MGSwipeButton(title: "ROUTE", icon: UIImage(named: "swipe_route")!.imageWithColor(appDefaults.color),backgroundColor: UIColor.clearColor(), padding: 25)
            routeButton.setEdgeInsets(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 0))
            routeButton.centerIconOverText()
            routeButton.titleLabel?.font = appDefaults.font
            routeButton.titleLabel?.textColor = appDefaults.color
            
            let addButton = MGSwipeButton(title: "ADD", icon: UIImage(named: "swipe_add")!.imageWithColor(appDefaults.color) ,backgroundColor: UIColor.clearColor(), padding: 25)
            addButton.setEdgeInsets(UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 15))
            addButton.centerIconOverText()
            addButton.titleLabel?.font = appDefaults.font
            addButton.titleLabel?.textColor = appDefaults.color
            
            cell.rightButtons = [addButton]
            cell.rightSwipeSettings.transition = MGSwipeTransition.ClipCenter
            cell.rightExpansion.buttonIndex = 0
            cell.rightExpansion.fillOnTrigger = false
            cell.rightExpansion.threshold = 1
            
            cell.leftButtons = [routeButton]
            cell.leftSwipeSettings.transition = MGSwipeTransition.ClipCenter
            cell.leftExpansion.buttonIndex = 0
            cell.leftExpansion.fillOnTrigger = true
            cell.leftExpansion.threshold = 1
            
        }else if mode == .Edit{
            cell.rightButtons.removeAll()
            cell.leftButtons.removeAll()
            let deleteButton = MGSwipeButton(title: "Delete",icon: UIImage(named: "location_icon"),backgroundColor: UIColor.redColor(),padding: 25)
            deleteButton.centerIconOverText()
            cell.leftButtons = [deleteButton]
            cell.leftSwipeSettings.transition = MGSwipeTransition.ClipCenter
            cell.leftExpansion.buttonIndex = 0
            cell.leftExpansion.fillOnTrigger = true
            cell.leftExpansion.threshold = 1
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showBusinessDetail"){
            let upcoming: BusinessDetailViewController = segue.destinationViewController as! BusinessDetailViewController
            
            let index = listTableView.indexPathForSelectedRow!.row
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
            
            self.listTableView.deselectRowAtIndexPath(listTableView.indexPathForSelectedRow!, animated: true)
        }else if (segue.identifier == "tapImageButton"){
            let nav = segue.destinationViewController as! UINavigationController
            let upcoming = nav.childViewControllers[0] as! SearchBusinessViewController
            upcoming.currentView = .AddPlace
            upcoming.searchTextField = upcoming.addPlaceSearchTextField
        }
    }

    func getIDsFromArrayOfBusiness(business: [Business], completion: (result:[String])->Void){
        var result:[String] = []
        for b in business{
            result.append(b.gPlaceID)
        }
        completion(result: result)
    }
    
    func sortMethods(businesses: Array<Business>, type: String)->[Business]{
        var sortedBusinesses: Array<Business> = []
        if type == "name"{
            sortedBusinesses = businesses.sort{$0.businessName < $1.businessName}
        } else if type == "rating"{
            sortedBusinesses = businesses.sort{$0.businessRating > $1.businessRating}
        }
        return sortedBusinesses
    }
    
    func sortGooglePlaces(gPlaces: [GooglePlaceDetail],type:String) -> [GooglePlaceDetail]{
        var sortedBusinesses: Array<GooglePlaceDetail> = []
        if type == "name"{
            sortedBusinesses = gPlaces.sort{$0.name < $1.name}
        } else if type == "rating"{
            sortedBusinesses = gPlaces.sort{$0.rating > $1.rating}
        }
        return sortedBusinesses
        
    }

    
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlistArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 128.5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let businessCell = tableView.dequeueReusableCellWithIdentifier("businessCell", forIndexPath: indexPath) as! BusinessTableViewCell
        businessCell.selectionStyle = .None
        
        //businessCell.delegate = self
        configureSwipeButtons(businessCell, mode: .View)
        
        dispatch_async(dispatch_get_main_queue(), {
            businessCell.configureCellWith(self.playlistArray[indexPath.row], mode: .More) {
                return businessCell
            }
        })
        return businessCell

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showBusinessDetail", sender: self)
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        let cell  = tableView.cellForRowAtIndexPath(indexPath) as! BusinessTableViewCell
        cell.mainView.backgroundColor = UIColor.selectedGray()
        cell.businessBackgroundImage.alpha = 0.8
        cell.BusinessRating.backgroundColor = UIColor.selectedGray()
    }
    
    func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        let cell  = tableView.cellForRowAtIndexPath(indexPath) as! BusinessTableViewCell
        cell.mainView.backgroundColor = UIColor.whiteColor()
        cell.businessBackgroundImage.alpha = 1
        cell.BusinessRating.backgroundColor = UIColor.clearColor()
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if self.mode == .Edit{
            return true
        }else{
            return false
        }
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        let itemToMove = playlistArray[fromIndexPath.row]
        let placeItemToMove = placeArray[fromIndexPath.row]
        let idOfItemToMove = placeIDs[fromIndexPath.row]
        
        playlistArray.removeAtIndex(fromIndexPath.row)
        placeArray.removeAtIndex(fromIndexPath.row)
        placeIDs.removeAtIndex(fromIndexPath.row)
        
        playlistArray.insert(itemToMove, atIndex: toIndexPath.row)
        placeArray.insert(placeItemToMove, atIndex: toIndexPath.row)
        placeIDs.insert(idOfItemToMove, atIndex: toIndexPath.row)
    }
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete{
            playlistArray.removeAtIndex(indexPath.row)
            placeArray.removeAtIndex(indexPath.row)
            placeIDs.removeAtIndex(indexPath.row)
            self.listTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            self.listTableView.reloadData()
        }
        
    }

    
}

extension ListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0{
            self.indicatorView.showShadow(0.2)
        }else{
            self.indicatorView.hideShadow()
        }
    }
    
    func scrollViewDidScrollToTop(scrollView: UIScrollView) {
        self.indicatorView.hideShadow()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y < 0{
            self.indicatorView.hideShadow()
        }
    }
}

extension ListViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer {
            let location = touch.locationInView(self.listTableView)
            return (self.listTableView.indexPathForRowAtPoint(location) == nil)
        }
        return true
    }
}

extension ListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
}

extension ListViewController: ModalViewControllerDelegate{
    
    func sendValue(value: AnyObject){
        itemReceived.append(value as! NSObject)
        
        for item in itemReceived{
            if item as! NSObject == "Alphabetical"{
                self.playlistArray = self.sortMethods(self.playlistArray, type: "name")
                getIDsFromArrayOfBusiness(self.playlistArray, completion: { (result) in
                    self.placeIDs = result
                    self.placeArray = self.sortGooglePlaces(self.placeArray, type: "name")
                    print("sorting")
                    self.listTableView.reloadData()
                })
            }else if item as! NSObject == "Rating"{
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
                addToOwnPlaylists[index].saveInBackgroundWithBlock({ (success, error) in
                    if (error == nil) {
                        print("Saved")
                    }
                })
            }
            itemReceived = []
        }
        
        
    }

    func showActionsMenu(sender: AnyObject) {
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