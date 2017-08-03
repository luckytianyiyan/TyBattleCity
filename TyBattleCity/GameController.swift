//
//  GameController.swift
//  TyBattleCity
//
//  Created by luckytianyiyan on 2017/8/4.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import Foundation

class GameController {
    static let shared = GameController()
    var player: Tank = Tank()
    private init() {
        
    }
    
    func trun(to direction: Direction) {
        player.trun(to: direction)
    }
}
