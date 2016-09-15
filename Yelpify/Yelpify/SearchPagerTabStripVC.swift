//
//  SearchPagerTabStripVC.swift
//  Yelpify
//
//  Created by Jonathan Lam on 4/30/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import XLPagerTabStrip
import UIKit
import Parse
import Foundation
import XLActionController
import Async

class SearchPagerTabStrip: ButtonBarPagerTabStripViewController, ModalViewControllerDelegate, Dimmable {
    
    var isReload = false
    
    var chosenCoordinates: String!
    var currentCity: String!
    
    var itemReceived: Array<AnyObject> = []
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBAction func unwindToSearchPagerTapStrip(_ segue: UIStoryboardSegue) {
        dim(.Out, alpha: dimLevel, speed: dimSpeed)
        if (segue.identifier != nil){
//            if segue.identifier == "unwindFromLocation"{
//                print("unwindFromLocation")
//                dim(.Out, alpha: dimLevel, speed: dimSpeed)
//                UIView.animateWithDuration(0.2, animations: {
//                    self.navigationController?.navigationBar.alpha = 1
//                })
////                if let searchPlaceVC = self.childViewControllers[0] as? SearchBusinessViewController{
////                    searchPlaceVC.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
////                }
//            }
        }
    }
    
    @IBAction func unwindToSearchPagerTapStripWithLocation(_ segue: UIStoryboardSegue) {
        if (segue.identifier != nil){
            if segue.identifier == "unwindFromNewLocation"{
                dim(.Out, alpha: dimLevel, speed: dimSpeed)
                UIView.animateWithDuration(0.2, animations: {
                    self.navigationController?.navigationBar.alpha = 1
                })
                
                let locationVC = segue.source as! LocationSearchViewController
                self.chosenCoordinates = locationVC.currentLocationCoordinates
                self.currentCity = locationVC.currentCity
                
                print(currentCity)
                print(chosenCoordinates)
                
                if let searchBusinessVC = self.childViewControllers[0] as? SearchBusinessViewController{
                    searchBusinessVC.googleParameters["location"] = chosenCoordinates
                    if searchBusinessVC.searchQuery != ""{
                        searchBusinessVC.searchWithKeyword(searchBusinessVC.searchQuery)
                    }else{
                        searchBusinessVC.searchQuery = "food"
                        searchBusinessVC.searchWithKeyword("food")
                    }
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, withEvent event: UIEvent?) {
        searchTextField.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        
        if sharedVariables.currentCoordinates == ""{
            Async.background{
                DataFunctions.getLocation({ (coordinates) in
                    self.chosenCoordinates = "\(coordinates.latitude),\(coordinates.longitude)"
                })
            }
        }else{
            self.chosenCoordinates = sharedVariables.currentCoordinates
        }
        
        // change selected bar color
        settings.style.buttonBarBackgroundColor = appDefaults.color
        settings.style.buttonBarItemBackgroundColor = .whiteColor()
        settings.style.selectedBarBackgroundColor = appDefaults.color
        settings.style.buttonBarItemFont = .boldSystemFontOfSize(14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = UIColor.grayColor()
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        //settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = -1

        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = UIColor.grayColor()
            newCell?.label.textColor = appDefaults.color
        }
        
        super.viewDidLoad()
        
        // Configure Functions
        self.navigationController?.configureTopBar()
        
        setupBarButtonItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupBarButtonItems()
    }
    
    func setupBarButtonItems(){
        let leftButton =  UIBarButtonItem(image: UIImage(named: "sort_icon"), style: .plain, target: self, action: "pressedSearchBy:")
        let rightButton = UIBarButtonItem(image: UIImage(named: "location_icon"), style: .plain, target: self, action: "pressedLocation:")
        
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton
    }
    
    fileprivate let dimLevel: CGFloat = 0.8
    fileprivate let dimSpeed: Double = 0.5
    
    func pressedLocation(_ sender: UIBarButtonItem){
        self.navigationController?.navigationBar.alpha = 0.5
        dim(.In, alpha: dimLevel, speed: dimSpeed)
        performSegueWithIdentifier("pickLocation", sender: self)
    }
    
    func sendValue(_ value: AnyObject){
        itemReceived.append(value as! NSObject)
        print(String(describing: itemReceived))
    }
    
    func pressedSearchBy(_ sender: UIBarButtonItem){
        // Open Now, By Distance
        let pickerController = CZPickerViewController()
        pickerController.fruits = ["Open Now","Distance"]
        pickerController.headerTitle = "Search By"
        pickerController.showWithMultipleSelections(UIViewController)
        pickerController.delegate = self
    }
    
    override func prepareForSegue(_ segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pickLocation" {
            let navVC = segue.destination as! UINavigationController
            let destVC = navVC.childViewControllers[0] as! LocationSearchViewController
            
            destVC.currentCity = self.currentCity
            destVC.currentLocationCoordinates = self.chosenCoordinates
            
//            DataFunctions.getLocation({ (coordinates) in
//                //destVC.currentLocationCoordinates = "\(coordinates.latitude),\(coordinates.longitude)"
//                print("Sending location \(coordinates.latitude),\(coordinates.longitude)")
//                
//            })
        }
    }
    
    // MARK: - PagerTabStripDataSource
    
//    override func pagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int) {
//        searchTextField.resignFirstResponder()
//    }
    
    override func viewControllersForPagerTabStrip(_ pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let searchPlaylistVC = storyboard.instantiateViewController(withIdentifier: "searchPlaylistVC") as! SearchPlaylistCollectionViewController
        searchPlaylistVC.searchTextField = self.searchTextField
        
        let searchBusinessVC = storyboard.instantiateViewController(withIdentifier: "searchBusinessVC") as! SearchBusinessViewController
        searchBusinessVC.searchTextField = self.searchTextField
        
        let searchPeopleVC = storyboard.instantiateViewController(withIdentifier: "searchPeopleVC") as! SearchPeopleTableViewController
        searchPeopleVC.searchTextField = self.searchTextField
        
        let child_1 = searchBusinessVC
        let child_2 = searchPlaylistVC
        let child_3 = searchPeopleVC
        
        guard isReload else {
            return [child_1, child_2, child_3]
        }
        
        var childViewControllers = [child_1, child_2, child_3]
        
        for (index, _) in childViewControllers.enumerated(){
            let nElements = childViewControllers.count - index
            let n = (Int(arc4random()) % nElements) + index
            if n != index{
                swap(&childViewControllers[index], &childViewControllers[n])
                searchTextField.resignFirstResponder()
                self.view.endEditing(true)
            }
        }
        let nItems = 1 + (arc4random() % 8)
        return Array(childViewControllers.prefix(Int(nItems)))
    }
    
    
    override func reloadPagerTabStripView() {
        isReload = true
        if arc4random() % 2 == 0 {
            pagerBehaviour = .Progressive(skipIntermediateViewControllers: arc4random() % 2 == 0 , elasticIndicatorLimit: arc4random() % 2 == 0 )
        }
        else {
            pagerBehaviour = .Common(skipIntermediateViewControllers: arc4random() % 2 == 0)
        }
        searchTextField.resignFirstResponder()
        self.view.endEditing(true)
        super.reloadPagerTabStripView()
    }
}
