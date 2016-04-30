//
//  AlertViewController.swift
//  Yelpify
//
//  Created by Kay Lab on 4/29/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var alert = SweetAlertViewController()
    
    
    
    
    @IBAction func warningAlert(sender: AnyObject) {
        SweetAlertViewController().showAlert("Are you sure?", subTitle: "You file will permanently delete!", style: AlertStyle.Warning, buttonTitle:"No, cancel pls!", buttonColor:UIColor.colorFromRGB(0xD0D0D0) , otherButtonTitle:  "Yes, delete it!", otherButtonColor: UIColor.colorFromRGB(0xDD6B55)) { (isOtherButton) -> Void in
            if isOtherButton == true {
                
                SweetAlertViewController().showAlert("Cancelled!", subTitle: "Your imaginary file is safe", style: AlertStyle.Error)
            }
            else {
                SweetAlertViewController().showAlert("Deleted!", subTitle: "You idiot!", style: AlertStyle.Success)
            }
        }
        
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
