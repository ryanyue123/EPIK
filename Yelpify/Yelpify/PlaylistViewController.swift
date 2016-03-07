//
//  PlaylistViewController.swift
//  Yelpify
//
//  Created by Ryan Yue on 2/14/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import Parse
import ParseUI

struct playlist
{
    static var playlistname: String!
    static var playlistID: String!
}
class PlaylistViewController: UICollectionViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, CLLocationManagerDelegate, UITextFieldDelegate {

    var locationManager = CLLocationManager()
    let client = YelpAPIClient()
    var parameters = ["ll": "", "category_filter": "pizza", "radius_filter": "3000", "sort": "0"]
    var playlists = []
    var userlatitude: Double!
    var userlongitude: Double!
    var inputTextField: UITextField!
    
    @IBAction func showPlaylistAlert(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Create new playlist", message: "Enter name of playlist.", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Playlist Name"
            textField.secureTextEntry = false
            self.inputTextField = textField
        })
        let deleteAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive, handler: {(alert :UIAlertAction!) in
            print("Delete button tapped")
        })
        alertController.addAction(deleteAction)
        let okAction = UIAlertAction(title: "Enter", style: UIAlertActionStyle.Default, handler: {(alert :UIAlertAction!) in
            let query = PFQuery(className: "Playlists")
            query.whereKey("createdbyuser", equalTo: (PFUser.currentUser()?.username!)!)
            query.whereKey("playlistName", equalTo: self.inputTextField.text!)
            query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
                if ((error) == nil)
                {
                    dispatch_async(dispatch_get_main_queue(), {
                        if (objects!.count == 0)
                        {
                            let object = PFObject(className: "Playlists")
                            object["playlistName"] = self.inputTextField.text!
                            object["createdbyuser"] = PFUser.currentUser()?.username!
                            object.saveInBackgroundWithBlock {(success, error) -> Void in
                                if (error == nil)
                                {
                                    playlist.playlistname = self.inputTextField.text!
                                    self.performSegueWithIdentifier("showList", sender: self)
                                }
                                else
                                {
                                    print(error?.userInfo)
                                }
                            }
                        }
                        else
                        {
                            print("You have already created this playlist")
                        }
                    })
                }
                else
                {
                    print(error?.description)
                }
            }
        })
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
        
    }

    func fetchAllObjectsFromDataStore()
    {
        let query:PFQuery = PFQuery(className: "Playlists")
        query.fromLocalDatastore()
        query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: userlatitude, longitude: userlongitude), withinMiles: 50.0)
        query.orderByAscending("location")
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
            if ((error) == nil)
            {
                dispatch_async(dispatch_get_main_queue(), {
                    self.playlists = objects! as NSArray
                    //print(self.playlists)
                })
            }
            else
            {
                print(error?.userInfo)
            }
        }
        
    }
    
    func fetchAllObjects()
    {
        PFObject.unpinAllObjectsInBackgroundWithBlock(nil)
        let query:PFQuery = PFQuery(className:"Playlists")
        print(userlatitude)
        print(userlongitude)
        query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: userlatitude, longitude: userlongitude), withinMiles: 50.0)
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
            if ((error) == nil)
            {
                PFObject.pinAllInBackground(objects, block: { (success, error) -> Void in
                    
                    if (error == nil)
                    {
                        self.fetchAllObjectsFromDataStore()
                    }
                })

            }
            else
            {
                print(error?.userInfo)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        print(userLocation.coordinate)
        userlatitude = latitude
        userlongitude = longitude
        fetchAllObjects()
        parameters["ll"] = String(latitude) + "," + String(longitude)
    }
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.description)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse
        {
            //print("Authorized")
        }
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
        locationManager.requestLocation()
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
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 0
    }
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PlaylistCell", forIndexPath: indexPath)
        return cell
    }

}
