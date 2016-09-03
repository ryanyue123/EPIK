//
//  UIExtensions.swift
//  Lyster
//
//  Created by Jonathan Lam on 8/25/16.
//  Copyright © 2016 Limitless. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC


private var xoAssociationKey: UInt8 = 0


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
    
    func addShadow(radius: CGFloat = 3, opacity: Float = 0.3, offset: CGSize = CGSizeZero, path: Bool = false){
        if path{
            self.layer.shadowPath = UIBezierPath(rect: self.bounds).CGPath
        }
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
    
    func fadeIn(duration: Double = 1, endAlpha: CGFloat = 1, beginScale: CGFloat, endScale: CGFloat = 1, beginOffsetY: CGFloat = 0, endOffsetY: CGFloat = 0){
        self.alpha = 0
        self.layer.frame.origin.y += beginOffsetY
        self.transform = CGAffineTransformMakeScale(beginScale, beginScale)
        self.clipsToBounds = true
        UIView.animateWithDuration(duration, animations: {
            self.layer.frame.origin.y -= endOffsetY
            self.alpha = endAlpha
            self.transform = CGAffineTransformMakeScale(endScale, endScale)
        })
    }
}

extension UILabel {
    func fadeIn(textToSet: String, duration: Double = 1, endAlpha: CGFloat = 1, beginScale: CGFloat, endScale: CGFloat = 1, beginOffsetY: CGFloat = 0, endOffsetY: CGFloat = 0){
        self.alpha = 0
        self.layer.frame.origin.y += beginOffsetY
        self.text = textToSet
        self.transform = CGAffineTransformMakeScale(beginScale, beginScale)
        self.clipsToBounds = true
        UIView.animateWithDuration(duration, animations: {
            self.layer.frame.origin.y -= endOffsetY
            self.alpha = endAlpha
            self.transform = CGAffineTransformMakeScale(endScale, endScale)
        })
    }
}

extension UIColor {
    public class func selectedGray() -> UIColor{
        return UIColor(netHex: 0xd5d5d5)
    }
}

extension UIImage {
    func imageWithColor(color1: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color1.setFill()
        
        let context = UIGraphicsGetCurrentContext()! as CGContextRef
        CGContextTranslateCTM(context, 0, self.size.height)
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        
        let rect = CGRectMake(0, 0, self.size.width, self.size.height) as CGRect
        CGContextClipToMask(context, rect, self.CGImage)
        CGContextFillRect(context, rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func resizedImage(width: CGFloat, height: CGFloat) -> UIImage{
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(size)
        self.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }

}

extension UIImageView {
    func fadeIn(imageToAdd: UIImage, duration: Double = 1,  endAlpha: CGFloat = 1, beginScale: CGFloat, endScale: CGFloat = 1){
        
        self.alpha = 0
        self.image = imageToAdd
        self.transform = CGAffineTransformMakeScale(beginScale, beginScale)
        self.clipsToBounds = true
        UIView.animateWithDuration(duration, animations: {
            self.alpha = endAlpha
            self.transform = CGAffineTransformMakeScale(endScale, endScale)
        })
    }
}

extension UINavigationController{
    
    var statusBar: UIView? {
        get {
            return objc_getAssociatedObject(self, &xoAssociationKey) as? UIView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &xoAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func changeTopBarColor(color: UIColor){
        self.navigationController?.navigationBar.backgroundColor = color.colorWithAlphaComponent((1))
        self.statusBar?.backgroundColor = color
    }
    
    func configureTopBar(color: UIColor = appDefaults.color){
        self.configureNavigationBar(self.view, color: color)
        self.configureStatusBar(color)
    }
    
    func configureStatusBar(color: UIColor){
        let statusBarRect = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 20.0)
        let statusBarView = UIView(frame: statusBarRect)
        statusBarView.backgroundColor = color
        self.view.addSubview(statusBarView)
        self.statusBar = statusBarView
    }
    
    func configureNavigationBar(outterView: UIView, color: UIColor){
        for parent in self.navigationBar.subviews {
            for childView in parent.subviews {
                if(childView is UIImageView) {
                    childView.removeFromSuperview()
                }
            }
        }
        
        self.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        self.navigationBar.backgroundColor = color
        self.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "Montserrat-Regular", size: 12)!,
            NSForegroundColorAttributeName: UIColor.whiteColor()     ]
    }
    
    func resetTopBars(alpha: CGFloat){
        self.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(alpha) ]
        self.navigationBar.backgroundColor = appDefaults.color.colorWithAlphaComponent(alpha)
        self.statusBar?.alpha = alpha
    }
    
    func resetNavigationBar(alpha: CGFloat){
        self.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(alpha) ]
        self.navigationBar.backgroundColor = appDefaults.color.colorWithAlphaComponent(alpha)
    }
    
    func updateNavigationBarForFade(headerHeight: CGFloat, bottomScrollView: UIScrollView){
        let yOffset = bottomScrollView.contentOffset.y
        if yOffset < 0{
            let newAlpha = 1 - abs(yOffset) / 64.0
            self.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(newAlpha) ]
            self.navigationBar.backgroundColor = appDefaults.color.colorWithAlphaComponent((newAlpha))
        }else{
            self.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(1) ]
            self.navigationBar.backgroundColor = appDefaults.color.colorWithAlphaComponent((1))
        }
    }
    
    func updateStatusBarForFade(headerHeight: CGFloat, bottomScrollView: UIScrollView){
        let yOffset = bottomScrollView.contentOffset.y
        if yOffset < 0{
            let newAlpha = 1 - abs(yOffset) / 64.0
            self.statusBar!.alpha = newAlpha
        }else{
            self.statusBar!.alpha = 1
        }
        
    }

}

extension UITextField {
    func enable(){
        self.userInteractionEnabled = true
    }
    
    func disable(){
        self.userInteractionEnabled = false
    }
    
    func fadeIn(textToSet: String, duration: Double = 1, endAlpha: CGFloat = 1, beginScale: CGFloat, endScale: CGFloat = 1, beginOffsetY: CGFloat = 0, endOffsetY: CGFloat = 0){
        self.alpha = 0
        self.layer.frame.origin.y += beginOffsetY
        self.text = textToSet
        self.transform = CGAffineTransformMakeScale(beginScale, beginScale)
        self.clipsToBounds = true
        UIView.animateWithDuration(duration, animations: {
            self.layer.frame.origin.y -= endOffsetY
            self.alpha = endAlpha
            self.transform = CGAffineTransformMakeScale(endScale, endScale)
        })
    }
}