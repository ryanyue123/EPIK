//
//  SearchPeopleTableViewController.swift
//  Yelpify
//
//  Created by Ryan Yue on 5/6/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import Parse
import XLPagerTabStrip

class SearchPeopleTableViewController: UITableViewController, UITextFieldDelegate, IndicatorInfoProvider {
    
    @IBOutlet weak var searchField: UITextField!
    var itemInfo: IndicatorInfo = "People"
    var searchTextField: UITextField!
    var user_list = [PFObject]()
    var collaborative = false
    var collaboration_list = [PFObject]()
    var playlist: PFObject!
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchFor("")
        self.tableView.allowsSelection = true
        ConfigureFunctions.configureNavigationBar(self.navigationController!, outterView: self.view)
        
    }
    override func viewDidAppear(animated: Bool) {
        ConfigureFunctions.resetNavigationBar(self.navigationController!)
        if (searchTextField == nil) {
            searchTextField = searchField
            collaborative = true
        }
        searchTextField.delegate = self
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let query = PFUser.query()!
        query.whereKey("search_name", containsString: self.searchTextField.text!.uppercaseString)
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if (error == nil)
            {
                dispatch_async(dispatch_get_main_queue(), {
                    self.user_list = objects!
                    textField.resignFirstResponder()
                    self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
                })
            }
        }
        return true
    }
    
    func searchFor(search: String){
        let query = PFUser.query()!
        query.whereKey("search_name", containsString: search)
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if (error == nil)
            {
                dispatch_async(dispatch_get_main_queue(), {
                    self.user_list = objects!
                    self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
                })
            }
        }
    }

    
    @IBAction func saveToParse(sender: UIBarButtonItem) {
        playlist["Collaborators"] = self.collaboration_list
        playlist.saveInBackgroundWithBlock { (success, error) in
            if (error == nil) {
                print("Saved")
            }
        }
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.user_list.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchPeople", forIndexPath: indexPath) as! SearchPeopleCell
        
        let user = self.user_list[indexPath.row]
        let first_name = (user["first_name"] as! String).capitalizedString
        let last_name = (user["last_name"] as! String).capitalizedString
        let fullName = first_name + " " + last_name
        let handle = "@" + (user["username"] as! String)
        
        //let profPic = user["profile_pic"] // CHANGE
        
        cell.configureCell(fullName, handle: handle)
//        
//        cell.nameLabel.text = first_name + " " + last_name
//        cell.handleLabel.text = "@" + (user["username"] as! String)

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (collaborative) {
            self.collaboration_list.append(self.user_list[indexPath.row])
        }
        else {
            let controller = storyboard!.instantiateViewControllerWithIdentifier("profileVC") as! ProfileCollectionViewController
            controller.user = self.user_list[indexPath.row] as! PFUser
            self.navigationController!.pushViewController(controller, animated: true)
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
}
