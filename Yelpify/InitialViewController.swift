//
//  InitialViewController.swift
//  Yelpify
//
//  Created by Ryan Yue on 4/29/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import Parse
import Async

class InitialViewController: UIViewController {

    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var background: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        print(PFUser.currentUser())
        if (PFUser.currentUser() == nil) {
            self.animate()
            Async.main(after: 0.5){
                self.performSegueWithIdentifier("loginscreen", sender: self)
            }
        }else{
            self.animate()
            Async.main(after: 0.5){
                self.performSegueWithIdentifier("showHome", sender: self)
            }
        }
    }
    
    func animate(){
        UIView.animateWithDuration(1, animations: {
            self.background.transform = CGAffineTransformMakeScale(1.2, 1.2)
            self.logo.transform = CGAffineTransformMakeScale(0.9, 0.9)
        })
    }

}
