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
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
    }
    
    func applyBackgroundBlurEffect() {
        // Blur Effect
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        
        // Vibrancy Effect
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyEffectView.frame = blurEffectView.bounds
        
        // Add to subview
        view.addSubview(blurEffectView)
        view.addSubview(vibrancyEffectView)
        
        blurEffectView.tag = 101
        vibrancyEffectView.tag = 102
    }
    
    func configureHeaderView(){
        let headerRect = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: self.view.frame.size.height * 0.5)
        tableHeaderView.frame = headerRect
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tableView.contentOffset.y < -100{
            performSegue(withIdentifier: "unwindToSinglePlaylist", sender: self)
        }
        
    }
    
    
    // MARK: - Table View Functions

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell", for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

}
