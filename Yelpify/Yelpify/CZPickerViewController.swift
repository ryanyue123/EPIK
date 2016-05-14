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

protocol ModalViewControllerDelegate
{
    func sendValue(var value: AnyObject)
}


class CZPickerViewController: UIViewController {
    
    var fruits = []
    var fruitImages = [UIImage]()
    var pickerWithImage: CZPickerView?
    var item = String()
    var headerTitle = String()
    var businessArrayToSort: [Business]!
    var didSet = false
    var delegate:ModalViewControllerDelegate!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //fruits = ["Apple", "Banana", "Grape", "Watermelon", "Lychee"]
        //fruitImages = [UIImage(named: "default_Icon")!, UIImage(named: "default_Icon")!, UIImage(named: "default_Icon")!, UIImage(named: "default_Icon")!, UIImage(named: "default_Icon")!]

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func showWithFooter(sender: AnyObject) {
        let picker = CZPickerView(headerTitle: headerTitle, cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
        picker.headerBackgroundColor = appDefaults.color
        picker.confirmButtonBackgroundColor = appDefaults.color
        picker.tapBackgroundToDismiss = true
        picker.delegate = self
        picker.dataSource = self
        picker.needFooterView = true
        picker.show()
    }
    
    @IBAction func showWithoutFooter(sender: AnyObject) {
        let picker = CZPickerView(headerTitle: headerTitle, cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
        picker.headerBackgroundColor = appDefaults.color
        picker.confirmButtonBackgroundColor = appDefaults.color
        picker.delegate = self
        picker.dataSource = self
        picker.needFooterView = false
        picker.show()
    }
    
    
    func showWithMultipleSelections(sender: AnyObject){
        let picker = CZPickerView(headerTitle: headerTitle, cancelButtonTitle: "Cancel", confirmButtonTitle: "Confirm")
        picker.headerBackgroundColor = appDefaults.color
        picker.confirmButtonBackgroundColor = appDefaults.color
        picker.delegate = self
        picker.dataSource = self
        picker.needFooterView = true
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
        //print(fruits[row])
        return fruits[row] as! String
    }
    
    func czpickerView(pickerView: CZPickerView!, didConfirmWithItemAtRow row: Int) {
        delegate.sendValue(fruits[row])
        didSet = true
    }
    
    func czpickerView(pickerView: CZPickerView!, didConfirmWithItemsAtRows rows: [AnyObject]!) {
        
        for row in rows {
            if let row = row as? Int {
                delegate.sendValue(row)
            }
        }
    }
  
    
    
    
}