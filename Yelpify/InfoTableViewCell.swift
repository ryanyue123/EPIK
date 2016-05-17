//
//  InfoTableViewCell.swift
//  Yelpify
//
//  Created by Jonathan Lam on 5/15/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit

class InfoTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    func configureCell(icon: UIImage, label: String){
        self.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth(self.bounds), 0, 0)
        self.icon.image = icon
        self.label.text = label
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
