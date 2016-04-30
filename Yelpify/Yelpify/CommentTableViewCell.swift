//
//  CommentTableViewCell.swift
//  Yelpify
//
//  Created by Jonathan Lam on 4/28/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import Haneke
import SwiftyJSON

class CommentTableViewCell: UITableViewCell {
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var reviewRating: UIImageView!
    @IBOutlet weak var reviewName: UILabel!
    @IBOutlet weak var reviewDate: UILabel!
    @IBOutlet weak var reviewProfileImage: UIImageView!
    
    let cache = Shared.dataCache
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(review: NSDictionary){
        
        self.reviewTextView.text = review["text"] as? String
        self.reviewName.text = review["author_name"] as? String
        
        if let profilePhotoURL = review["profile_photo_url"] as? String{
            
            //let fetcher = NetworkFetcher<UIImage>(URL: NSURL(string: profilePhotoURL)!)
            cache.fetch(URL: NSURL(string: profilePhotoURL)!).onSuccess({ (data) in
                self.reviewProfileImage.image = UIImage(data: data)
            })
        }
        
        if let unixTime = review["time"] as? Double{
            let date = NSDate(timeIntervalSince1970: unixTime)
            let dateFormatter = NSDateFormatter()
            dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle //Set date style
            dateFormatter.timeZone = NSTimeZone()
            let localDate = dateFormatter.stringFromDate(date)
            self.reviewDate.text = localDate
        }
        
        
//        //if let text = review
//        self.reviewTextView.text = text
//        self.reviewName.text = name
//        self.reviewDate.text = date
    }

}
