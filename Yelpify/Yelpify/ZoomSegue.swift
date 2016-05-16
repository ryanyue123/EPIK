//
//  ZoomSegue.swift
//  Yelpify
//
//  Created by Jonathan Lam on 5/15/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import Parse

class ZoomSegue: UIStoryboardSegue {
    
    var objectToSet: PFObject!
    
    override init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
    }
    
    override func perform() {
        let sourceVC = self.sourceViewController as! TableViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //let destVC = storyboard.instantiateViewControllerWithIdentifier("singlePlaylistVC") as! SinglePlaylistViewController
        let destVC = self.destinationViewController
        
        sourceVC.view.superview?.addSubview(destVC.view)
        //sourceVC.view.addSubview(destVC.view)
        
        destVC.view.transform = CGAffineTransformMakeScale(0.05, 0.05)
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: {
            destVC.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
        }) { (finished) in
            destVC.view.removeFromSuperview()
            
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.001 * Double(NSEC_PER_SEC)))
            
            dispatch_after(time, dispatch_get_main_queue(), {
                sourceVC.navigationController?.pushViewController(destVC, animated: false)
                //sourceVC.presentViewController(destVC, animated: false, completion: nil)
            })
            
        }
    }
}
