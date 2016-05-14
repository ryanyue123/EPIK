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

class SearchPagerTabStrip: ButtonBarPagerTabStripViewController {
    
    var isReload = false
    
    var chosenCoordinates: String!
    
    @IBOutlet weak var searchTextField: UITextField!
    override func viewDidLoad() {
        
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
        
        // Setup Navigation Bar
        let navigationBar = navigationController!.navigationBar
        navigationBar.tintColor = UIColor.whiteColor()
        
        let leftButton =  UIBarButtonItem(image: UIImage(named: "sort_icon"), style: .Plain, target: self, action: nil)
        let rightButton = UIBarButtonItem(image: UIImage(named: "location_icon"), style: .Plain, target: self, action: "pressedLocation:")
        
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton
    }
    
    func pressedLocation(sender: UIBarButtonItem){
        performSegueWithIdentifier("pickLocation", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pickLocation" {
            let navVC = segue.destinationViewController as! UINavigationController
            let destVC = navVC.childViewControllers[0] as! GPlacesSearchViewController
            
            DataFunctions.getLocation({ (coordinates) in
                destVC.currentLocationCoordinates = "\(coordinates.latitude),\(coordinates.longitude)"
                print("Sending location \(coordinates.latitude),\(coordinates.longitude)")
                
            })
        }
    }
    
    // MARK: - PagerTabStripDataSource
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let searchPlaylistVC = storyboard.instantiateViewControllerWithIdentifier("searchPlaylistVC") as! SearchPlaylistCollectionViewController
        searchPlaylistVC.searchTextField = self.searchTextField
        let searchBusinessVC = storyboard.instantiateViewControllerWithIdentifier("searchBusinessVC") as! SearchBusinessViewController
        searchBusinessVC.searchTextField = self.searchTextField
        let searchPeopleVC = storyboard.instantiateViewControllerWithIdentifier("searchPeopleVC") as! SearchPeopleTableViewController
        searchPeopleVC.searchTextField = self.searchTextField
        
        let child_1 = searchBusinessVC
        let child_2 = searchPlaylistVC
        let child_3 = searchPeopleVC
        guard isReload else {
            return [child_1, child_2, child_3]
        }
        
        var childViewControllers = [child_1, child_2, child_3]
        
        for (index, _) in childViewControllers.enumerate(){
            let nElements = childViewControllers.count - index
            let n = (Int(arc4random()) % nElements) + index
            if n != index{
                swap(&childViewControllers[index], &childViewControllers[n])
            }
        }
        let nItems = 1 + (rand() % 8)
        return Array(childViewControllers.prefix(Int(nItems)))
    }
    
    override func reloadPagerTabStripView() {
        isReload = true
        if rand() % 2 == 0 {
            pagerBehaviour = .Progressive(skipIntermediateViewControllers: rand() % 2 == 0 , elasticIndicatorLimit: rand() % 2 == 0 )
        }
        else {
            pagerBehaviour = .Common(skipIntermediateViewControllers: rand() % 2 == 0)
        }
        super.reloadPagerTabStripView()
    }
}