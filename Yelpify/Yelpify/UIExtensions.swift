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

extension UIViewController {

    var statusBar: UIView? {
        get {
            return objc_getAssociatedObject(self, &xoAssociationKey) as? UIView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &xoAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func changeTopBarColor(color: UIColor){
        self.statusBar!.backgroundColor = color
        self.navigationController!.navigationBar.backgroundColor = color
    }
    
    func configureTopBar(color: UIColor = appDefaults.color) -> (UIView, UIView){
        self.statusBar = self.navigationController?.configureStatusBar(color)
        let navBar = self.navigationController?.configureNavigationBar(self.view, color: color)
        
        return (navBar!, statusBar!)
    }
    
    func updateNavigationBarForFade(headerHeight: CGFloat, bottomScrollView: UIScrollView){
        let yOffset = bottomScrollView.contentOffset.y
        if yOffset < 0{
            let newAlpha = (headerHeight + yOffset) / headerHeight
            self.navigationController?.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(newAlpha) ]
            self.navigationController?.navigationBar.backgroundColor = appDefaults.color.colorWithAlphaComponent((newAlpha))
        }else{
            self.navigationController?.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(1) ]
            self.navigationController?.navigationBar.backgroundColor = appDefaults.color.colorWithAlphaComponent((1))
        }
    }
    
    func updateStatusBarForFade(headerHeight: CGFloat, bottomScrollView: UIScrollView, statusBar: UIView){
        let yOffset = bottomScrollView.contentOffset.y
        if yOffset < 0{
            let newAlpha = (headerHeight + yOffset) / headerHeight
            statusBar.alpha = newAlpha
        }else{
            statusBar.alpha = 1
        }

    }
}

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
}

extension UINavigationController{
    func configureStatusBar(color: UIColor) -> UIView{
        let statusBarRect = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 20.0)
        let statusBarView = UIView(frame: statusBarRect)
        statusBarView.backgroundColor = color
        self.view.addSubview(statusBarView)
        return statusBarView
    }
    
    func configureNavigationBar(outterView: UIView, color: UIColor) -> UIView{
        func addShadowToBar() -> UIView{
            let shadowView = UIView(frame: self.navigationBar.frame)
            shadowView.layer.masksToBounds = false
            shadowView.layer.shadowOpacity = 0.7 // your opacity
            shadowView.layer.shadowOffset = CGSize(width: 0, height: 3) // your offset
            shadowView.layer.shadowRadius =  10 //your radius
            outterView.addSubview(shadowView)
            //outterView.bringSubviewToFront(statusBarView)
            
            //shadowView.tag = 100
            return shadowView
        }
        
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
        
        return addShadowToBar()
    }
    
    func resetNavigationBar(){
        self.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(1) ]
        self.navigationBar.backgroundColor = appDefaults.color.colorWithAlphaComponent(1)
        //        navController.navigationBar.alpha = 1
        //        navController.navigationItem.titleView?.alpha = 1
    }

}

extension UITextField {
    func enable(){
        self.userInteractionEnabled = true
    }
    
    func disable(){
        self.userInteractionEnabled = false
    }
}
