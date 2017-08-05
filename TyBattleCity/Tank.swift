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
    
    var offset: CGPoint {
        switch self {
        case .up:
            return CGPoint(x: 0, y: -0.5)
        case .right:
            return CGPoint(x: 0.5, y: 0)
        case .down:
            return CGPoint(x: 0, y: 0.5)
        case .left:
            return CGPoint(x: -0.5, y: 0)
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
    private var dstLocation: CGPoint?
    var nextLocation: CGPoint {
        let offset = direction.offset
        let location = dstLocation ?? CGPoint(x: CGFloat(position.x), y: CGFloat(position.z))
        return CGPoint(x: location.x + offset.x, y: location.y + offset.y)
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
        let next = nextLocation
        dstLocation = next
        runAction(SCNAction.move(to: SCNVector3(x: Float(next.x), y: 0, z: Float(next.y)), duration: 0.2), forKey: nil) {
            print("moved to \(self.position)")
        }
    }
}

