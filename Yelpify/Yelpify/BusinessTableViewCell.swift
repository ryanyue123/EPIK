//
//  BusinessTableViewCell.swift
//  Yelpify
//
//  Created by Jonathan Lam on 2/17/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import Haneke

struct colorSetter {
    static var currentSchemeNum = 1
    
    static var blueScheme = ["1": UIColor(netHex:0x000000), "2": UIColor(netHex:0x000000), "3": UIColor(netHex:0x000000), "4": UIColor(netHex:0x000000)]
    
    //static var blueScheme = ["1": UIColor(netHex:0x34a9db), "2": UIColor(netHex:0x2a7da1), "3": UIColor(netHex:0x166080), "4": UIColor(netHex:0x124358)]
}

class BusinessTableViewCell: UITableViewCell {
    
    let cache = Shared.imageCache
    
    @IBOutlet weak var addToPlaylist: UIButton!
    @IBOutlet weak var businessTitleLabel: UILabel!
    @IBOutlet weak var businessBackgroundImage: UIImageView!
    @IBOutlet weak var businessAddressLabel: UILabel!
    
    let googlePlacesClient = GooglePlacesAPIClient()
    
    func configureCellWith(business: Business){
        businessTitleLabel.text = business.businessName
        businessAddressLabel.text = business.businessAddress
        self.backgroundColor = UIColor(netHex:0x000000)
        //setCellColor()
        
        let photoReference = business.businessPhotoReference
        
        googlePlacesClient.getImageFromPhotoReference(photoReference) { (key) -> Void in
            
            self.cache.fetch(key: key).onSuccess { image in
                
                self.applyBlurEffect(image, completion: { (blurredImage) -> Void in
                    self.businessBackgroundImage.hnk_setImage(blurredImage, key: photoReference)
                })
                //self.businessBackgroundImage.hnk_setImage(image, key: photoReference)
    
            }
        }
    }
    
    func setCellColor(){
        self.backgroundColor = colorSetter.blueScheme[String(colorSetter.currentSchemeNum)]
        
        if colorSetter.currentSchemeNum != 4{
            colorSetter.currentSchemeNum++
        }else{
            colorSetter.currentSchemeNum = 1
        }
    }
    
    func applyBlurEffect(image: UIImage, completion: (blurredImage: UIImage) -> Void){
        let imageToBlur = CIImage(image: image)

        let blurfilter = CIFilter(name: "CIGaussianBlur")!
        blurfilter.setValue(2, forKey: kCIInputRadiusKey)
        blurfilter.setValue(imageToBlur, forKey: "inputImage")
        let resultImage = blurfilter.valueForKey("outputImage") as! CIImage
        
        let croppedImage:CIImage = resultImage.imageByCroppingToRect(CGRectMake(0, 0,imageToBlur!.extent.size.width, imageToBlur!.extent.size.height))
        let finalImage = UIImage(CIImage: croppedImage)

        completion(blurredImage: finalImage)
    }
    
    
    
//    func applyBlurEffect(image: UIImage, completion: (blurredImage: UIImage) -> Void){
//        let imageToBlur = CIImage(image: image)
//        
//        let blurfilter = CIFilter(name: "CIGaussianBlur")!
//        blurfilter.setValue(3, forKey: kCIInputRadiusKey)
//        blurfilter.setValue(imageToBlur, forKey: "inputImage")
//        var resultImage = blurfilter.valueForKey("outputImage") as! CIImage
//        var blurredImage = UIImage(CIImage: resultImage)
//        
//        let darkfilter = CIFilter(name: "CIColorControls")!
//        darkfilter.setValue(2, forKey: kCIInputBrightnessKey)
//        darkfilter.setValue(imageToBlur, forKey: "inputImage")
//        var resultDarkImage = darkfilter.valueForKey("outputImage") as! CIImage
//        var darkenedImage = UIImage(CIImage: resultDarkImage)
//        
//        var cropped:CIImage=resultDarkImage.imageByCroppingToRect(CGRectMake(0, 0,imageToBlur!.extent.size.width, imageToBlur!.extent.size.height))
//        let finalImage = UIImage(CIImage: cropped)
//        
//        completion(blurredImage: finalImage)
//    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
