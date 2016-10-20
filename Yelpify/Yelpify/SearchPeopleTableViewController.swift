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
    case view
    case collaborate
}

class SearchPeopleTableViewController: UITableViewController, UITextFieldDelegate, IndicatorInfoProvider {
    
    @IBOutlet weak var searchField: UITextField!
    var itemInfo: IndicatorInfo = "People"
    var searchTextField: UITextField!
    var user_list = [PFObject]()
    var collaborative = false
    var collaboration_list = [PFObject]()
    var playlist: PFObject!
    var mode: PeopleMode! = .view
    
    func addPersonToCollab(_ button: UIButton) {
        
        if button.tintColor == appDefaults.color_darker{
            button.tintColor = UIColor.green
            let index = button.tag
            self.collaboration_list.append(self.user_list[index])
            
            print("added", user_list[index])
        }else{
            button.tintColor = appDefaults.color_darker
            let index = button.tag
            let itemToRemove = user_list[index]
            let indexToRemove = collaboration_list.index(of: itemToRemove)
            self.collaboration_list.remove(at: indexToRemove!)
            
            print("removed", user_list[index])
        }
    }
    
    var locationUpdated = false
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.navigationController?.navigationBar.backgroundColor != appDefaults.color{
            // Configure Functions
           self.navigationController?.configureTopBar()
        }
        
        let rightButton = UIBarButtonItem(image: UIImage(named: "location_icon"), style: .plain, target: self, action: "pressedLocation:")
        
        navigationItem.rightBarButtonItem = rightButton

        self.searchFor("")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.configureTopBar()
        
        if let _ = self.parent as? SearchPagerTabStrip{
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let query = PFUser.query()!
        query.whereKey("search_name", contains: self.searchTextField.text!.uppercased())
        query.findObjectsInBackground { (objects, error) in
            if (error == nil)
            {
                DispatchQueue.main.async(execute: {
                    self.user_list = objects!
                    textField.resignFirstResponder()
                    self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
                })
            }
        }
        return true
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain , target: self, action: "pressedCancel:")
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let rightButton = UIBarButtonItem(image: UIImage(named: "location_icon"), style: .plain, target: self, action: "pressedLocation:")
        
        navigationItem.rightBarButtonItem = rightButton
        
    }
    
    func searchFor(_ search: String){
        let query = PFUser.query()!
        query.whereKey("search_name", contains: search)
        query.findObjectsInBackground { (objects, error) in
            if (error == nil)
            {
                DispatchQueue.main.async(execute: {
                    self.user_list = objects!
                    self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
                })
            }
        }
    }

    
    @IBAction func saveToParse(_ sender: UIBarButtonItem) {
        playlist["Collaborators"] = self.collaboration_list
        playlist.saveInBackground { (success, error) in
            if (error == nil) {
                print("Saved")
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.user_list.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchPeople", for: indexPath) as! SearchPeopleCell
        
        let user = self.user_list[(indexPath as NSIndexPath).row]
        let first_name = (user["first_name"] as! String).capitalized
        let last_name = (user["last_name"] as! String).capitalized
        let fullName = first_name + " " + last_name
        let handle = "@" + (user["username"] as! String)
        
        //let profPic = user["profile_pic"] // CHANGE
        
        if collaborative == false{
            cell.configureCell(fullName, handle: handle)
        }else{
            cell.addPersonButton.tag = (indexPath as NSIndexPath).row
            cell.addPersonButton.addTarget(self, action: #selector(SearchPeopleTableViewController.addPersonToCollab(_:)), for: .touchUpInside)
            cell.configureCell(fullName, handle: handle, collab: true)
        }
//
//        cell.nameLabel.text = first_name + " " + last_name
//        cell.handleLabel.text = "@" + (user["username"] as! String)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = storyboard!.instantiateViewController(withIdentifier: "profileVC") as! ProfileCollectionViewController
        controller.user = self.user_list[(indexPath as NSIndexPath).row] as! PFUser
        self.navigationController!.pushViewController(controller, animated: true)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}
