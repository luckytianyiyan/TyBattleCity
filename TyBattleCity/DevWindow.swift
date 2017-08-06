//
//  DevWindow.swift
//  TyBattleCity
//
//  Created by luckytianyiyan on 2017/8/4.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import UIKit

class DevWindow: UIWindow {
    override var keyCommands: [UIKeyCommand]? {
        let upAction = #selector(up)
        let downAction = #selector(down)
        let leftAction = #selector(left)
        let rightAction = #selector(right)
        return [UIKeyCommand(input: "w", modifierFlags: [], action: upAction),
                UIKeyCommand(input: "s", modifierFlags: [], action: downAction),
                UIKeyCommand(input: "a", modifierFlags: [], action: leftAction),
                UIKeyCommand(input: "d", modifierFlags: [], action: rightAction),
                UIKeyCommand(input: "j", modifierFlags: [], action: #selector(fire)),
                UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags: [], action: upAction),
                UIKeyCommand(input: UIKeyInputDownArrow, modifierFlags: [], action: downAction),
                UIKeyCommand(input: UIKeyInputLeftArrow, modifierFlags: [], action: leftAction),
                UIKeyCommand(input: UIKeyInputRightArrow, modifierFlags: [], action: rightAction)]
    }
    
    @objc func up() {
        GameController.shared.trun(to: .up)
    }
    
    @objc func down() {
        GameController.shared.trun(to: .down)
    }
    
    @objc func left() {
        GameController.shared.trun(to: .left)
    }
    
    @objc func right() {
        GameController.shared.trun(to: .right)
    }
    
    @objc func fire() {
        GameController.shared.fire()
    }
}
