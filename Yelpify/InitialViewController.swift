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
        self.navigationController?.navigationBar.isHidden = true
        //print(PFUser.current())
        if (PFUser.current() == nil) {
            self.animate()
            Async.main(after: 0.5){
                self.performSegue(withIdentifier: "loginscreen", sender: self)
            }
        }else{
            self.animate()
            Async.main(after: 0.5){
                self.performSegue(withIdentifier: "showHome", sender: self)
            }
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    func animate(){
        UIView.animate(withDuration: 1, animations: {
            self.background.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.logo.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        })
    }

}
