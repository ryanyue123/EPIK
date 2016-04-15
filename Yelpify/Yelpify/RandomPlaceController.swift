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
    
    
    var business1 = Business(name: "Z Pizza", address: "4567 Caballos Rd.", city: "Santa Ana", zip: "92345", phone: "", imageURL: "", photoRef: "", latitude: 45, longitude: 34, distance: 15, rating: 4, categories: [], status: true, businessID: "", placeID: "")
    var business2 = Business(name: "Carlo's Pizza", address: "4555 Osono Ave", city: "Cerritos", zip: "93453", phone: "", imageURL: "", photoRef: "", latitude: 45, longitude: 34, distance: 15, rating: 4, categories: [], status: true, businessID: "", placeID: "")
    var business3 = Business(name: "Patrick's Pizza", address: "3544 Swag Rd.", city: "Alhambra", zip: "95683", phone: "", imageURL: "", photoRef: "", latitude: 45, longitude: 34, distance: 15, rating: 4, categories: [], status: true, businessID: "", placeID: "")
   
    @IBOutlet weak var RestaurantName: UILabel!
    @IBOutlet weak var RestaurantAddress: UILabel!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var cardImageView: UIImageView!
    
    func getRandomPlace(playlist: [Business])->Business{
        let num = Int32(arc4random_uniform(UInt32(playlist.count)))
        let randomPlace = playlist[Int(num)]
        return randomPlace
    }
    
    func applyBackgroundBlurEffect() {
        // Blur Effect
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        
        // Vibrancy Effect
        let vibrancyEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyEffectView.frame = blurEffectView.bounds
        
        // Add to subview
        backgroundImage.addSubview(blurEffectView)
        backgroundImage.addSubview(vibrancyEffectView)
    }

    
    override func viewDidLoad() {
        let randomBusiness = getRandomPlace([business1, business2, business2])
        RestaurantName.text = randomBusiness.businessName
        RestaurantAddress.text = randomBusiness.businessAddress
        applyBackgroundBlurEffect()
        cardImageView.layer.cornerRadius = 30.0
    }
    
   //MARK: Actions
    
    
}