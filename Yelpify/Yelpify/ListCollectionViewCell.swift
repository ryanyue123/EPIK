//
//  ListCollectionViewCell.swift
//  Yelpify
//
//  Created by Ryan Yue on 4/10/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import Haneke
import Parse

class ListCollectionViewCell: UICollectionViewCell {
    
    let cache = Shared.imageCache
    
    @IBOutlet weak var listIcon: UIImageView!
    @IBOutlet weak var playlistImage: UIImageView!
    @IBOutlet weak var listName: UILabel!
    @IBOutlet weak var creatorName: UILabel!
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var avgPrice: UILabel!
    @IBOutlet weak var numOfPlaces: UILabel!
    
    var gpAPIClient = GooglePlacesAPIClient()
    
    func configureCellLayout(){
        
        //addShadowToCell()
        
        // Round the banner's corners
        var maskPath: UIBezierPath = UIBezierPath(roundedRect: self.layer.bounds, byRoundingCorners: ([.TopLeft, .TopRight, .BottomLeft, .BottomRight]), cornerRadii: CGSizeMake(5, 5))
        var maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = self.layer.bounds
        maskLayer.path = maskPath.CGPath
        self.layer.mask = maskLayer
        
        // Round cell corners
        self.layer.cornerRadius = 3
        // Add shadow
        self.layer.masksToBounds = false
        
    }
    
    
    func configureCell(cellobject: PFObject){
        self.listName.text = cellobject["playlistName"] as? String
        let createdByUser = cellobject["createdBy"] as! PFUser
        createdByUser.fetchIfNeededInBackgroundWithBlock { (object, error) in
            if (error == nil)
            {
                dispatch_async(dispatch_get_main_queue(), {
                    self.creatorName.text = "BY " + (object!["username"]?.uppercaseString)!
                })
            }
        }
        let followCount = cellobject["followerCount"]
        if (followCount == nil) {
            self.followerCount.text = "0"
        }
        else {
            self.followerCount.text = String(followCount)
        }
        
        if let numPlaces = cellobject["num_places"] as? Int{
            self.numOfPlaces.text = String(numPlaces)
        }
        if let icon = cellobject["custom_bg"] as? PFFile{
            icon.getDataInBackgroundWithBlock({ (data, error) in
                if error == nil{
                    let image = UIImage(data: data!)
                    self.playlistImage.image = image
                }
            })
        }
        else {
            self.playlistImage.image = UIImage(named: "default_list_bg")
        }
        if let avgPrice = cellobject["average_price"] as? Int{
            var avg_price = ""
            for _ in 0..<(avgPrice) {
                avg_price += "$"
            }
            if avg_price != ""{
                self.avgPrice.text = avg_price
            }else{
                let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "-$-")
                attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
                self.avgPrice.attributedText = attributeString
            }
        }else{
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "-$-")
            attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
            self.avgPrice.attributedText = attributeString
        }
        
    }

    func addShadowToCell(){
        //self.backgroundColor = UIColor.whiteColor()
        self.layer.masksToBounds = false
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 30.0
        self.layer.shadowOffset = CGSizeZero
        self.layer.shadowColor = UIColor.blackColor().CGColor
        //self.layer.shouldRasterize = true
        //self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).CGPath
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.autoresizingMask.insert(.FlexibleHeight)
        self.contentView.autoresizingMask.insert(.FlexibleWidth)
    }
    
}
