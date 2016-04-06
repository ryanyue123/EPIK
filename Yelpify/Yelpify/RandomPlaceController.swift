//
//  RandomPlaceController.swift
//  Yelpify
//
//  Created by Kay Lab on 4/5/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import Foundation

class RandomPlaceController: UITableViewController{
    
   
    let num = Int32(arc4random_uniform(sizeOf(playlist)))
    func getRandomPlace(num: Int)->Business{
        let randomPlace = playlist[num]
        return randomPlace
    }
   
}