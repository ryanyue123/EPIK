//
//  ConfigureFunctions.swift
//  Yelpify
//
//  Created by Jonathan Lam on 4/22/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import Foundation
import UIKit

struct ConfigureFunctions {
    static func configureStatusBar(navController: UINavigationController) -> UIView{
        let statusBarRect = CGRect(x: 0, y: 0, width: navController.view.frame.size.width, height: 20.0)
        let statusBarView = UIView(frame: statusBarRect)
        statusBarView.backgroundColor = appDefaults.color
        navController.view.addSubview(statusBarView)
        return statusBarView
    }
    
    static func configureNavigationBar(navController: UINavigationController, outterView: UIView) -> UIView{
        func addShadowToBar() -> UIView{
            let shadowView = UIView(frame: navController.navigationBar.frame)
            shadowView.layer.masksToBounds = false
            shadowView.layer.shadowOpacity = 0.7 // your opacity
            shadowView.layer.shadowOffset = CGSize(width: 0, height: 3) // your offset
            shadowView.layer.shadowRadius =  10 //your radius
            outterView.addSubview(shadowView)
            //outterView.bringSubviewToFront(statusBarView)
            
            //shadowView.tag = 100
            return shadowView
        }
        
        for parent in navController.navigationBar.subviews {
            for childView in parent.subviews {
                if(childView is UIImageView) {
                    childView.removeFromSuperview()
                }
            }
        }
        
        navController.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        navController.navigationBar.backgroundColor = appDefaults.color
        
        return addShadowToBar()
    }
}