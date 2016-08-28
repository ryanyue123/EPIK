//
//  UIExtensions.swift
//  Lyster
//
//  Created by Jonathan Lam on 8/25/16.
//  Copyright © 2016 Limitless. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    var y: CGFloat! {
        get {
            return self.frame.origin.y
        }
        set(y) {
            self.frame = CGRect(x: self.frame.origin.x, y: y, width: self.frame.width, height: self.frame.height)
        }
    }
    
    var x: CGFloat! {
        get {
            return self.frame.origin.x
        }
        set(x) {
            self.frame = CGRect(x: x, y: self.frame.origin.y, width: self.frame.width, height: self.frame.height)
        }
    }
    
    var height: CGFloat! {
        get {
            return self.frame.height
        }
        set(height) {
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: height)
        }
    }
    
    func addShadow(radius: CGFloat = 3, opacity: Float = 0.3, offset: CGSize = CGSizeZero){
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
        
        if self.superview?.clipsToBounds == true{
            print("WARNING: Clips to bounds must be false in order for shadow to be drawn")
        }
    }
    
    func hideShadow(){
        self.layer.shadowOpacity = 0
    }
    
    func showShadow(opacity: Float){
        self.layer.shadowOpacity = opacity
    }

}