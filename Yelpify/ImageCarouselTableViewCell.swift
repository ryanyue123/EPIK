//
//  ImageCarouselTableViewCell.swift
//  Yelpify
//
//  Created by Jonathan Lam on 5/16/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import SwiftPhotoGallery

class ImageCarouselTableViewCell: UITableViewCell, SwiftPhotoGalleryDelegate, SwiftPhotoGalleryDataSource {

    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    @IBOutlet weak var imageThree: UIImageView!
    @IBOutlet weak var morePhotosButton: UIButton!
    
    func setImages(place: GooglePlaceDetail){
        
        let gPlacesClient = GooglePlacesAPIClient()
        let imageRefArray = place.photos
        
        for (index, ref) in imageRefArray.enumerate(){
            if index < 3{
                gPlacesClient.getImage(ref as! String) { (image) in
                    switch index{
                    case 0:
                        Animations.fadeInImageView(self.imageOne, imageToAdd: image, beginScale: 1)
                        //self.imageOne.image = image
                    case 1:
                        Animations.fadeInImageView(self.imageTwo, imageToAdd: image, beginScale: 1)
                        //self.imageTwo.image = image
                    case 2:
                        Animations.fadeInImageView(self.imageThree, imageToAdd: image, beginScale: 1)
                    default:
                        break
                    }
                }
            }else{
                break
            }
        }
    }
    
    
    // MARK: - SwiftPhotoGallery Delegate Methods
    
    func configureCarouselGallery(){
        let gallery = SwiftPhotoGallery(delegate: self, dataSource: self)
        gallery.backgroundColor = appDefaults.color_bg
        gallery.pageIndicatorTintColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        gallery.currentPageIndicatorTintColor = appDefaults.color_darker
    }
    
    let imageNames = ["face", "temp_profile", "default_restaurant"]
    
    func numberOfImagesInGallery(gallery: SwiftPhotoGallery) -> Int {
        return imageNames.count
    }
    
    func imageInGallery(gallery: SwiftPhotoGallery, forIndex: Int) -> UIImage? {
        return UIImage(named: imageNames[forIndex])
    }
    
    func galleryDidTapToClose(gallery: SwiftPhotoGallery) {
        // do something cool like:
        //dismissViewControllerAnimated(true, completion: nil)
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
