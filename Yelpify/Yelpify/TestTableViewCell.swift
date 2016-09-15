//
//  TestTableViewCell.swift
//  Yelpify
//
//  Created by Jonathan Lam on 3/1/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit

class TestTableViewCell: UITableViewCell {

    @IBOutlet weak var backgroundImage: UIImageView!
    
    
    @IBOutlet weak var businessNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
