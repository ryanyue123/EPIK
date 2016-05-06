//
//  PlaceActions.swift
//  Yelpify
//
//  Created by Kay Lab on 5/5/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import Foundation
import UIKit

struct PlaceActions{
    private func convertAddress(address: String) -> String{
        let addressArray = address.characters.split{$0 == " "}.map(String.init)
        var resultString = ""
        for word in addressArray{
            resultString += word + "+"
        }
        return resultString
    }
    
    private func convertPhone(phone: String) -> Int{
        let phoneArray = phone.characters.map { String($0) }
        var result = ""
        for char in phoneArray{
            if Int(char) != nil{
                result += char
            }
        }
        return Int(result)!
    }
    
    private func openInMaps(business: Business) {
        let latitude = business.businessLatitude!
        let longitude = business.businessLongitude!
        
        if (UIApplication.sharedApplication().canOpenURL(NSURL(string: "comgooglemaps://")!))
        {
            let name = convertAddress(business.businessAddress!)
            //let name = self.object.businessName//self.object.businessName?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            print(name)
            let url = NSURL(string: "comgooglemaps://?saddr=\(name)&center=\(latitude),\(longitude)&directionsmode=driving")!
            print(url)
            UIApplication.sharedApplication().openURL(url)
        }
        else
        {
            print("not allowed")
        }
    }
    
    private func openInPhone(business: Business)
    {
        let telnum = convertPhone(business.businessPhone!)
        if(UIApplication.sharedApplication().canOpenURL(NSURL(string: "tel://")!))
        {
            let url = NSURL(string: "tel://\(telnum)")
            UIApplication.sharedApplication().openURL(url!)
        }
    }
    private func openInWeb(business: Business)
    {
        //check is self.object.businessURL is nil
        //let url = self.object.businessURL
        let url = NSURL(string: "")
        if (UIApplication.sharedApplication().canOpenURL(url!))
        {
            UIApplication.sharedApplication().openURL(url!)
        }
    }

}