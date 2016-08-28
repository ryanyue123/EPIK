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

class ListViewController: UIViewController {
    
    @IBOutlet var topView: UIView!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var indicatorView: UIView!
    
    @IBOutlet var listTypeLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var numPlacesLabel: UILabel!
    @IBOutlet var placesLabel: UILabel!
    
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var listTableView: UITableView!
    
    var object: PFObject!
    var playlistArray = [Business]()
    
    var placeArray = [GooglePlaceDetail]()
    var placeIDs = [String]()
    var apiClient = APIDataHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bottomView.addShadow()
        self.indicatorView.addShadow(opacity: 0.2, offset: CGSize(width: 0, height: 5))
        self.indicatorView.hideShadow()
        
        self.loadData()

        configureRecognizers()
        
        self.listTableView.delegate = self
        self.listTableView.dataSource = self
        
        // set initial location in Honolulu
        let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
        centerMapOnLocation(initialLocation)
        
        // Do any additional setup after loading the view.
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
                recognizer.view!.frame = CGRect(x: self.originalFrame.origin.x, y: finalY, width: self.originalFrame.width, height: self.originalFrame.height)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureSwipeButtons(cell: MGSwipeTableCell, mode: ListMode){
        if mode == .View{
            let routeButton = MGSwipeButton(title: "ROUTE", icon: UIImage(named: "swipe_route"),backgroundColor: appDefaults.color, padding: 25)
            routeButton.setEdgeInsets(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 15))
            routeButton.centerIconOverText()
            routeButton.titleLabel?.font = appDefaults.font
            
            let addButton = MGSwipeButton(title: "ADD", icon: UIImage(named: "swipe_add"),backgroundColor: appDefaults.color, padding: 25)
            addButton.setEdgeInsets(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 15))
            addButton.centerIconOverText()
            addButton.titleLabel?.font = appDefaults.font
            
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
        
        //businessCell.delegate = self
        configureSwipeButtons(businessCell, mode: .View)
        
        dispatch_async(dispatch_get_main_queue(), {
            businessCell.configureCellWith(self.playlistArray[indexPath.row], mode: .More) {
                return businessCell
            }
        })
        return businessCell

    }
    
}

extension ListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
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
