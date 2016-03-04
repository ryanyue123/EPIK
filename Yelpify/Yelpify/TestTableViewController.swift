//
//  TestTableViewController.swift
//  Yelpify
//
//  Created by Jonathan Lam on 3/1/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit

class TestTableViewController: UITableViewController {
    
    let googleClient = GooglePlacesAPIClient()
    
    var businessShown: [Bool] = []
    var businessObjects: [Business] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0...10{
            self.businessShown.append(false)
        }
        
//        for business in businessObjects{
//            googleClient.getImageFromPhotoReference(business.businessPhotoReference, completion: { (photo, error) -> Void in
//                
//            })
//        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businessObjects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TestTableViewCell", forIndexPath: indexPath) as! TestTableViewCell
        cell.tag = indexPath.row
        
        let business = businessObjects[indexPath.row]
        
//        if businessShown[indexPath.row] == false{
//            self.getImageFromPhotoReference(business.businessPhotoReference) { (photo, error) -> Void in
//                if cell.tag == indexPath.row{
//                    cell.backgroundImage.image = photo
//                }
//            }
//        }
        cell.businessNameLabel.text = business.businessName
        
        businessShown[indexPath.row] = true
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
