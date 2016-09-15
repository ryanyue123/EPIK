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
    
    func addShadow(_ radius: CGFloat = 3, opacity: Float = 0.3, offset: CGSize = CGSize.zero, path: Bool = false){
        if path{
            self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        }
        self.layer.shadowColor = UIColor.black.cgColor
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
    
    func showShadow(_ opacity: Float){
        self.layer.shadowOpacity = opacity
    }
    
    func fadeIn(_ duration: Double = 1, endAlpha: CGFloat = 1, beginScale: CGFloat, endScale: CGFloat = 1, beginOffsetY: CGFloat = 0, endOffsetY: CGFloat = 0){
        self.alpha = 0
        self.layer.frame.origin.y += beginOffsetY
        self.transform = CGAffineTransform(scaleX: beginScale, y: beginScale)
        self.clipsToBounds = true
        UIView.animate(withDuration: duration, animations: {
            self.layer.frame.origin.y -= endOffsetY
            self.alpha = endAlpha
            self.transform = CGAffineTransform(scaleX: endScale, y: endScale)
        })
    }
}

extension UILabel {
    func fadeIn(_ textToSet: String, duration: Double = 1, endAlpha: CGFloat = 1, beginScale: CGFloat, endScale: CGFloat = 1, beginOffsetY: CGFloat = 0, endOffsetY: CGFloat = 0){
        self.alpha = 0
        self.layer.frame.origin.y += beginOffsetY
        self.text = textToSet
        self.transform = CGAffineTransform(scaleX: beginScale, y: beginScale)
        self.clipsToBounds = true
        UIView.animate(withDuration: duration, animations: {
            self.layer.frame.origin.y -= endOffsetY
            self.alpha = endAlpha
            self.transform = CGAffineTransform(scaleX: endScale, y: endScale)
        })
    }
}

extension UIColor {
    public class func selectedGray() -> UIColor{
        return UIColor(netHex: 0xd5d5d5)
    }
}

extension UIImage {
    func imageWithColor(_ color1: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color1.setFill()
        
        let context = UIGraphicsGetCurrentContext()! as CGContext
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0);
        context.setBlendMode(CGBlendMode.normal)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height) as CGRect
        context.clip(to: rect, mask: self.cgImage!)
        context.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func resizedImage(_ width: CGFloat, height: CGFloat) -> UIImage{
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(size)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage!
    }

}

extension UIImageView {
    func fadeIn(_ imageToAdd: UIImage, duration: Double = 1,  endAlpha: CGFloat = 1, beginScale: CGFloat, endScale: CGFloat = 1){
        
        self.alpha = 0
        self.image = imageToAdd
        self.transform = CGAffineTransform(scaleX: beginScale, y: beginScale)
        self.clipsToBounds = true
        UIView.animate(withDuration: duration, animations: {
            self.alpha = endAlpha
            self.transform = CGAffineTransform(scaleX: endScale, y: endScale)
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
    
    func changeTopBarColor(_ color: UIColor){
        self.navigationController?.navigationBar.backgroundColor = color.withAlphaComponent((1))
        self.statusBar?.backgroundColor = color
    }
    
    func configureTopBar(_ color: UIColor = appDefaults.color){
        self.configureNavigationBar(self.view, color: color)
        self.configureStatusBar(color)
    }
    
    func configureStatusBar(_ color: UIColor){
        let statusBarRect = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 20.0)
        let statusBarView = UIView(frame: statusBarRect)
        statusBarView.backgroundColor = color
        self.view.addSubview(statusBarView)
        self.statusBar = statusBarView
    }
    
    func configureNavigationBar(_ outterView: UIView, color: UIColor){
        for parent in self.navigationBar.subviews {
            for childView in parent.subviews {
                if(childView is UIImageView) {
                    childView.removeFromSuperview()
                }
            }
        }
        
        self.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        self.navigationBar.backgroundColor = color
        self.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "Montserrat-Regular", size: 12)!,
            NSForegroundColorAttributeName: UIColor.white     ]
    }
    
    func resetTopBars(_ alpha: CGFloat){
        self.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(alpha) ]
        self.navigationBar.backgroundColor = appDefaults.color.withAlphaComponent(alpha)
        self.statusBar?.alpha = alpha
    }
    
    func resetNavigationBar(_ alpha: CGFloat){
        self.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(alpha) ]
        self.navigationBar.backgroundColor = appDefaults.color.withAlphaComponent(alpha)
    }
    
    func updateNavigationBarForFade(_ headerHeight: CGFloat, bottomScrollView: UIScrollView){
        let yOffset = bottomScrollView.contentOffset.y
        if yOffset < 0{
            let newAlpha = 1 - abs(yOffset) / 64.0
            self.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(newAlpha) ]
            self.navigationBar.backgroundColor = appDefaults.color.withAlphaComponent((newAlpha))
        }else{
            self.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(1) ]
            self.navigationBar.backgroundColor = appDefaults.color.withAlphaComponent((1))
        }
    }
    
    func updateStatusBarForFade(_ headerHeight: CGFloat, bottomScrollView: UIScrollView){
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
        self.isUserInteractionEnabled = true
    }
    
    func disable(){
        self.isUserInteractionEnabled = false
    }
    
    func fadeIn(_ textToSet: String, duration: Double = 1, endAlpha: CGFloat = 1, beginScale: CGFloat, endScale: CGFloat = 1, beginOffsetY: CGFloat = 0, endOffsetY: CGFloat = 0){
        self.alpha = 0
        self.layer.frame.origin.y += beginOffsetY
        self.text = textToSet
        self.transform = CGAffineTransform(scaleX: beginScale, y: beginScale)
        self.clipsToBounds = true
        UIView.animate(withDuration: duration, animations: {
            self.layer.frame.origin.y -= endOffsetY
            self.alpha = endAlpha
            self.transform = CGAffineTransform(scaleX: endScale, y: endScale)
        })
    }
}
