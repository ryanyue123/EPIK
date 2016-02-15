//
//  ModalViewController.swift
//  Yelpify
//
//  Created by Ryan Yue on 2/14/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit
import Parse

class ModalViewController: UIViewController, UIPickerViewDelegate{

    @IBOutlet weak var playlistName: UITextField!
    @IBOutlet weak var pickerWheel: UIPickerView!
    @IBOutlet weak var playlistMood: UITextField!
    
    
    var pickerData: [String] = [String]()
    var playlistObject:PFObject!
    var ageGroup:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerWheel.delegate = self
        // Do any additional setup after loading the view.\
        pickerData = ["Teenagers", "Young Aduilts", "Adults", "Old People"]
        
        self.playlistObject = PFObject(className: (PFUser.currentUser()?.username)!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.playlistObject["AgeGroup"] = pickerData[row]
        
    }
    @IBAction func createPlaylist(sender: UIButton) {
        self.playlistObject["Name"] = self.playlistName.text
        self.playlistObject["Mood"] = self.playlistMood.text
        self.playlistObject.saveInBackgroundWithBlock{(success, error) -> Void in
            if success == true
            {
                print("saved")
            }
            else
            {
                print("failed")
            }
        }
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
