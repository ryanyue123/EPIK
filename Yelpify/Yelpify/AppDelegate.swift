    //
//  AppDelegate.swift
//  Yelpify
//
//  Created by Ryan Yue on 2/10/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import Parse
import GoogleMaps
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Parse.enableLocalDatastore()
        
        // Initialize Parse.
        Parse.setApplicationId("VGI8bzJyUoObJ7fI1sRSnkCkpH9K452EP4tHPdUi",
            clientKey: "CPDodCFeYryaK1aq2VfgGy8eok1LXNwXGntkxW00")
        
        // Initialize Google Places API.
        GMSServices.provideAPIKey("AIzaSyCKY_SOq4ivZp9b3oB8mmkBaKqHbLrbDlg")
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "Montserrat-Regular", size: 16)!,
            NSForegroundColorAttributeName: UIColor.whiteColor()     ]
        
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        
        //UINavigationBar.appearance().backgroundColor = UIColor.darkGrayColor()
        //UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarMetrics: .Default)
        
        //UILabel.appearance().font = UIFont(name: "Montserrat", size: 14)
        
        
        // Set navigation bar tint / background colour
//        UINavigationBar.appearance().barTintColor = UIColor.whiteColor()
//        
//        UINavigationBar.appearance().backgroundColor = UIColor.whiteColor()
//        
        // Set navigation bar ItemButton tint colour
        //UIBarButtonItem.appearance().tintColor = UIColor.orangeColor()
        
        //Set navigation bar Back button tint colour
        //UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions:
            launchOptions)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}




