//
//  Constant.swift
//  AppleReserver
//
//  Created by Sunnyyoung on 2017/9/19.
//  Copyright © 2017年 Sunnyyoung. All rights reserved.
//

import Foundation

public struct AppleURL {///iphone-xs
    //URL    https://reserve-prime.apple.com/CN/zh_CN/reserve/iPhone/availability.json
    // URL    https://reserve-prime.apple.com/CN/zh_CN/reserve/iPhone/stores.json
    static let stores = URL(string: "https://reserve-prime.apple.com/CN/zh_CN/reserve/iPhone/stores.json")!
    static let availability = URL(string: "https://reserve-prime.apple.com/CN/zh_CN/reserve/iPhone/availability.json")!
}
