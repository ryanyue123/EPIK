////
////  ZoomSegue.swift
////  Yelpify
////
////  Created by Jonathan Lam on 5/15/16.
////  Copyright © 2016 Yelpify. All rights reserved.
////
//
//import UIKit
//import Parse
//
//class ZoomSegue: UIStoryboardSegue {
//    
//    var objectToSet: PFObject!
//    
//    override init(identifier: String?, source: UIViewController, destination: UIViewController) {
//        super.init(identifier: identifier, source: source, destination: destination)
//    }
//    
//    override func perform() {
//        let sourceVC = self.source as! HomeViewController
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        //let destVC = storyboard.instantiateViewControllerWithIdentifier("singlePlaylistVC") as! SinglePlaylistViewController
//        let destVC = self.destination
//        
//        sourceVC.view.superview?.addSubview(destVC.view)
//        //sourceVC.view.addSubview(destVC.view)
//        
//        destVC.view.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
//        
//        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
//            destVC.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//        }) { (finished) in
//            destVC.view.removeFromSuperview()
//            
//            let time = DispatchTime.now() + Double(Int64(0.001 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
//            
//            DispatchQueue.main.asyncAfter(deadline: time, execute: {
//                sourceVC.navigationController?.pushViewController(destVC, animated: false)
//                //sourceVC.presentViewController(destVC, animated: false, completion: nil)
//            })
//            
//        }
//    }
//}
