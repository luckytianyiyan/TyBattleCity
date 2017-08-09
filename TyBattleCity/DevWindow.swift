//
//  DevWindow.swift
//  TyBattleCity
//
//  Created by luckytianyiyan on 2017/8/4.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import UIKit

class DevWindow: BaseDeveloperWindow {
    
    var keyMap: [String: Selector] = [:]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        keyCommandDelegate = self
        
        let upAction = #selector(up(isKeyDown:))
        let downAction = #selector(down(isKeyDown:))
        let leftAction = #selector(left(isKeyDown:))
        let rightAction = #selector(right(isKeyDown:))
        keyMap["w"] = upAction
        keyMap["s"] = downAction
        keyMap["a"] = leftAction
        keyMap["d"] = rightAction
        keyMap["j"] = #selector(fire(isKeyDown:))
        keyMap[UIKeyInputUpArrow] = upAction
        keyMap[UIKeyInputDownArrow] = downAction
        keyMap[UIKeyInputLeftArrow] = leftAction
        keyMap[UIKeyInputRightArrow] = rightAction
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var keyCommands: [UIKeyCommand]? {
        let temp = #selector(unusedTemp)
        return [UIKeyCommand(input: "w", modifierFlags: [], action: temp),
                UIKeyCommand(input: "s", modifierFlags: [], action: temp),
                UIKeyCommand(input: "a", modifierFlags: [], action: temp),
                UIKeyCommand(input: "d", modifierFlags: [], action: temp),
                UIKeyCommand(input: "j", modifierFlags: [], action: temp),
                UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags: [], action: temp),
                UIKeyCommand(input: UIKeyInputDownArrow, modifierFlags: [], action: temp),
                UIKeyCommand(input: UIKeyInputLeftArrow, modifierFlags: [], action: temp),
                UIKeyCommand(input: UIKeyInputRightArrow, modifierFlags: [], action: temp)]
    }
    
    @objc func unusedTemp() {
    }
    
    @objc func up(isKeyDown: NSNumber) {
        controlMoving(isMoving: isKeyDown.boolValue, direction: .up)
    }
    
    @objc func down(isKeyDown: NSNumber) {
        controlMoving(isMoving: isKeyDown.boolValue, direction: .down)
    }
    
    @objc func left(isKeyDown: NSNumber) {
        controlMoving(isMoving: isKeyDown.boolValue, direction: .left)
    }
    
    @objc func right(isKeyDown: NSNumber) {
        controlMoving(isMoving: isKeyDown.boolValue, direction: .right)
    }
    
    @objc func fire(isKeyDown: NSNumber) {
        GameController.shared.fire()
    }
    
    // MARK: Helper
    
    func controlMoving(isMoving: Bool, direction: Direction) {
        if isMoving {
            GameController.shared.moving(direction: direction)
        } else {
            GameController.shared.stopMoving()
        }
    }
}

extension DevWindow: BaseDeveloperKeyCommandDelegate {
    func keyUp(_ keyCode: String!, command: UIKeyCommand!) {
        guard command.modifierFlags.isEmpty, let input = command.input, let sel = keyMap[input] else {
            return
        }
        perform(sel, with: NSNumber(booleanLiteral: false))
    }
    
    func keyDown(_ keyCode: String!, command: UIKeyCommand!) {
        guard command.modifierFlags.isEmpty, let input = command.input, let sel = keyMap[input] else {
            return
        }
        perform(sel, with: NSNumber(booleanLiteral: true))
    }
}

