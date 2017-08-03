//
//  Tank.swift
//  TyBattleCity
//
//  Created by luckytianyiyan on 2017/8/3.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import SceneKit

enum Direction: Int {
    case up
    case right
    case down
    case left
    
    var offset: int2 {
        switch self {
        case .up:
            return int2(x: 0, y: -1)
        case .right:
            return int2(x: 1, y: 0)
        case .down:
            return int2(x: 0, y: 1)
        case .left:
            return int2(x: -1, y: 0)
        }
    }
}

class Tank: SCNNode {
    var body: SCNNode
    var direction: Direction = .down {
        didSet {
            switch direction {
            case .right:
                eulerAngles.y = Float.pi / 2
            case .left:
                eulerAngles.y = -Float.pi / 2
            case .up:
                eulerAngles.y = -Float.pi
            case .down:
                eulerAngles.y = 0
            }
        }
    }
    
    override init() {
        let scene = SCNScene(named: "tank.scn")!
        body = scene.rootNode.childNode(withName: "tank", recursively: true)!
        super.init()
        addChildNode(body)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func trun(to direction: Direction) {
        guard abs(direction.rawValue - self.direction.rawValue) != 2 else {
            return
        }
        self.direction = direction
        print("trun to \(direction)")
    }
    
    func move() {
        let offset = direction.offset
        runAction(SCNAction.moveBy(x: CGFloat(offset.x), y: 0, z: CGFloat(offset.y), duration: 0.5))
    }
}

