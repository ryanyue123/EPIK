//
//  BusinessDetailViewController.swift
//  Yelpify
//
//  Created by Ryan Yue on 2/23/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import Parse

class BusinessDetailViewController: UITableViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    var object: Business!
    var index: Int!
    var yelpClient = APIDataHandler()
    var yelpObj:YelpBusiness!

    @IBAction func showBusinessList(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = "Details"
        yelpClient.retrieveYelpBusinessFromBusinessObject(object) { (yelpBusinessObject) -> Void in
            self.yelpObj = yelpBusinessObject
        }
        nameLabel.text = yelpObj.businessName
        addressLabel.text = yelpObj.businessAddress
        //nameLabel.text = object.businessName
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addItemToPlaylist(sender: UIBarButtonItem) {
        performSegueWithIdentifier("unwindFromDetail", sender: self)
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
