//
//  SearchPeopleCell.swift
//  Yelpify
//
//  Created by Ryan Yue on 5/6/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit

class SearchPeopleCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    
    func configureCell(name: String, handle: String){
        nameLabel.text = name
        handleLabel.text = handle
        roundProf()
    }
    
    func roundProf(){
        self.roundingUIView(self.profilePicture, cornerRadiusParam: 30)
        self.roundingUIView(self.profilePicture, cornerRadiusParam: 30)
        self.profilePicture.layer.borderWidth = 1.0
        self.profilePicture.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    private func roundingUIView(let aView: UIView!, let cornerRadiusParam: CGFloat!) {
        aView.clipsToBounds = true
        aView.layer.cornerRadius = cornerRadiusParam
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
