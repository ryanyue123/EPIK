//
//  CommentTableViewCell.swift
//  Yelpify
//
//  Created by Jonathan Lam on 4/28/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    @IBOutlet weak var reviewTextView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(text: String){
        self.reviewTextView.text = text
    }

}
