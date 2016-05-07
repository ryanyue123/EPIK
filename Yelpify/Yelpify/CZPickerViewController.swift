//
//  CZPickerViewController.swift
//  Yelpify
//
//  Created by Kay Lab on 5/6/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import Foundation
import UIKit
import CZPicker

class CZPickerViewController: UIViewController {
    
    var fruits = [String]()
    var fruitImages = [UIImage]()
    var pickerWithImage: CZPickerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fruits = ["Apple", "Banana", "Grape", "Watermelon", "Lychee"]
        fruitImages = [UIImage(named: "default_Icon")!, UIImage(named: "default_Icon")!, UIImage(named: "default_Icon")!, UIImage(named: "default_Icon")!, UIImage(named: "default_Icon")!]

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showWithFooter(sender: AnyObject) {
        let picker = CZPickerView(headerTitle: "Fruits", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
        picker.delegate = self
        picker.dataSource = self
        picker.needFooterView = true
        picker.show()
    }
    
    @IBAction func showWithoutFooter(sender: AnyObject) {
        let picker = CZPickerView(headerTitle: "Fruits", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
        picker.delegate = self
        picker.dataSource = self
        picker.needFooterView = false
        picker.show()
    }
    
    
    func showWithMultipleSelections(sender: AnyObject) {
        let picker = CZPickerView(headerTitle: "Sort Options", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
        self.czpickerView(picker, imageForRow: 1)
        picker.delegate = self
        picker.dataSource = self
        picker.needFooterView = false
        picker.allowMultipleSelection = true
        
        
        picker.show()
    }
    
    @IBAction func showWithImages(sender: AnyObject) {
        pickerWithImage = CZPickerView(headerTitle: "Fruits", cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
        pickerWithImage?.delegate = self
        pickerWithImage?.dataSource = self
        pickerWithImage?.needFooterView = false
        pickerWithImage?.show()
    }
}

extension CZPickerViewController: CZPickerViewDelegate, CZPickerViewDataSource {
    func czpickerView(pickerView: CZPickerView!, imageForRow row: Int) -> UIImage! {
        if pickerView == pickerWithImage {
            return fruitImages[row]
        }
        return nil
    }
    
    func numberOfRowsInPickerView(pickerView: CZPickerView!) -> Int {
        return fruits.count
    }
    
    func czpickerView(pickerView: CZPickerView!, titleForRow row: Int) -> String! {
        print(fruits)
        return fruits[row]
    }
    
    func czpickerView(pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int){
        print(fruits[row])
    }
    
    func czpickerView(pickerView: CZPickerView!, didConfirmWithItemsAtRows rows: [AnyObject]!) {
        for row in rows {
            if let row = row as? Int {
                print(fruits[row])
            }
        }
    }
}