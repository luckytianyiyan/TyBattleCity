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
        return offset(unit: CGPoint(x: 0.5, y: 0.5))
    }
    
    func offset(unit: CGPoint) -> CGPoint {
        switch self {
        case .up:
            return CGPoint(x: 0, y: -unit.y)
        case .right:
            return CGPoint(x: unit.x, y: 0)
        case .down:
            return CGPoint(x: 0, y: unit.y)
        case .left:
            return CGPoint(x: -unit.x, y: 0)
        }
    }
}

class Bullet: SCNNode {
    var body: SCNNode
    init(scale: Float = 1) {
        let scene = SCNScene(named: "Assets.scnassets/tank.scn")!
        body = scene.rootNode.childNode(withName: "bullet", recursively: true)!
        super.init()
        body.position = SCNVector3()
        addChildNode(body)
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: SCNSphere(radius: CGFloat(0.05 * scale)), options: nil))
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
    
    enum State: Int {
        case normal
        case moving
        case correcting
    }
    
    var body: SCNNode
    var launchingPoint: SCNNode
    var firingRange: CGFloat = 100.0
    var firingRate: CGFloat = 0.2
    var movingSpeed: Float = 2.5
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
    var state: Tank.State = .normal
    private var dstLocation: CGPoint?
    var nextLocation: CGPoint {
        let offset = direction.offset
        let location = dstLocation ?? CGPoint(x: CGFloat(position.x), y: CGFloat(position.z))
        return CGPoint(x: location.x + offset.x, y: location.y + offset.y)
    }
    
    override init() {
        let scene = SCNScene(named: "Assets.scnassets/tank.scn")!
        body = scene.rootNode.childNode(withName: "tank", recursively: true)!
        launchingPoint = scene.rootNode.childNode(withName: "launching_point", recursively: true)!
        super.init()
        body.position = SCNVector3()
        addChildNode(body)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func trun(to direction: Direction) {
        guard self.direction != direction else {
            return
        }
        self.direction = direction
        print("trun to \(direction)")
    }
    
    func fire(completion: ((_ bullet: Bullet) -> Void)?) -> Bullet? {
        guard let parent = parent else {
            return nil
        }
        let bullet = Bullet(scale: GameController.shared.mapScale)
        let offset = direction.offset
        bullet.position = convertPosition(launchingPoint.position, to: parent)
        parent.addChildNode(bullet)
        let distanceX = offset.x * firingRange
        let distanceY = offset.y * firingRange
        let distance = sqrt(distanceX * distanceX + distanceY * distanceY)
        bullet.runAction(SCNAction.moveBy(x: distanceX, y: 0, z: distanceY, duration: TimeInterval(firingRate * distance))) {
            completion?(bullet)
        }
        return bullet
    }
}

