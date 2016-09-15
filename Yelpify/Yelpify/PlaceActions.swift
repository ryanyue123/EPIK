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
   
    static func openInMaps(_ business: Business? = nil, place: GooglePlaceDetail? = nil) {
        func convertAddress(_ address: String) -> String{
            let addressArray = address.characters.split{$0 == " "}.map(String.init)
            var resultString = ""
            for word in addressArray{
                resultString += word + "+"
            }
            return resultString
        }
        
        var latitude: Double!
        var longitude: Double!
        
        if business != nil{
            latitude = business!.businessLatitude!
            longitude = business!.businessLongitude!
        }else{
            latitude = place!.latitude
            longitude = place!.longitude
        }
        
        if (UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!))
        {
            var name: String!
            if business != nil{
                name = convertAddress(business!.businessAddress)
            }else{
                name = convertAddress(place!.formattedAddress)
            }
            print(name)
            let url = URL(string: "comgooglemaps://?daddr=\(name)&center=\(latitude),\(longitude)&directionsmode=driving")!
            print(url)
            UIApplication.shared.openURL(url)
        }
        else
        {
            print("not allowed")
        }
    }
    
    static func openInPhone(_ business: Business? = nil, place: GooglePlaceDetail? = nil)
    {
        func convertPhone(_ phone: String) -> Int{
            let phoneArray = phone.characters.map { String($0) }
            var result = ""
            for char in phoneArray{
                if Int(char) != nil{
                    result += char
                }
            }
            return Int(result)!
        }
        
        var telnum: Int!
        if business != nil{
            telnum = convertPhone(business!.businessPhone!)
        }else{
            telnum = convertPhone(place!.phone)
        }
        
        if(UIApplication.shared.canOpenURL(URL(string: "tel://")!))
        {
            let url = URL(string: "tel://\(telnum)")
            UIApplication.shared.openURL(url!)
        }
    }
    func openInWeb(_ business: Business)
    {
        //check is self.object.businessURL is nil
        //let url = self.object.businessURL
        let url = URL(string: "")
        if (UIApplication.shared.canOpenURL(url!))
        {
            UIApplication.shared.openURL(url!)
        }
    }

}
