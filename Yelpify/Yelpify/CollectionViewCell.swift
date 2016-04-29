//
//  CollectionViewCell.swift
//  Yelpify
//
//  Created by Ryan Yue on 4/10/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import Haneke

class CollectionViewCell: UICollectionViewCell {
    
    let cache = Shared.imageCache
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var playlistImage: UIImageView!
    
    var gpAPIClient = GooglePlacesAPIClient()
    
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
    
}
