//
//  ListCollectionViewCell.swift
//  Yelpify
//
//  Created by Ryan Yue on 4/10/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import Haneke

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
    
    func configureCell(imageref: String)
    {
        
        gpAPIClient.getImageFromPhotoReference(imageref) { (key) -> Void in
            
            self.cache.fetch(key: key).onSuccess { image in
                self.playlistImage.hnk_setImage(image, key: imageref)
                self.playlistImage.setNeedsDisplay()
                self.playlistImage.setNeedsLayout()
            }
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
