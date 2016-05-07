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
    
    var gpAPIClient = GooglePlacesAPIClient()
    
    func configureCellLayout(){
//        self.layer.cornerRadius = 4.0
//        self.layer.masksToBounds = true
        
        //self.customObject = customObject
        
        // Round the banner's corners
        var maskPath: UIBezierPath = UIBezierPath(roundedRect: self.layer.bounds, byRoundingCorners: ([.TopLeft, .TopRight, .BottomLeft, .BottomRight]), cornerRadii: CGSizeMake(20, 20))
        var maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = self.layer.bounds
        maskLayer.path = maskPath.CGPath
        self.layer.mask = maskLayer
        
        // Round cell corners
        self.layer.cornerRadius = 20
        // Add shadow
        self.layer.masksToBounds = false
        self.layer.shadowOpacity = 0.75
        self.layer.shadowRadius = 20.0
        self.layer.shouldRasterize = false
        self.layer.shadowPath = UIBezierPath(rect: CGRectMake(self.frame.size.width / 2 - (self.frame.size.width - 50) / 2, self.frame.size.height, self.frame.size.width - 50, 10)).CGPath
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.autoresizingMask.insert(.FlexibleHeight)
        self.contentView.autoresizingMask.insert(.FlexibleWidth)
    }
    
}
