//
//  SearchPlaylistViewController.swift
//  Yelpify
//
//  Created by Ryan Yue on 4/29/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import Parse
class SearchPlaylistViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    var playlist_query = [PFObject]()
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.playlist_query.count
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        searchForPlaylistWithName()
        self.textField.endEditing(true)
        return true
    }
    
    func searchForPlaylistWithName()
    {
        let query = PFQuery(className: "Playlists")
        query.whereKey("playlistName", containsString: self.textField.text!)
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
            if (error == nil)
            {
                dispatch_async(dispatch_get_main_queue(), {
                    self.playlist_query = objects!
                    self.tableView.reloadData()
                    print("dslkjflksd")
                })
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SearchPlaylistCell
        cell.label.text = playlist_query[indexPath.row]["playlistName"] as? String

        return cell
    }
}
