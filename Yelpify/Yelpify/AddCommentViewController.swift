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
    @IBOutlet weak var modalView: UIView!
    
    @IBOutlet weak var comment_content: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalView.layer.cornerRadius = 20.0
        self.modalView.clipsToBounds = true
        
        self.comment_content.layer.cornerRadius = 10.0
        
        self.comment_content.delegate = self
        comment_content.becomeFirstResponder()
    }
    
    override func viewDidAppear(animated: Bool) {
    }

    // MARK: - TextField Delegate Functions
    
    func textViewDidBeginEditing(textView: UITextView) {
        self.popUpView.transform = CGAffineTransformMakeTranslation(0, -100)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        self.popUpView.transform = CGAffineTransformMakeTranslation(0, 100)
    }

}
