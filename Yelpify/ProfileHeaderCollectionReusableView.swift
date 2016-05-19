//
//  ProfileHeaderCollectionReusableView.swift
//  Yelpify
//
//  Created by Jonathan Lam on 5/3/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import Parse
import BetterSegmentedControl

enum PictureToChange {
    case Profile
    case Cover
}

protocol ShouldSegueToImagePickerDelegate{
    func shouldSegue()
}

class ProfileHeaderCollectionReusableView: UICollectionReusableView, SendCustomImages {
    
    var user: PFUser!
    var listnum: Int!
    var delegate: ShouldSegueToImagePickerDelegate!
    
    @IBOutlet weak var segmentedIndicatorView: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    var pictureToChange: PictureToChange!
    
    @IBOutlet weak var coverPhoto: UIImageView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handleLabel : UILabel!
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var listCount: UILabel!
    
    @IBOutlet weak var followButton : UIButton!
    
    @IBOutlet weak var segmentedBarView: UIView!
    
    @IBOutlet weak var changeBGPicButton: UIButton!
    @IBOutlet weak var changeProfPicButton: UIButton!
    
    @IBAction func pressedFollowButton(sender: AnyObject) {
        
    }
    
    @IBAction func pressedChangeProfPicButton(sender: AnyObject) {
        self.pictureToChange = .Profile
        //delegate.shouldSegue()
    }
    
    @IBAction func pressedChangeBGPicButton(sender: AnyObject) {
        self.pictureToChange = .Cover
        //delegate.shouldSegue()
    }
    
    func configureSegmentedBar(){
        let control = BetterSegmentedControl(
            frame: CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: 40),
            titles: ["Lists", "Following"],
            index: 0,
            backgroundColor: appDefaults.color,
            titleColor: UIColor.whiteColor(),
            indicatorViewBackgroundColor: appDefaults.color,
            selectedTitleColor: .whiteColor())
        control.autoresizingMask = [.FlexibleWidth]
        control.panningDisabled = true
        control.titleFont = UIFont(name: "Montserrat", size: 12.0)!
        control.addTarget(self, action: nil, forControlEvents: .ValueChanged)
        control.alpha = 0
        self.segmentedBarView.addSubview(control)
        UIView.animateWithDuration(0.3) {
            control.alpha = 1
            self.segmentedBarView.bringSubviewToFront(self.segmentedIndicatorView)
        }
    }
    
    func sendImage(image: UIImage) {
        if self.pictureToChange == .Profile{
            self.profileImageView.image = image
        }else{
            self.coverPhoto.image = image
        }
    }
    
    // MARK: - Image Picker Functions
    var customProfilePic: UIImage!
    var customCoverPic: UIImage!
    
    func configureView(){
        let firstname = user["first_name"] as! String
        let lastname = user["last_name"] as! String
        nameLabel.text = firstname.uppercaseFirst + " " + lastname.uppercaseFirst
        listCount.text = String(listnum)
        
        
        // CHANGE
        profileImageView.alpha = 0
        Animations.roundSquareImageView(profileImageView, outerView: profileView, borderWidth: 3.0, borderColor: .whiteColor())
        Animations.fadeInImageView(profileImageView, imageToAdd: UIImage(named: "face")!, beginScale: 0.6)
    }
    
}
