//
//  AddCommentViewController.swift
//  Yelpify
//
//  Created by Ryan Yue on 5/14/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit

class AddCommentViewController: UIViewController, UITextViewDelegate {

    @IBOutlet var popUpView: UIView!
    
    @IBOutlet weak var comment_content: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.comment_content.delegate = self
        comment_content.becomeFirstResponder()
        //roundCorners(popUpView)
        //roundCorners(comment_content)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    func roundCorners(view: UIView){
        // Round the banner's corners
        let maskPath: UIBezierPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: ([.TopLeft, .TopRight, .BottomLeft, .BottomRight]), cornerRadii: CGSizeMake(20, 20))
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = view.layer.bounds
        maskLayer.path = maskPath.CGPath
        view.layer.mask = maskLayer
        
        // Round cell corners
        view.layer.cornerRadius = 20
        // Add shadow
        view.layer.masksToBounds = false
    }

    // MARK: - TextField Delegate Functions
    
    func textViewDidBeginEditing(textView: UITextView) {
        self.popUpView.transform = CGAffineTransformMakeTranslation(0, -100)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        self.popUpView.transform = CGAffineTransformMakeTranslation(0, 100)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
