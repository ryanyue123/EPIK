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
    

    func getRandomPlace(playlist: NSArray)->Business{
        let num = Int(arc4random_uniform(UInt32(playlist.count)))
        let randomPlace = playlist[num]
        return randomPlace as! Business
    }
    
    override func viewDidLoad() {
        
    }
    
}