//
//  APIDataHandler.swift
//  Yelpify
//
//  Created by Jonathan Lam on 2/19/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//


// Grab Data from Google API
// Save data to Business Object

import Foundation
import UIKit
import SwiftyJSON

struct debugPrint{
    static var RAW_GOOGLE_JSON = false
    static var RAW_JSON = false
    static var BUSINESS_ARRAY = false
    static var GRAND_BUSINESS_ARRAY = false
}

class APIDataHandler {
    
    // DEBUG OPTIONS
    let PRINT_JSON = true
    
    var gpClient = GooglePlacesAPIClient()
    
    func performAPISearch(_ googleParameters: Dictionary<String, String>, completion:@escaping (_ businessObjectArray: [Business]) -> Void) {
        
        gpClient.searchPlacesWithParameters(googleParameters) { (result) -> Void in
            self.parseGPlacesJSON(result, completion: { (businessArray) -> Void in
                completion(businessObjectArray: businessArray)
            })
        }
        
    }
    
    func performDetailedSearch(_ googleID: String, completion: @escaping (_ detailedGPlace: GooglePlaceDetail) -> Void){
        self.gpClient.searchPlaceWithID(googleID) { (JSONdata) in
            self.parseGoogleDetailedData(JSONdata, completion: { (detailedGPlace) in
                completion(detailedGPlace: detailedGPlace)
            })
        }
    }
    

    // Detailed Search
    func parseGoogleDetailedData(_ data: Data, completion: (_ detailedGPlace: GooglePlaceDetail) -> Void){
        let json = JSON(data: data)
        if json.count > 0 {
            if let place = json["result"].dictionary{
                if place.count > 0{
                    
                    var DetailedObject = GooglePlaceDetail()
                    
                    if let name = place["name"]?.string{
                        DetailedObject.name = name
                    }
                    
                    
                
                    if let open_now = place["opening_hours"]?["open_now"].bool{
                        DetailedObject.status = open_now
                    }
                    
                    if let coordinates = place["geometry"]?["location"].dictionary{
                        if let lat = coordinates["lat"]?.double{
                            DetailedObject.latitude = lat
                        }
                        if let lng = coordinates["lng"]?.double{
                            DetailedObject.longitude  = lng
                        }
                    }
                    
                    if let address = place["address_components"]?.array{
                    }
                    
                    if let formattedAddress = place["formatted_address"]?.string{
                        DetailedObject.address = formattedAddress
                    }
                    if let phone = place["formatted_phone_number"]?.string{
                        DetailedObject.phone = phone
                    }
                    if let intlPhone = place["international_phone_number"]?.string{
                        
                    }
                    
                    if let dayArray = place["opening_hours"]?["weekday_text"].array{
                        for day in dayArray{
                            if let hours = day.string{
                                DetailedObject.hours.addObject(hours)
                            }
                        }
                    }
                    
                    if let photoArray = place["photos"]?.array{
                        for photoDict in photoArray{
                            if let ref = photoDict["photo_reference"].string{
                                DetailedObject.photos.addObject(ref)
                            }
                        }
                    }
                    
                    if let placePrice = place["price_level"]?.int{
                        DetailedObject.priceRating = placePrice
                    }
                    
                    if let rating = place["rating"]?.double{
                        DetailedObject.rating = rating
                    }
                    
                    if let reviewArray = place["reviews"]?.array{
                        for review in reviewArray{
                            if let reviewDict = review.dictionary{
                                
                                var resultDict = NSMutableDictionary()
                                if let time = reviewDict["time"]?.int{
                                    resultDict["time"] = time
                                }
                                if let text = reviewDict["text"]?.string{
                                    resultDict["text"] = text
                                }
                                if let author = reviewDict["author_name"]?.string{
                                    resultDict["author_name"] = author
                                }
                                if let author_url = reviewDict["author_url"]?.string{
                                    resultDict["author_url"] = author_url
                                }
                                if let profile_photo = reviewDict["profile_photo_url"]?.string{
                                    resultDict["profile_photo"] = profile_photo
                                }
                                if let rating = reviewDict["rating"]?.double{
                                    resultDict["rating"] = rating
                                }
                                DetailedObject.reviews.addObject(resultDict)
                            }
                        }
                    }
                    
                    if let types = place["types"]?.array{
                        for type in types{
                            if let t = type.string{
                                DetailedObject.types.addObject(t)
                            }
                        }
                    }
                    
                    if let website = place["url"]?.string{
                        DetailedObject.website = website
                    }
                    
                    completion(DetailedObject)
                }
            }
        
        }
    
    }
    


    // Regular Search
    func parseGPlacesJSON(_ data: Data, completion: (_ businessArray: [Business]) -> Void){
        let json = JSON(data: data)
        if let places = json["results"].array{
            if places.count > 0{
                
                var arrayOfBusinesses: [Business] = []
                
                for place in places{
                    var businessObject = Business()
                    
                    if let id = place["place_id"].string{
                        businessObject.gPlaceID = id
                    }
                    if let name = place["name"].string{
                        businessObject.businessName = name
                    }
                    if let address = place["vicinity"].string{
                        businessObject.businessAddress = address
                    }
                    if let photoRef = place["photos"][0]["photo_reference"].string{
                        businessObject.businessPhotoReference = photoRef
                    }
                    if let rating = place["rating"].double{
                        businessObject.businessRating = rating
                    }
                    
                    if let placeLocation = place["geometry"]["location"].dictionary{
                        if let placeLat = placeLocation["lat"]!.double{
                            businessObject.businessLatitude = placeLat
                        }
                        if let placeLng = placeLocation["lng"]!.double{
                            businessObject.businessLongitude = placeLng
                        }
                    }
                    
                    if let types = place["types"].array{
                        for type in types{
                            if let t = type.string{
                                businessObject.businessTypes.addObject(t)
                            }
                        }
                    }
                    
                    if let status = place["opening_hours"]["open_now"].bool{
                        businessObject.businessStatus = status
                    }
                    
                    arrayOfBusinesses.append(businessObject)
                }
                
                completion(arrayOfBusinesses)
            }
        }
    }
  }
