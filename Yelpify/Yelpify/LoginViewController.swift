//
//  LoginViewController.swift
//  Yelpify
//
//  Created by Kay Lab on 4/15/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    let loginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["email"]
        return button
    }()
    

    @IBOutlet weak var fbLogin: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(loginButton)
        //loginButton.center = view.center
        self.loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        //if let token = FBSDKAccessToken.currentAccessToken(){
        //fetchProfile()
        //}
        
        
        let verticalCenterConstraint = NSLayoutConstraint(item: loginButton, attribute: .CenterY, relatedBy:.Equal, toItem: self.view, attribute: .CenterY, multiplier: 1, constant: 0)
        
        let horizontalCenterConstraint = NSLayoutConstraint(item: loginButton, attribute: .CenterX, relatedBy:.Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        
        self.view.addConstraints([verticalCenterConstraint, horizontalCenterConstraint])
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    //    func fetchProfile() {
    //        print("Profile Fetched!")
    //        let parameters = ["fields": "email, first_name, last_name, picture.type(large)"]
    //        FBSDKGraphRequest(graphPath: "me", parameters: parameters).startWithCompletionHandler{(connection, result, error) -> Void in
    //            if error != nil{
    //                print(error)
    //                return
    //
    //            }
    //
    //            if let email = result["email"] as? String{
    //                print(email)
    //            }
    //
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    
}


