//
//  InitialViewController.swift
//  Yelpify
//
//  Created by Ryan Yue on 4/29/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import Parse

class InitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        // Do any additional setup after loading the view.
//        if (PFUser.currentUser() == nil) {
//            self.performSegueWithIdentifier("loginscreen", sender: self)
//            
//        }else{
//             self.performSegueWithIdentifier("showHome", sender: self)
//        }

    }
    
    override func viewDidAppear(animated: Bool) {
        print(PFUser.currentUser())
        if (PFUser.currentUser() == nil) {
            self.performSegueWithIdentifier("loginscreen", sender: self)
            
        }else{
            self.performSegueWithIdentifier("showHome", sender: self)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
