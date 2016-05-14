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
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func cancelComment(sender: UIButton) {
        self.comment_content.text = ""
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
