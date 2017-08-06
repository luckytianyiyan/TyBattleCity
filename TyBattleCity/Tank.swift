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

class Bullet: SCNNode {
    var body: SCNNode
    override init() {
        let scene = SCNScene(named: "tank.scn")!
        body = scene.rootNode.childNode(withName: "bullet", recursively: true)!
        super.init()
        body.position = SCNVector3()
        addChildNode(body)
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        physicsBody.mass = 0
        physicsBody.categoryBitMask = CollisionMask.bullet.rawValue
        physicsBody.collisionBitMask = CollisionMask.bullet.rawValue | CollisionMask.obstacles.rawValue | CollisionMask.tank.rawValue
        physicsBody.contactTestBitMask = CollisionMask.bullet.rawValue | CollisionMask.obstacles.rawValue | CollisionMask.tank.rawValue
        self.physicsBody = physicsBody
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Tank: SCNNode {
    var body: SCNNode
    var launchingPoint: SCNNode
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
        launchingPoint = scene.rootNode.childNode(withName: "launching_point", recursively: true)!
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
    
    func fire() -> Bullet {
        let bullet = Bullet()
        let offset = direction.offset
        bullet.position = position + launchingPoint.position
        parent?.addChildNode(bullet)
        bullet.runAction(SCNAction.moveBy(x: offset.x * 100, y: 0, z: offset.y * 100, duration: 10))
        return bullet
    }
}

extension SCNVector3 {
    static func +(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        return SCNVector3(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
}
