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
import Kingfisher

class BusinessTableViewCell: MGSwipeTableCell {
    
    @IBOutlet weak var BusinessRating: CosmosView!
  
    let cache = Shared.imageCache
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var businessTitleLabel: UILabel!
    
    @IBOutlet weak var categoryIcon: UIImageView!
    @IBOutlet weak var businessBackgroundImage: UIImageView!
    
    @IBOutlet weak var businessAddressLabel: UILabel!
    @IBOutlet weak var businessOpenLabel: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    
    let googlePlacesClient = GooglePlacesAPIClient()
        
    @IBOutlet weak var actionButtonView: UIView!
    
    override func draw(_ rect: CGRect) {
        mainView.addShadow(4, opacity: 0.2, offset: CGSize(width: 0, height: 4), path: true)
    }
    
    func configure(with business: Business, mode: BusinessCellMode, completion:() -> Void){
        
        switch mode {
        case .add:
            self.configureButton(UIImage(named: "checkMark")!)
            let tapRec = UITapGestureRecognizer(target: self, action: #selector(BusinessTableViewCell.actionButtonPressed(_:)))
            actionButtonView.addGestureRecognizer(tapRec)

        case .more:
            self.configureButton(UIImage(named: "more_icon")!)
            self.moreButton.isHidden = true
        default:
            self.configureButton(UIImage(named: "more_icon")!)
        }
        
        //Set Icon
        let businessList = ["restaurant","food","amusement","bakery","bar","beauty_salon","bowling_alley","cafe","car_rental","car_repair","clothing_store","department_store","grocery_or_supermarket","gym","hospital","liquor_store","lodging","meal_takeaway","movie_theater","night_club","police","shopping_mall"]
        
        if business.businessTypes.count != 0 && businessList.contains(String(describing: business.businessTypes[0])){
            categoryIcon.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
            let origImage = UIImage(named: String(describing: business.businessTypes[0]) + "_Icon")!
            let tintedImage = origImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            categoryIcon.image = tintedImage
            categoryIcon.tintColor = appDefaults.color_darker
            
        }else{
            categoryIcon.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
            let origImage = UIImage(named: "default_Icon")!
            let tintedImage = origImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            categoryIcon.image = tintedImage
            categoryIcon.tintColor = appDefaults.color_darker
        }
        
        // Set Name
        businessTitleLabel.text = business.businessName
        
        // Set Address
        businessAddressLabel.text = business.businessAddress
        
        // Set Rating
        //print("\(business.businessName): \(business.businessRating)")
        if business.businessRating != -1{
            self.BusinessRating.isHidden = false
            if let ratingValue2 = business.businessRating{
                self.BusinessRating.rating = ratingValue2
            }
        }else{
            self.BusinessRating.isHidden = true
        }
        
        // Set Status
        if business.businessStatus != nil{
            if business.businessStatus == true{
                businessOpenLabel.text = "Open Now"
            }else{
                businessOpenLabel.text = "Closed"
            }
        }else{
            businessOpenLabel.text = "No Hours Availible"
        }
        
//        // Set Background Image
        self.businessBackgroundImage.backgroundColor = appDefaults.color
        self.businessBackgroundImage.image = nil
        
        func buildPlacePhotoURLString(_ photoReference: String) -> String{
            let photoParameters = [
                "key" : "AIzaSyDkxzICx5QqztP8ARvq9z0DxNOF_1Em8Qc",
                "photoreference" : photoReference,
                "maxheight" : "800"
            ]
            var result = "https://maps.googleapis.com/maps/api/place/photo?"
            for (key, value) in photoParameters{
                let addString = key + "=" + value + "&"
                result += addString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            }
            return result
        }
        
        if business.businessPhotoReference != ""{
            let PhotoURL = buildPlacePhotoURLString(business.businessPhotoReference)
            //let URLString = self.items[indexPath.row]
            let URL = Foundation.URL(string:PhotoURL)!
            //businessBackgroundImage.hnk_setImageFromURL(URL: URL as NSURL)
            //let url = URL(string: "https://domain.com/image.jpg")!
            businessBackgroundImage.kf.setImage(with: URL)
        }
        else{
            businessBackgroundImage.image =  UIImage(named: "default_business_bg")
            
        }
    }
    

    func configureButton(_ image: UIImage){
        //let tintedImage = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        if actionButton != nil{
            //self.actionButton.setImage(tintedImage, forState: .Normal)
            self.actionButton.tintColor = appDefaults.color_darker
        }
    }
    
    func changeImageViewColor(_ imageView: UIImageView, color: UIColor) {
        
    }
    
//    func addShadow(){
//        self.mainView.layer.shadowColor = UIColor.blackColor().CGColor
//        self.mainView.layer.shadowOpacity = 0.2
//        self.mainView.layer.shadowOffset = CGSize(width: 0, height: 4)
//        self.mainView.layer.shadowRadius = 4
//    }
//    
    
    @IBAction func actionButtonPressed(_ sender: AnyObject) {
        self.actionButton.tintColor = UIColor.green
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
