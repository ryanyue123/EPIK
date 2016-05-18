//
//  ProfileHeaderCollectionReusableView.swift
//  Yelpify
//
//  Created by Jonathan Lam on 5/3/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import Parse
class ProfileHeaderCollectionReusableView: UICollectionReusableView {
    
    var user: PFUser!
    var listnum: Int!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handleLabel : UILabel!
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var listCount: UILabel!
    
    @IBOutlet weak var followButton : UIButton!
    
    @IBOutlet weak var segmentedBarView: UIView!
    
    
    @IBAction func pressedFollowButton(sender: AnyObject) {
    }
    
    
    func configureView(){
        let firstname = user["first_name"] as! String
        let lastname = user["last_name"] as! String
        nameLabel.text = firstname + " " + lastname
        listCount.text = String(listnum)
        setupProfilePicture()
    }
    
    
    private func setupProfilePicture(){
        self.roundingUIView(self.profileImageView, cornerRadiusParam: 50)
        self.roundingUIView(self.profileView, cornerRadiusParam: 50)
        self.profileImageView.layer.borderWidth = 4.0
        self.profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
    }

    private func roundingUIView(let aView: UIView!, let cornerRadiusParam: CGFloat!) {
        aView.clipsToBounds = true
        aView.layer.cornerRadius = cornerRadiusParam
    }

}
