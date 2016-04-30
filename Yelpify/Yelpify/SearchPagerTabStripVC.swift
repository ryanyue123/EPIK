//
//  SearchPagerTabStripVC.swift
//  Yelpify
//
//  Created by Jonathan Lam on 4/30/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import XLPagerTabStrip
import UIKit
import Foundation

class SearchPagerTabStrip: ButtonBarPagerTabStripViewController {
    
    
    @IBOutlet weak var searchTextField: UITextField!
    
    var isReload = false
    
    override func viewDidLoad() {
        // change selected bar color
        settings.style.buttonBarBackgroundColor = appDefaults.color
        settings.style.buttonBarItemBackgroundColor = .whiteColor()
        settings.style.selectedBarBackgroundColor = appDefaults.color
        settings.style.buttonBarItemFont = .boldSystemFontOfSize(14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .blackColor()
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = -19
        
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .blackColor()
            newCell?.label.textColor = appDefaults.color
        }
        super.viewDidLoad()

//        buttonBarView.selectedBar.backgroundColor = .orangeColor()
//        buttonBarView.backgroundColor = UIColor(red: 7/255, green: 185/255, blue: 155/255, alpha: 1)
        
    }
    
    // MARK: - PagerTabStripDataSource
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let searchPlaylistVC = storyboard.instantiateViewControllerWithIdentifier("searchPlaylistVC") as! UITableViewController
        let searchBusinessVC = storyboard.instantiateViewControllerWithIdentifier("searchBusinessVC") as! UIViewController
        
        let child_1 = searchBusinessVC //SearchPlaylistViewController(style: .Plain , itemInfo: "Lists", textField: searchTextField)
        let child_2 = ChildExampleViewController(itemInfo: "Places")
        let child_3 = TableChildExampleViewController(style: .Grouped, itemInfo: "People")
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