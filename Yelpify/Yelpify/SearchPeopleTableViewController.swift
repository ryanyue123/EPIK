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

enum PeopleMode{
    case View
    case Collaborate
}

class SearchPeopleTableViewController: UITableViewController, UITextFieldDelegate, IndicatorInfoProvider {
    
    @IBOutlet weak var searchField: UITextField!
    var itemInfo: IndicatorInfo = "People"
    var searchTextField: UITextField!
    var user_list = [PFObject]()
    var collaborative = false
    var collaboration_list = [PFObject]()
    var playlist: PFObject!
    var mode: PeopleMode! = .View
    
    func addPersonToCollab(button: UIButton) {
        
        if button.tintColor == appDefaults.color_darker{
            button.tintColor = UIColor.greenColor()
            let index = button.tag
            self.collaboration_list.append(self.user_list[index])
            
            print("added", user_list[index])
        }else{
            button.tintColor = appDefaults.color_darker
            let index = button.tag
            let itemToRemove = user_list[index]
            let indexToRemove = collaboration_list.indexOf(itemToRemove)
            self.collaboration_list.removeAtIndex(indexToRemove!)
            
            print("removed", user_list[index])
        }
    }
    
    var locationUpdated = false
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.navigationController?.navigationBar.backgroundColor != appDefaults.color{
            // Configure Functions
           self.configureTopBar()
        }
        
        let rightButton = UIBarButtonItem(image: UIImage(named: "location_icon"), style: .Plain, target: self, action: "pressedLocation:")
        
        navigationItem.rightBarButtonItem = rightButton

        self.searchFor("")
    }
    
    override func viewDidAppear(animated: Bool) {
        self.configureTopBar()
        
        if let _ = self.parentViewController as? SearchPagerTabStrip{
            collaborative = false
            tableView.allowsSelection = true
        }else{
            tableView.allowsSelection = false
        }
        
//        if (searchTextField != nil) {
//            searchTextField.placeholder = "Search for People"
//            searchTextField = searchField
//            collaborative = true
//        }
        searchField.placeholder = "Search for People"
        searchField.delegate = self
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
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain , target: self, action: "pressedCancel:")
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let rightButton = UIBarButtonItem(image: UIImage(named: "location_icon"), style: .Plain, target: self, action: "pressedLocation:")
        
        navigationItem.rightBarButtonItem = rightButton
        
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
        self.dismissViewControllerAnimated(true, completion: nil)
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
        
        if collaborative == false{
            cell.configureCell(fullName, handle: handle)
        }else{
            cell.addPersonButton.tag = indexPath.row
            cell.addPersonButton.addTarget(self, action: "addPersonToCollab:", forControlEvents: .TouchUpInside)
            cell.configureCell(fullName, handle: handle, collab: true)
        }
//
//        cell.nameLabel.text = first_name + " " + last_name
//        cell.handleLabel.text = "@" + (user["username"] as! String)

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("profileVC") as! ProfileCollectionViewController
        controller.user = self.user_list[indexPath.row] as! PFUser
        self.navigationController!.pushViewController(controller, animated: true)
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
