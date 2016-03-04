//
//  TestViewController.swift
//  Yelpify
//
//  Created by Jonathan Lam on 3/3/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    
    
    let googleClient = GooglePlacesAPIClient()
    let yelpClient = YelpAPIClient()
    let dataHandler = APIDataHandler()
    
    var businessShown: [Bool] = []
    var businessObjects: [Business] = []
    
    var yelpSearchParameters = [
        "ll": "33.64496794563093,-117.83725295740864",
        "term": "tacos",
        "radius_filter": "10000",
        "sort": "1"]


    override func viewDidLoad() {
        super.viewDidLoad()
        var searchName = ""
        var searchCoordinate = []
        yelpClient.searchPlacesWithParameters(yelpSearchParameters) { (result) -> Void in
            print(result)
            self.dataHandler.parseYelpJSON(result, completion: { (yelpBusinessArray) -> Void in
                let business = yelpBusinessArray[0]
                print("\n")
                searchName = business.businessName
                searchCoordinate = [business.businessLatitude, business.businessLongitude]
                
                print(business.businessName)
                print(business.businessAddress)
                print(business.businessLatitude, business.businessLongitude)
                print("\n")
                
//                self.googleClient.searchPlaceWithNameAndCoordinates(searchName, coordinates: searchCoordinate, completion: { (JSONdata) -> Void in
//                    self.dataHandler.parseGPlacesJSON(JSONdata, completion: { (googlePlacesArray) -> Void in
//                        for place in googlePlacesArray{
//                            
//                            print(place.placeName)
//                            print(place.placeAddress)
//                            print("\n")
//                        }
//                    })
//                })
                
            })
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
