//
//  BusinessTableViewCell.swift
//  Yelpify
//
//  Created by Jonathan Lam on 2/17/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import Haneke
import Cosmos
import MGSwipeTableCell

enum BusinessCellMode {
    case Add
    case More
}

class BusinessTableViewCell: MGSwipeTableCell {
    
    @IBOutlet weak var BusinessRating: CosmosView!
  
    let cache = Shared.imageCache
    
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var businessTitleLabel: UILabel!
    
    @IBOutlet weak var categoryIcon: UIImageView!
    @IBOutlet weak var businessBackgroundImage: UIImageView!
    
    @IBOutlet weak var businessAddressLabel: UILabel!
    @IBOutlet weak var businessOpenLabel: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    
    let googlePlacesClient = GooglePlacesAPIClient()
        
    func configureCellWith(business: Business, mode: BusinessCellMode, completion:() -> Void){
        
        switch mode {
        case .Add:
            self.configureButton(UIImage(named: "checkMark")!)
        case .More:
            self.configureButton(UIImage(named: "more_icon")!)
        default:
            self.configureButton(UIImage(named: "more_icon")!)
        }
        
        // Set Name
        businessTitleLabel.text = business.businessName
        
        // Set Address
        businessAddressLabel.text = business.businessAddress
        
        // Set Rating
        //print("\(business.businessName): \(business.businessRating)")
        if business.businessRating != -1{
            self.BusinessRating.hidden = false
            if let ratingValue2 = business.businessRating{
                self.BusinessRating.rating = ratingValue2
            }
        }else{
            self.BusinessRating.hidden = true
        }
        
        // Set Status
        if business.businessStatus != nil{
            if business.businessStatus == true{
                businessOpenLabel.text = "Open Now"
            }else{
                businessOpenLabel.text = "Closed"
            }
        }else{
            businessOpenLabel.text = ""
        }
        
        // Set Background Image
        self.businessBackgroundImage.image = UIImage(named:"default_restaurant")
        
        if let photoReference = business.businessPhotoReference{
            googlePlacesClient.getImageFromPhotoReference(photoReference) { (key) -> Void in
                
                self.cache.fetch(key: key).onSuccess { image in
                    self.businessBackgroundImage.hnk_setImage(image, key: photoReference)
                    self.businessBackgroundImage.setNeedsDisplay()
                    self.businessBackgroundImage.setNeedsLayout()
                    
                    completion()
                    
                }
            }

        }
    }
    
    func configureButton(image: UIImage){
        //let tintedImage = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        if actionButton != nil{
            //self.actionButton.setImage(tintedImage, forState: .Normal)
            self.actionButton.tintColor = appDefaults.color_darker
        }
    }
    
    @IBAction func actionButtonPressed(sender: AnyObject) {
        self.actionButton.tintColor = UIColor.greenColor()
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
