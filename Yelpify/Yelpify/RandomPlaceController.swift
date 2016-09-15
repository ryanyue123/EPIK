//
//  RandomPlaceController.swift
//  Yelpify
//
//  Created by Kay Lab on 4/5/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import Foundation
import UIKit

class RandomPlaceController: UIViewController{
    
    @IBOutlet weak var RestaurantName: UILabel!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var cardImageView: UIImageView!
    
    var businessArray: [Business]!
    var googleClient = GooglePlacesAPIClient()
    
    func getRandomPlace(_ playlist: [Business])->Business{
        let num = Int32(arc4random_uniform(UInt32(playlist.count)))
        let randomPlace = playlist[Int(num)]
        return randomPlace
    }
    
    func applyBackgroundBlurEffect() {
        // Blur Effect
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        
        // Vibrancy Effect
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyEffectView.frame = blurEffectView.bounds
        
        // Add to subview
        backgroundImage.addSubview(blurEffectView)
        backgroundImage.addSubview(vibrancyEffectView)
    }
    
    override func viewDidLoad() {
        
        let randomBusiness = getRandomPlace(businessArray)
        RestaurantName.text = randomBusiness.businessName
        googleClient.getImage(randomBusiness.businessPhotoReference) { (image) in
            self.backgroundImage.image = image
            self.cardImageView.image = image
        }
        applyBackgroundBlurEffect()
        cardImageView.layer.cornerRadius = 30.0
    }
    
   //MARK: Actions
    
    
}
