//
//  AddCommentViewController.swift
//  Yelpify
//
//  Created by Ryan Yue on 5/14/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit

class AddCommentViewController: UIViewController {

    @IBOutlet var popUpView: UIView!
    
    @IBOutlet weak var comment_content: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
