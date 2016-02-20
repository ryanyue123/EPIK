//
//  LocuAPIClient.swift
//  Yelpify
//
//  Created by Jonathan Lam on 2/18/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import Foundation
import OAuthSwift
import Alamofire

struct LocuAPIConsole {
    let APIKEY = "c670cc3b73f1b4ac1c297ab19b4111716552c83d"
}

class LocuAPIClient: NSObject {
    
    var parameters = [
        "api_key": "c670cc3b73f1b4ac1c297ab19b4111716552c83d",
        "fields" : ["name", "menus"],
        "venue_queries": [
            [
                "location" : ["locality": "Irvine"],
                "name" : "pizza"
            ]
        ]
    ]

    override init() {
        super.init()
    }
    
    func pullMediaObject(){
        
        Alamofire.request(.POST, "https://api.locu.com/v2/venue/search", parameters: self.parameters, encoding: .JSON)
            .responseJSON { response in
                //print(self.parameters)
                //print(response.request)  // original URL request
                //print(response.response) // URL response
                //print(response.data)     // server data
                //print(response.result)   // result of response serialization
                
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                }
        }
    }
    
}