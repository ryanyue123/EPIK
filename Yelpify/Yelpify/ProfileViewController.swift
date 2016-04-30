//
//  ProfileViewController.swift
//  Yelpify
//
//  Created by Jonathan Lam on 4/15/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import Parse
class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var profileBG: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    // MARK: - View Setup Methods
    
    var username: String!
    var userobject: PFObject!
    
    func fetchUserData()
    {
        let query = PFUser.query()!
        query.whereKey("username", equalTo: username)
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
            if ((error) == nil)
            {
                dispatch_async(dispatch_get_main_queue(), {
                    self.userobject = objects![0]
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
        
//        if (userobject == nil)
//        {
//            fetchUserData()
//        }
        
        configureNavigationBar()
        setupProfilePicture()
    }
    
    override func viewDidAppear(animated: Bool) {
        configureHeaderView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateHeaderView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderView()
    }
    
    // MARK: - Scroll View
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.fadeBG()
        self.updateHeaderView()
        self.handleNavigationBarOnScroll()
    }
    
    func fadeBG(){
        self.profileBG.alpha = (-tableView.contentOffset.y / headerHeight) * 0.5
    }
    
    func handleNavigationBarOnScroll(){
        let showWhenScrollDownAlpha = 1 - (-tableView.contentOffset.y / headerHeight)
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(showWhenScrollDownAlpha) ]
        self.navigationItem.title = "details"
        
        // Handle Status Bar
        //self.statusBarView.alpha = showWhenScrollDownAlpha
        
        // Handle Nav Shadow View
        self.view.viewWithTag(102)!.backgroundColor = appDefaults.color.colorWithAlphaComponent(showWhenScrollDownAlpha)
    }

    
    // MARK: - Configure Methods
    
    private let headerHeight: CGFloat = 300.0
    
    func setupProfilePicture(){
        
        self.roundingUIView(self.profileImageView, cornerRadiusParam: 45)
        self.profileImageView.layer.borderWidth = 3.0
        self.profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
        
//        self.profileImageView.layer.borderWidth = 1.0
//        self.profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
//        self.profileImageView.layer.cornerRadius = 13
//        //self.profileImageView.layer.cornerRadius = profileImageView.frame.size.height/2
//        self.profileImageView.clipsToBounds = true
//        profileImageView.layer.masksToBounds = false
    }
    
    private func roundingUIView(let aView: UIView!, let cornerRadiusParam: CGFloat!) {
        aView.clipsToBounds = true
        aView.layer.cornerRadius = cornerRadiusParam
    }
    
    func configureNavigationBar(){
        addShadowToBar()
        for parent in self.navigationController!.navigationBar.subviews {
            for childView in parent.subviews {
                if(childView is UIImageView) {
                    childView.removeFromSuperview()
                }
            }
        }
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
    }
    
    func configureHeaderView(){
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        tableView.contentInset = UIEdgeInsets(top: headerHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -headerHeight)
    }
    
    func updateHeaderView(){
        var headerRect = CGRect(x: 0, y: -headerHeight, width: self.tableView.frame.size.width, height: headerHeight)
        
        if self.tableView.contentOffset.y < -headerHeight{
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
            print("high")
        }else if self.tableView.contentOffset.y > headerHeight{
            self.navigationItem.title = "hi"
            self.navigationItem.titleView?.tintColor = UIColor.whiteColor()
            print("low")
        }
        
        headerView.frame = headerRect
    }
    
    func addShadowToBar() {
        let shadowView = UIView(frame: self.navigationController!.navigationBar.frame)
        //shadowView.backgroundColor = appDefaults.color
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowOpacity = 0.7 // your opacity
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 3) // your offset
        shadowView.layer.shadowRadius =  10 //your radius
        self.view.addSubview(shadowView)
        self.view.bringSubviewToFront(shadowView)
        
        shadowView.tag = 102
    }

    
    // MARK: - Table View Functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("playlistCell", forIndexPath: indexPath)
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    


}
