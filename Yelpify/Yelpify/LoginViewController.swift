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

class LoginViewController: UIViewController, UITextFieldDelegate {
    
//    let loginButton: FBSDKLoginButton = {
//        let button = FBSDKLoginButton()
//        button.readPermissions = ["email"]
//        return button
//    }()
    

    @IBOutlet weak var fbLogin: UIView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameBG: UIImageView!
    @IBOutlet weak var passwordBG: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usernameField.delegate = self
        self.passwordField.delegate = self
        
        // Add Login Button - CHANGE
        
//        view.addSubview(loginButton)
//        //loginButton.center = view.center
//        self.loginButton.translatesAutoresizingMaskIntoConstraints = false
//        
//        
//        let verticalCenterConstraint = NSLayoutConstraint(item: loginButton, attribute: .CenterY, relatedBy:.Equal, toItem: self.view, attribute: .CenterY, multiplier: 1, constant: 100)
//        
//        let horizontalCenterConstraint = NSLayoutConstraint(item: loginButton, attribute: .CenterX, relatedBy:.Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
//        
//        self.view.addConstraints([verticalCenterConstraint, horizontalCenterConstraint])
        
//        if let token = FBSDKAccessToken.currentAccessToken(){
//            fetchProfile()
//        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewDidAppear(animated: Bool) {

    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {   //delegate method
        textField.resignFirstResponder()
        if textField == usernameField{
            self.fadeNewImage(self.usernameBG, newImage: UIImage(named: "text_field_white")!)
        }else{
            self.fadeNewImage(self.passwordBG, newImage: UIImage(named: "text_field_white")!)
        }
        return true
    }
    
    @IBAction func usernameFieldDidBeginEditing(sender: AnyObject) {
        self.fadeNewImage(self.usernameBG, newImage: UIImage(named: "text_field_grey")!)
    }
    
    @IBAction func passwordFieldDidBeginEditing(sender: AnyObject) {
        self.fadeNewImage(self.passwordBG, newImage: UIImage(named: "text_field_grey")!)
    }
    
    func fadeNewImage(imageView: UIImageView, newImage: UIImage){
        func fadeInImage(image: UIImageView){
            UIImageView.animateWithDuration(0.5) {
                image.alpha = 1
            }
        }
        
        func fadeOutImage(image: UIImageView){
            UIImageView.animateWithDuration(0.5) {
                image.alpha = 0
            }
        }
        
        fadeOutImage(imageView)
        imageView.image = newImage
        fadeInImage(imageView)
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
                let object = PFUser()
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
                
                object.signUpInBackgroundWithBlock({ (success, error) in
                    if (error == nil)
                    {
                        print("user signed up")
                    }
                })

            }
            self.performSegueWithIdentifier("loginSuccessSegue", sender: self)
            
        }
    }
    
    @IBAction func loginAction(sender: UIButton) {
        let username = self.usernameField.text!
        let password = self.passwordField.text!
        
        if (!username.isEmpty && !password.isEmpty)
        {
            print("hello")
            
            PFUser.logInWithUsernameInBackground(username, password: password, block: { (user, error) in
                if (error == nil)
                {
                    if (user != nil)
                    {
                        print("success")
                        self.performSegueWithIdentifier("loginSuccessSegue", sender: self)
                    }
                }
            })
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


