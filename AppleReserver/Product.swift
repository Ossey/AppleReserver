//
//  Product.swift
//  AppleReserver
//
//  Created by Sunnyyoung on 2017/9/19.
//  Copyright © 2017年 Sunnyyoung. All rights reserved.
//

import Foundation

struct IPhonexsProduct {
    let capacity: String
    let partNumber: String
    let color: String
    let screenSize: String
    let price: String
    var description: String? {
        get {
            var des = "iPhone XS"
            if screenSize == "6_5inch" {
                 des += " Max"
            }
            switch self.color {
            case "silver":
                des += " 银色"
            case "space_gray":
                des += " 深空灰色"
            case "gold":
                des += " 金色"
            default: break
                
            }
           des += " \(capacity.uppercased())"
            return des
        }
    }
    
    init(partNumber: String, color: String, capacity: String, screenSize: String, price: String) {
        self.partNumber = partNumber
        self.color = color
        self.capacity = capacity
        self.screenSize = screenSize
        self.price = price
    }
    
    init?(json: [String: Any]) {
        guard let partNumber = json["partNumber"] as? String else { return nil }
        guard let color = json["color"] as? String else { return nil }
        guard let capacity = json["capacity"] as? String else { return nil }
        guard let screenSize = json["screenSize"] as? String else { return nil }
        guard let price = json["price"] as? String else { return nil }
        
        self.init(partNumber: partNumber, color: color, capacity: capacity, screenSize: screenSize, price: price)
    }
}

//struct Product {
//    let partNumber: String
//    let description: String
//    let color: String
//    let capacity: String
//    let screenSize: String
//    let price: String
//    let installmentPrice: String
//    let installmentPeriod: String
//    let iUPPrice: String
//    let iUPInstallments: String
//    let colorSortOrder: String
//    let swatchImage: URL
//    let image: URL
//    let contractEnabled: Bool
//    let unlockedEnabled: Bool
//    let groupID: String
//    let groupName: String
//    let subfamilyID: String
//    let subfamily: String
//
//    init(partNumber: String, description: String, color: String, capacity: String, screenSize: String, price: String, installmentPrice: String, installmentPeriod: String, iUPPrice: String, iUPInstallments: String, colorSortOrder: String, swatchImage: URL, image: URL, contractEnabled: Bool, unlockedEnabled: Bool, groupID: String, groupName: String, subfamilyID: String, subfamily: String) {
//        self.partNumber = partNumber
//        self.description = description
//        self.color = color
//        self.capacity = capacity
//        self.screenSize = screenSize
//        self.price = price
//        self.installmentPrice = installmentPrice
//        self.installmentPeriod = installmentPeriod
//        self.iUPPrice = iUPPrice
//        self.iUPInstallments = iUPInstallments
//        self.colorSortOrder = colorSortOrder
//        self.swatchImage = swatchImage
//        self.image = image
//        self.contractEnabled = contractEnabled
//        self.unlockedEnabled = unlockedEnabled
//        self.groupID = groupID
//        self.groupName = groupName
//        self.subfamilyID = subfamilyID
//        self.subfamily = subfamily
//    }
//
//    init?(json: [String: Any]) {
//        guard let partNumber = json["partNumber"] as? String else { return nil }
//        guard let description = json["description"] as? String else { return nil }
//        guard let color = json["color"] as? String else { return nil }
//        guard let capacity = json["capacity"] as? String else { return nil }
//        guard let screenSize = json["screenSize"] as? String else { return nil }
//        guard let price = json["price"] as? String else { return nil }
//        guard let installmentPrice = json["installmentPrice"] as? String else { return nil }
//        guard let installmentPeriod = json["installmentPeriod"] as? String else { return nil }
//        guard let iUPPrice = json["iUPPrice"] as? String else { return nil }
//        guard let iUPInstallments = json["iUPInstallments"] as? String else { return nil }
//        guard let colorSortOrder = json["colorSortOrder"] as? String else { return nil }
//        guard let swatchImageString = json["swatchImage"] as? String else { return nil }
//        guard let swatchImage = URL(string: swatchImageString) else { return nil }
//        guard let imageString = json["image"] as? String else { return nil }
//        guard let image = URL(string: imageString) else { return nil }
//        guard let contractEnabled = json["contractEnabled"] as? Bool else { return nil }
//        guard let unlockedEnabled = json["unlockedEnabled"] as? Bool else { return nil }
//        guard let groupID = json["groupID"] as? String else { return nil }
//        guard let groupName = json["groupName"] as? String else { return nil }
//        guard let subfamilyID = json["subfamilyID"] as? String else { return nil }
//        guard let subfamily = json["subfamily"] as? String else { return nil }
//        self.init(partNumber: partNumber, description: description, color: color, capacity: capacity, screenSize: screenSize, price: price, installmentPrice: installmentPrice, installmentPeriod: installmentPeriod, iUPPrice: iUPPrice, iUPInstallments: iUPInstallments, colorSortOrder: colorSortOrder, swatchImage: swatchImage, image: image, contractEnabled: contractEnabled, unlockedEnabled: unlockedEnabled, groupID: groupID, groupName: groupName, subfamilyID: subfamilyID, subfamily: subfamily)
//    }
//}


