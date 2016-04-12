//
//  ActionsViewController.swift
//  Yelpify
//
//  Created by Jonathan Lam on 4/11/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit

class ActionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeaderView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHeaderView()
        applyBackgroundBlurEffect()
        view.backgroundColor = UIColor.clearColor()
        view.opaque = false
    
    }
    
    func applyBackgroundBlurEffect() {
        // Blur Effect
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        
        // Vibrancy Effect
        let vibrancyEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyEffectView.frame = blurEffectView.bounds
        
        // Add to subview
        view.addSubview(blurEffectView)
        view.addSubview(vibrancyEffectView)
    }
    
    func configureHeaderView(){
        var headerRect = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: self.view.frame.size.height * 0.5)
        tableHeaderView.frame = headerRect

    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if tableView.contentOffset.y < -100{
            performSegueWithIdentifier("unwindToSinglePlaylist", sender: self)
        }
    }
    
    
    // MARK: - Table View Functions

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("actionCell", forIndexPath: indexPath)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

}
