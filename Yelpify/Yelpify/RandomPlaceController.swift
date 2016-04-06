//
//  RandomPlaceController.swift
//  Yelpify
//
//  Created by Kay Lab on 4/5/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import Foundation

class RandomPlaceController: UITableViewController{
    
   
    
    func getRandomPlace(playlist: Array<Business>)->Business{
        let num = Int32(arc4random_uniform(sizeOf(playlist)))
        let randomPlace = playlist[num]
        return randomPlace
    }
   
    
}