//
//  LoginViewController.swift
//  Yelpify
//
//  Created by Kay Lab on 4/15/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    let loginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["email"]
        return button
    }()
    

    @IBOutlet weak var fbLogin: UIView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
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
    override func viewDidAppear(animated: Bool) {
        if (PFUser.currentUser() == nil) {
            let logInViewController = PFLogInViewController()
            logInViewController.delegate = self
            
            let signUpViewController = PFSignUpViewController()
            signUpViewController.delegate = self
            
            logInViewController.signUpController = signUpViewController
            
            self.presentViewController(logInViewController, animated: true, completion: nil)
            
        }

    }
    func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
        if (!username.isEmpty || !password.isEmpty)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        print("failed to login")
    }
    func signUpViewController(signUpController: PFSignUpViewController, shouldBeginSignUp info: [String : String]) -> Bool {
        if let password = info["password"]
        {
            return password.utf16.count >= 8
        }
        else
        {
            return false
        }
    }
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func signUpViewController(signUpController: PFSignUpViewController, didFailToSignUpWithError error: NSError?) {
        print("failed to signup")
    }
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController) {
        print("signup canceled")
    }

    func fetchProfile() {
        print("Profile Fetched!")
        let parameters = ["fields": "email, first_name, last_name, picture.type(large)"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).startWithCompletionHandler{(connection, result, error) -> Void in
            
            var results = result as! NSDictionary
            if (error != nil)
            {
                print(error)
                return

            }
            else
            {
                let object = PFObject(className: "User")
                if let email = results["email"] as? String{
                    object["email"] = email
                    print(email)
                }
                if let picture = results["picture"] as? NSDictionary, data = picture["data"] as? NSDictionary,
                    url = data["url"] as? String {
                    object["profpicture"] = url
                    print(url)
                }
                if let first_name = results["first_name"] as? String{
                    object["first_name"] = first_name
                    print(first_name)
                }
                if let last_name = results["last_name"] as? String{
                    object["last_name"] = last_name
                    print(last_name)
                }
                if let id = results["id"] as? String{
                    object["username"] = id
                    print(id)
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
            self.performSegueWithIdentifier("loginSuccessSegue", sender: self)
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


