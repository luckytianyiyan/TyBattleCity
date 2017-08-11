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
    
    static func direction(from src: CGPoint, to dst: CGPoint) -> Direction? {
        if dst.x > src.x {
            return .right
        } else if dst.x < src.x {
            return .left
        } else if dst.y > src.y {
            return .down
        } else if dst.y < src.y {
            return .up
        }
        return nil
    }
}

class Bullet: SCNNode {
    var body: SCNNode
    weak var owner: SCNNode?
    init(owner: SCNNode? = nil, scale: Float = 1) {
        let scene = SCNScene(named: "Assets.scnassets/tank.scn")!
        body = scene.rootNode.childNode(withName: "bullet", recursively: true)!
        super.init()
        self.owner = owner
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
    var bulletSpeed: CGFloat = 8
    var firingRate: TimeInterval = 0.5
    var movingSpeed: Float = 2.5
    var nearNextPosition: float2 {
        let mapPosition = float2(x: position.x, y: position.z)
        let remainderX = mapPosition.x.truncatingRemainder(dividingBy: 0.5)
        let remainderY = mapPosition.y.truncatingRemainder(dividingBy: 0.5)
        let floorX = floor(mapPosition.x / 0.5) * 0.5
        let floorY = floor(mapPosition.y / 0.5) * 0.5
        var dstX: Float = position.x
        var dstY: Float = position.z
        switch direction {
        case .up:
            dstY = floorY
            break
        case .down:
            dstY = abs(remainderY) > 0 ? floorY + 0.5 : position.z
            break
        case .left:
            dstX = floorX
            break
        case .right:
            dstX = abs(remainderX) > 0 ? floorX + 0.5 : position.x
            break
        }
        return float2(x: dstX, y: dstY)
    }
    var nearPosition: float2 {
        let mapPosition = float2(x: position.x, y: position.z)
        let floorX = floor(mapPosition.x / 0.5) * 0.5
        let floorY = floor(mapPosition.y / 0.5) * 0.5
        var dstX: Float = floorX
        var dstY: Float = floorY
        switch direction {
        case .down:
            let remainderY = mapPosition.y.truncatingRemainder(dividingBy: 0.5)
            dstY = abs(remainderY) > 0 ? floorY + 0.5 : position.z
            break
        case .right:
            let remainderX = mapPosition.x.truncatingRemainder(dividingBy: 0.5)
            dstX = abs(remainderX) > 0 ? floorX + 0.5 : position.x
            break
        default:
            break
        }
        return float2(x: dstX, y: dstY)
    }
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
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0), options: nil))
        physicsBody.mass = 0
        physicsBody.categoryBitMask = CollisionMask.tank.rawValue
        physicsBody.collisionBitMask = CollisionMask.bullet.rawValue
        physicsBody.contactTestBitMask = CollisionMask.bullet.rawValue
        self.physicsBody = physicsBody
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
        let bullet = Bullet(owner: self, scale: GameController.shared.mapScale)
        let offset = direction.offset
        bullet.position = convertPosition(launchingPoint.position, to: parent)
        parent.addChildNode(bullet)
        let distanceX = offset.x * firingRange
        let distanceY = offset.y * firingRange
        let distance = sqrt(distanceX * distanceX + distanceY * distanceY)
        bullet.runAction(SCNAction.moveBy(x: distanceX, y: 0, z: distanceY, duration: TimeInterval(distance / bulletSpeed))) {
            completion?(bullet)
        }
        return bullet
    }
}

class Player: Tank {
    var firingObstacleTimer: Timer?
    
    override func fire(completion: ((Bullet) -> Void)?) -> Bullet? {
        guard firingObstacleTimer == nil else {
            return nil
        }
        firingObstacleTimer = Timer.scheduledTimer(withTimeInterval: firingRate, repeats: false, block: {[weak self] _ in
            self?.firingObstacleTimer = nil
        })
        return super.fire(completion: completion)
    }
}

class Enemy: Tank {
    var firingTimer: Timer?
    func autoFiring(begin: ((Bullet) -> Void)?, completion: ((Bullet) -> Void)?) {
        firingTimer?.invalidate()
        firingTimer = Timer.scheduledTimer(withTimeInterval: firingRate, repeats: true, block: { _ in
            if let bullet = self.fire(completion: completion) {
                begin?(bullet)
            }
        })
    }
    
    func stopFiring() {
        firingTimer?.invalidate()
        firingTimer = nil
    }
}
