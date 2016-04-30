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

class BusinessTableViewCell: UITableViewCell {
    
    @IBOutlet weak var BusinessRating: CosmosView!
  
    let cache = Shared.imageCache
    
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var businessTitleLabel: UILabel!
    
    @IBOutlet weak var categoryIcon: UIImageView!
    @IBOutlet weak var businessBackgroundImage: UIImageView!
    
    @IBOutlet weak var businessAddressLabel: UILabel!
    @IBOutlet weak var businessOpenLabel: UILabel!
    
    //let yelpBusinessClient = YelpAPIClient()
    let googlePlacesClient = GooglePlacesAPIClient()
        
    func configureCellWith(business: Business, completion:() -> Void){
        businessTitleLabel.text = business.businessName
        businessAddressLabel.text = business.businessAddress
        //self.backgroundColor = UIColor(netHex:0x000000)
        //setCellColor()
        print(business.businessRating)
        if business.businessRating != -1{
            if let ratingValue2 = business.businessRating{
                self.BusinessRating.rating = ratingValue2
            }

        }else{
            self.BusinessRating.rating = 0
        }
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
        
//        // If Business Object contains photo reference
//        if photoReference != ""{
//            
//            googlePlacesClient.getImageFromPhotoReference(photoReference) { (key) -> Void in
//                
//                self.cache.fetch(key: key).onSuccess { image in
//                    self.businessBackgroundImage.hnk_setImage(image, key: photoReference)
//                    self.businessBackgroundImage.setNeedsDisplay()
//                    self.businessBackgroundImage.setNeedsLayout()
//                    
//                    completion()
//                    
////                    self.applyBlurEffect(image, completion: { (blurredImage) -> Void in
////                        self.businessBackgroundImage.hnk_setImage(blurredImage, key: photoReference)
////                        self.businessBackgroundImage.setNeedsLayout()
////                    })
//        
//                }
//            }
//        }
    }
    
    func applyBlurEffect(image: UIImage, completion: (blurredImage: UIImage) -> Void){
        let imageToBlur = CIImage(image: image)

        let blurfilter = CIFilter(name: "CIGaussianBlur")!
        blurfilter.setValue(1, forKey: kCIInputRadiusKey)
        blurfilter.setValue(imageToBlur, forKey: "inputImage")
        let resultImage = blurfilter.valueForKey("outputImage") as! CIImage
        
        let croppedImage:CIImage = resultImage.imageByCroppingToRect(CGRectMake(0, 0,imageToBlur!.extent.size.width, imageToBlur!.extent.size.height))
        let finalImage = UIImage(CIImage: croppedImage)

        completion(blurredImage: finalImage)
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
