//
//  BusinessTableViewCell.swift
//  Yelpify
//
//  Created by Jonathan Lam on 2/17/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit

class BusinessTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var businessTitleLabel: UILabel!
    @IBOutlet weak var businessBackgroundImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
