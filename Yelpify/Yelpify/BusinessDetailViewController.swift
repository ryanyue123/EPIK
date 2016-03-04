//
//  BusinessDetailViewController.swift
//  Yelpify
//
//  Created by Ryan Yue on 2/23/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit

class BusinessDetailViewController: UITableViewController {

    var object: Business!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBAction func showBusinessList(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Details"
        nameLabel.text = object.businessName
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addItemToPlaylist(sender: UIBarButtonItem) {
        
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
