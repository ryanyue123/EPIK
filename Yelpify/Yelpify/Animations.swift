//
//  Animations.swift
//  Yelpify
//
//  Created by Jonathan Lam on 5/17/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import Foundation
import UIKit

struct Animations{
    // MARK: - Animation Functions
    static func fadeInImageView(_ imageView: UIImageView, imageToAdd: UIImage, duration: Double = 1,  endAlpha: CGFloat = 1, beginScale: CGFloat, endScale: CGFloat = 1){
        
        imageView.alpha = 0
        imageView.image = imageToAdd
        imageView.transform = CGAffineTransform(scaleX: beginScale, y: beginScale)
        imageView.clipsToBounds = true
        UIView.animate(withDuration: duration, animations: {
            imageView.alpha = endAlpha
            imageView.transform = CGAffineTransform(scaleX: endScale, y: endScale)
        })
    }
    
    static func fadeInView(_ view: UIView, duration: Double = 1, endAlpha: CGFloat = 1, beginScale: CGFloat, endScale: CGFloat = 1, beginOffsetY: CGFloat = 0, endOffsetY: CGFloat = 0){
        view.alpha = 0
        view.layer.frame.origin.y += beginOffsetY
        view.transform = CGAffineTransform(scaleX: beginScale, y: beginScale)
        view.clipsToBounds = true
        UIView.animate(withDuration: duration, animations: {
            view.layer.frame.origin.y -= endOffsetY
            view.alpha = endAlpha
            view.transform = CGAffineTransform(scaleX: endScale, y: endScale)
        })
    }
    
    static func fadeInLabel(_ label: UILabel, textToSet: String, duration: Double = 1, endAlpha: CGFloat = 1, beginScale: CGFloat, endScale: CGFloat = 1, beginOffsetY: CGFloat = 0, endOffsetY: CGFloat = 0){
        label.alpha = 0
        label.layer.frame.origin.y += beginOffsetY
        label.text = textToSet
        label.transform = CGAffineTransform(scaleX: beginScale, y: beginScale)
        label.clipsToBounds = true
        UIView.animate(withDuration: duration, animations: {
            label.layer.frame.origin.y -= endOffsetY
            label.alpha = endAlpha
            label.transform = CGAffineTransform(scaleX: endScale, y: endScale)
        })
    }
    
    static func fadeInTextField(_ textField: UITextField, textToSet: String, duration: Double = 1, endAlpha: CGFloat = 1, beginScale: CGFloat, endScale: CGFloat = 1, beginOffsetY: CGFloat = 0, endOffsetY: CGFloat = 0){
        textField.alpha = 0
        textField.layer.frame.origin.y += beginOffsetY
        textField.text = textToSet
        textField.transform = CGAffineTransform(scaleX: beginScale, y: beginScale)
        textField.clipsToBounds = true
        UIView.animate(withDuration: duration, animations: {
            textField.layer.frame.origin.y -= endOffsetY
            textField.alpha = endAlpha
            textField.transform = CGAffineTransform(scaleX: endScale, y: endScale)
        })
    }
    
    static func roundCorners(_ view: UIView, radius: CGFloat = 20.0, corners: UIRectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]){
        
        let roundedRect = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.width, height: view.frame.height)
        
        // Round the banner's corners
        let maskPath: UIBezierPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: (corners), cornerRadii: CGSize(width: radius, height: radius))
        
        let maskLayer: CAShapeLayer = CAShapeLayer()
        
        maskLayer.frame = view.bounds
        maskLayer.path = maskPath.cgPath
        view.layer.mask = maskLayer
        
        // Round cell corners
        //view.layer.cornerRadius = radius
        view.clipsToBounds = true
//        view.layer.masksToBounds = false
    }
    
    static func roundSquareImageView(_ imageView: UIImageView, outerView: UIView?, borderWidth: CGFloat?, borderColor: UIColor? = UIColor.white){
        func roundingUIView(_ aView: UIView!, cornerRadiusParam: CGFloat!) {
            aView.clipsToBounds = true
            aView.layer.cornerRadius = cornerRadiusParam
        }
        roundingUIView(imageView, cornerRadiusParam: imageView.frame.width / 2)
        if outerView != nil{
            roundingUIView(outerView, cornerRadiusParam: imageView.frame.width / 2)
        }
        
        if borderWidth != nil{
            imageView.layer.borderWidth = borderWidth!
            imageView.layer.borderColor = borderColor!.cgColor
        }
    }

}
