//
//  ReviewTableViewCell.swift
//  Yelpify
//
//  Created by Jonathan Lam on 4/28/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import Haneke
import SwiftyJSON
import Cosmos

class ReviewTableViewCell: UITableViewCell {
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var reviewName: UILabel!
    @IBOutlet weak var reviewDate: UILabel!
    @IBOutlet weak var reviewProfileImage: UIImageView!
    @IBOutlet weak var CommentRating: CosmosView!
    
    let cache = Shared.dataCache
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(_ review: NSDictionary, ratingHidden: Bool = false){
        
        self.roundProf()
        
        self.contentView.autoresizingMask = [.flexibleHeight]
        // Set Review Text
        self.reviewTextView.text = review["text"] as? String
        
        // Set Review Author Name
        self.reviewName.text = review["author_name"] as? String
        
        if ratingHidden == false{
            // Set Review Rating
            if let ratingValue3 = review["rating"] as? Double{
                if ratingValue3 != -1{
                    self.CommentRating.rating = ratingValue3
                }
            }
        }else{
            self.CommentRating.isHidden = true
        }
        
        if let profilePhoto = review["profile_photo"] as? UIImage{
            Animations.fadeInImageView(reviewProfileImage, imageToAdd: profilePhoto, beginScale: 1.0)
        }
        
        // Set Review Author Profile Picture
        if let profilePhotoURL = review["profile_photo_url"] as? String{
            cache.fetch(URL: URL(string: profilePhotoURL)! as NSURL).onSuccess(onSuccess: { (data) in
                self.reviewProfileImage.image = UIImage(data: data)
            })
        }
        
        if let unixTime = review["time"] as? Double{
            let date = Date(timeIntervalSince1970: unixTime)
            let dateFormatter = DateFormatter()
            //dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
            dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
            dateFormatter.timeZone = TimeZone(abbreviation: "PST")
            let localDate = dateFormatter.string(from: date)
            self.reviewDate.text = localDate
        }else if let unixTimeString = review["time"] as? String{
            let unixTime = Double(unixTimeString)!
            let date = Date(timeIntervalSince1970: unixTime)
            let dateFormatter = DateFormatter()
            //dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
            dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
            dateFormatter.timeZone = TimeZone(abbreviation: "PST")
            let localDate = dateFormatter.string(from: date)
            self.reviewDate.text = localDate

        }
        
    }
    
    func roundProf(){
        self.roundingUIView(self.reviewProfileImage, cornerRadiusParam: 15)
        self.roundingUIView(self.reviewProfileImage, cornerRadiusParam: 15)
        self.reviewProfileImage.layer.borderWidth = 1.0
        self.reviewProfileImage.layer.borderColor = appDefaults.color_darker.cgColor //UIColor.whiteColor().CGColor
    }
    
    fileprivate func roundingUIView(_ aView: UIView!, cornerRadiusParam: CGFloat!) {
        aView.clipsToBounds = true
        aView.layer.cornerRadius = cornerRadiusParam
    }

}
