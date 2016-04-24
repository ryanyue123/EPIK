//
//  LoginViewController.swift
//  Yelpify
//
//  Created by Kay Lab on 4/15/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import FBSDKLoginKit

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
        
        
        let verticalCenterConstraint = NSLayoutConstraint(item: loginButton, attribute: .CenterY, relatedBy:.Equal, toItem: self.view, attribute: .CenterY, multiplier: 1, constant: 100)
        
        let horizontalCenterConstraint = NSLayoutConstraint(item: loginButton, attribute: .CenterX, relatedBy:.Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
        
        self.view.addConstraints([verticalCenterConstraint, horizontalCenterConstraint])
        
        if let token = FBSDKAccessToken.currentAccessToken(){
            fetchProfile()
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    func fetchProfile() {
        print("Profile Fetched!")
        let parameters = ["fields": "email, first_name, last_name, picture.type(large)"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).startWithCompletionHandler{(connection, result, error) -> Void in
            if error != nil{
                print(error)
                return

            }
            let object = PFObject(classname: "User")
            if let email = result["email"] as? String{
                object["email"] = email
                print(email)
            }
            if let picture = result["picture"] as? NSDictionary, data = picture["data"] as? NSDictionary,
                url = data["url"] as? String {
                object["profpicture"] = url
                print(url)
            }
            if let first_name = result["first_name"] as? String{
                object["first_name"] = first_name
                print(first_name)
            }
            if let last_name = result["last_name"] as? String{
                object["last_name"] = last_name
                print(last_name)
            }
            
            object.saveInBackgroundWithBlock { (success, error)  -> Void in
                if (error == nil){
                    print("saved")
                }
                else{
                    print(error?.description)
                }
            }
        }
    }
    
    
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


