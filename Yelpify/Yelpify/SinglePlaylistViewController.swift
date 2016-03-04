//
//  SinglePlaylistViewController.swift
//  Yelpify
//
//  Created by Ryan Yue on 2/25/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import Parse

class SinglePlaylistViewController: UIViewController {

    var playlistName:String!

    func fetchAllObjectsFromDataStore()
    {
        let query:PFQuery = PFQuery(className: "Playlists")
        query.fromLocalDatastore()
        
        query.whereKey("name", equalTo: playlistName)
        query.whereKey("createdBy", equalTo: (PFUser.currentUser()?.username)!)
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
            if ((error) == nil)
            {
                
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
        let query:PFQuery = PFQuery(className: (PFUser.currentUser()?.username)!)
        query.fromLocalDatastore()
        
        query.whereKey("name", equalTo: playlistName)
        query.whereKey("createdBy", equalTo: (PFUser.currentUser()?.username)!)
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
            if ((error) == nil)
            {
                PFObject.pinAllInBackground(objects, block: { (success, error) -> Void in
                    print(objects)
                    
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
        
        
        // Do any additional setup after loading the view.
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
