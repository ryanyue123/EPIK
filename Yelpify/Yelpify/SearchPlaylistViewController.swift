//
//  SearchPlaylistViewController.swift
//  Yelpify
//
//  Created by Ryan Yue on 4/29/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import Parse
import XLPagerTabStrip

class SearchPlaylistViewController: UITableViewController, UITextFieldDelegate, IndicatorInfoProvider {
    
    var itemInfo: IndicatorInfo = "Lists"
    
    var textField: UITextField!
    
    init(style: UITableViewStyle, itemInfo: IndicatorInfo, textField: UITextField) {
        self.textField = textField
        self.itemInfo = itemInfo
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }

    //@IBOutlet weak var textField: UITextField!
    var playlist_query = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
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
