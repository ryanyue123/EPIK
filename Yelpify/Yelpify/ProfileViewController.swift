//
//  ProfileViewController.swift
//  Yelpify
//
//  Created by Jonathan Lam on 4/15/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    
    // MARK: - View Setup Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
//    // MARK: - Configure Methods
//    
//    private let headerHeight: CGFloat = 300.0
//    
//    func configureNavigationBar(){
//        addShadowToBar()
//        for parent in self.navigationController!.navigationBar.subviews {
//            for childView in parent.subviews {
//                if(childView is UIImageView) {
//                    childView.removeFromSuperview()
//                }
//            }
//        }
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
//        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
//        
//    }
//    
//    func configureHeaderView(){
//        tableView.tableHeaderView = nil
//        tableView.addSubview(headerView)
//        tableView.contentInset = UIEdgeInsets(top: headerHeight, left: 0, bottom: 0, right: 0)
//        tableView.contentOffset = CGPoint(x: 0, y: -headerHeight)
//    }
//    
//    func updateHeaderView(){
//        var headerRect = CGRect(x: 0, y: -headerHeight, width: self.tableView.frame.size.width, height: headerHeight)
//        
//        if self.tableView.contentOffset.y < -headerHeight{
//            headerRect.origin.y = tableView.contentOffset.y
//            headerRect.size.height = -tableView.contentOffset.y
//            print("high")
//        }else if self.tableView.contentOffset.y > headerHeight{
//            self.navigationItem.title = "hi"
//            self.navigationItem.titleView?.tintColor = UIColor.whiteColor()
//            print("low")
//        }
//        
//        headerView.frame = headerRect
//    }
//    
//    func addShadowToBar() {
//        let shadowView = UIView(frame: self.navigationController!.navigationBar.frame)
//        //shadowView.backgroundColor = appDefaults.color
//        shadowView.layer.masksToBounds = false
//        shadowView.layer.shadowOpacity = 0.7 // your opacity
//        shadowView.layer.shadowOffset = CGSize(width: 0, height: 3) // your offset
//        shadowView.layer.shadowRadius =  10 //your radius
//        self.view.addSubview(shadowView)
//        self.view.bringSubviewToFront(shadowView)
//        
//        shadowView.tag = 102
//    }
//
//    
//    
//    // MARK: - Scroll View
//    
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        self.fadeBG()
//        self.updateHeaderView()
//        self.handleNavigationBarOnScroll()
//    }
//    
//    func fadeBG(){
//        print(-tableView.contentOffset.y / headerHeight)
//        self.darkOverlay.alpha = 1.6 - (-tableView.contentOffset.y / headerHeight)
//        if self.darkOverlay.alpha < 0.6{ self.darkOverlay.alpha = 0.6 }
//    }
//    
//    func handleNavigationBarOnScroll(){
//        let showWhenScrollDownAlpha = 1 - (-tableView.contentOffset.y / headerHeight)
//        
//        self.navigationController?.navigationBar.titleTextAttributes = [
//            NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(showWhenScrollDownAlpha) ]
//        self.navigationItem.title = "details"
//        
//        // Handle Status Bar
//        //self.statusBarView.alpha = showWhenScrollDownAlpha
//        
//        // Handle Nav Shadow View
//        self.view.viewWithTag(102)!.backgroundColor = appDefaults.color.colorWithAlphaComponent(showWhenScrollDownAlpha)
//    }
//
//    
    // MARK: - Table View Methods

}
