//
//  PlaylistCreationViewController.swift
//  Yelpify
//
//  Created by Jonathan Lam on 3/9/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit

class SinglePlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    @IBOutlet weak var statusBarView: UIView!

    @IBOutlet weak var playlistInfoView: UIView!
    
    
    @IBOutlet weak var playlistTableView: UITableView!
    
    @IBOutlet weak var playlistInfoBG: UIImageView!
    @IBOutlet weak var playlistInfoIcon: UIImageView!
    @IBOutlet weak var playlistInfoName: UILabel!
    @IBOutlet weak var playlistInfoUser: UIButton!
    
    @IBOutlet weak var addPlaceButton: UIButton!
    var businessObjects: [Business] = []
    var playlistarray = [Business]()
    
    // The apps default color
    let defaultAppColor = UIColor(netHex: 0xFFFFFF)
    
    @IBAction func addPlaceButtonAction(sender: AnyObject) {
        
    }
    
    
    @IBAction func unwindToSinglePlaylist(segue: UIStoryboardSegue)
    {
        if(segue.identifier != nil)
        {
            if(segue.identifier == "unwindToPlaylist")
            {
                let sourceVC = segue.sourceViewController as! SearchBusinessViewController
                playlistarray = sourceVC.playlistArray
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businessObjects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("businessCell", forIndexPath: indexPath) as! BusinessTableViewCell
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    let dataHandler = APIDataHandler()
    var googleParameters = ["key": "AIzaSyDkxzICx5QqztP8ARvq9z0DxNOF_1Em8Qc", "location": "33.64496794563093,-117.83725295740864", "rankby":"distance", "keyword": ""]
    
    func performInitialSearch(){
        dataHandler.performAPISearch(googleParameters) { (businessObjectArray) -> Void in
            self.businessObjects = businessObjectArray
            self.playlistTableView.reloadData()
        }
    }
    
//    var navigationBarOriginalOffset : CGFloat?
//    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationBarOriginalOffset = playlistInfoView.frame.origin.y
//    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        fadePlaylistBG()
        updateHeaderView()
        handleNavigationBarOnScroll()
    }
    
    private let playlistTableHeaderHeight: CGFloat = 300.0
    var headerView: UIView!
    
    func fadePlaylistBG(){
        self.playlistInfoBG.alpha = (-playlistTableView.contentOffset.y / playlistTableHeaderHeight) * 0.5
    }
    
    func handleNavigationBarOnScroll(){
        
        let showWhenScrollDownAlpha = 1 - (-playlistTableView.contentOffset.y / playlistTableHeaderHeight)
        //let showWhenScrollUpAlpha = (-playlistTableView.contentOffset.y / playlistTableHeaderHeight)
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(showWhenScrollDownAlpha) ]
        self.navigationItem.title = "A Day in the City"
        //self.navigationController?.navigationBar.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(showWhenScrollDownAlpha)
        
        // Handle Status Bar
        self.statusBarView.alpha = showWhenScrollDownAlpha
        
        // Handle Nav Shadow View
        self.view.viewWithTag(100)!.backgroundColor = UIColor.darkGrayColor().colorWithAlphaComponent(showWhenScrollDownAlpha)
    }

    func updateHeaderView(){
        var headerRect = CGRect(x: 0, y: -playlistTableHeaderHeight, width: playlistTableView.frame.size.width, height: playlistTableHeaderHeight)
        
        if playlistTableView.contentOffset.y < -playlistTableHeaderHeight{
            headerRect.origin.y = playlistTableView.contentOffset.y
            headerRect.size.height = -playlistTableView.contentOffset.y
        }else if playlistTableView.contentOffset.y > -playlistTableHeaderHeight{
            self.navigationItem.title = "A Day in the City"
            self.navigationItem.titleView?.tintColor = UIColor.whiteColor()
//            headerRect.origin.y = playlistTableView.contentOffset.y
//            headerRect.size.height = -playlistTableView.contentOffset.y//playlistTableHeaderHeight//playlistTableView.contentOffset.y
        }
        headerView.frame = headerRect
    }
    
    func addShadowToBar() {
        let shadowView = UIView(frame: self.navigationController!.navigationBar.frame)
        //shadowView.backgroundColor = UIColor.darkGrayColor()
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowOpacity = 0.7 // your opacity
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 3) // your offset
        shadowView.layer.shadowRadius =  10 //your radius
        self.view.addSubview(shadowView)
        self.view.bringSubviewToFront(statusBarView)
        
        shadowView.tag = 100
    }

    
    func configurePlaylistInfoView(){
        headerView = playlistInfoView//playlistTableView.tableHeaderView
        
        playlistTableView.tableHeaderView = nil
        playlistTableView.addSubview(headerView)
        playlistTableView.contentInset = UIEdgeInsets(top: playlistTableHeaderHeight, left: 0, bottom: 0, right: 0)
        playlistTableView.contentOffset = CGPoint(x: 0, y: -playlistTableHeaderHeight)
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
        
        // Change the back button item to display no text
//        let backItem = UIBarButtonItem()
//        backItem.title = ""
//        navigationController?.navigationItem.backBarButtonItem = backItem
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configurePlaylistInfoView()
        performInitialSearch()
        
        //let tableViewPanGesture = UIPanGestureRecognizer(target: self, action: "panTableView:")
        //self.playlistTableView.addGestureRecognizer(tableViewPanGesture)

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
