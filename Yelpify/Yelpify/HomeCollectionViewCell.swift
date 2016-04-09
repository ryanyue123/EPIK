//
//  HomeCollectionViewCell.swift
//  Yelpify
//
//  Created by Ryan Yue on 4/8/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
@IBDesignable

class HomeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
    }
    override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
}
