//
//  Publishers.swift
//  Yelpify
//
//  Created by Kay Lab on 3/7/16.
//  Copyright © 2016 Yelpify. All rights reserved.
//

import UIKit

class Publishers{
    private var publishers = [Publisher]()
    private var sections = [String]()
    
    //Mark - Public
    
    var numberOfPublishers: Int{
        return publishers.count
    }
    
    var numberOfSections:Int{
        return sections.count
    }
    
    init(){
        publishers = createPublishers()
        immutablePublishers = publishers
        sections = ["My Favorites", "Happy", "Night", "Day", "Fast Food"]
    }
    
    func deleteItemsAtIndexPaths(indexPaths: [NSIndexPath]){
        var indexes = [Int]()
        for indexPath in indexPaths{
            indexes.append(absoluteIndexForIndexPath(indexPath))
        }
        var newPublishers = [Publisher]()
        for (index, publisher) in publishers.enumerate(){
            if !indexes.contains(index){
                newPublishers.append(publisher)
            }
        }
    }
}

