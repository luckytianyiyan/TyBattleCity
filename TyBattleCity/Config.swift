//
//  Config.swift
//  TyBattleCity
//
//  Created by luckytianyiyan on 2017/8/12.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import Foundation

struct Config {
    static let debug: Bool = false
    
    struct FiringRate {
        static let player: TimeInterval = 0.5
        static let enemy: TimeInterval = 0.5
        static let tank: TimeInterval = 0.5
    }
    static let bulletSpeed: CGFloat = 8
    static let tankFiringRange: CGFloat = 100.0
}

