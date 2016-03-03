//
//  BusinessTableViewCell.swift
//  Yelpify
//
//  Created by Jonathan Lam on 2/17/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit

class BusinessTableViewCell: UITableViewCell {
    
    @IBOutlet weak var addToPlaylist: UIButton!
    @IBOutlet weak var businessTitleLabel: UILabel!
    @IBOutlet weak var businessBackgroundImage: UIImageView!
    
    let googlePlacesClient = GooglePlacesAPIClient()
    
    func downloadPhotoFromReference(photoRef: String, completion: (photo: UIImage, error: NSError?) -> Void){
        
        googlePlacesClient.getImageFromPhotoReference(photoRef) { (photo, error) -> Void in
            completion(photo: photo, error: error)
        }
    }
    
    func configureCellWith(business: Business){
        businessTitleLabel.text = business.businessName
        
        let photoReference = business.businessPhotoReference
        
        downloadPhotoFromReference(photoReference) { (photo, error) -> Void in
            if error != nil{
                self.businessBackgroundImage.image = UIImage(named: "restaurantImage - InNOut")
            }else{
                self.businessBackgroundImage.image = photo
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
