//
//  ControlViewController.swift
//  TyBattleCity
//
//  Created by luckytianyiyan on 2017/8/4.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import UIKit

class ControlViewController: UIViewController {
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    var continuedControlTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        leftButton.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        rightButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        downButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
    }
    
    @IBAction func down(_ sender: UIButton) {
        var direction: Direction = .up
        if sender == upButton {
            direction = .up
        } else if sender == downButton {
            direction = .down
        } else if sender == leftButton {
            direction = .left
        } else if sender == rightButton {
            direction = .right
        } else {
            return
        }
        GameController.shared.moving(direction: direction)
        continuedControlTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
            GameController.shared.moving(direction: direction)
        })
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        continuedControlTimer?.invalidate()
        continuedControlTimer = nil
        GameController.shared.stopMoving()
    }
    
    @IBAction func fire(_ sender: Any) {
        GameController.shared.fire()
    }
}
