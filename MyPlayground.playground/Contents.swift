//: Playground - noun: a place where people can play

import UIKit


var phoneString = "(408) 332-6980"
var phoneArray = phoneString.characters.map { String($0) }
var result = ""

for char in phoneArray{
    if Int(char) != nil{
        result += char
    }
}

print(Int(result)!)