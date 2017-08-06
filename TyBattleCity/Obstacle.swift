//
//  Obstacle.swift
//  TyBattleCity
//
//  Created by luckytianyiyan on 2017/8/4.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import SceneKit

enum ObstacleType: Int {
    case wall = 1
    case brick = 2
    
    var identifier: String {
        switch self {
        case .wall:
            return "wall"
        case .brick:
            return "brick"
        }
    }
}

class Obstacle: SCNNode {
    var body: SCNNode
    private(set) var type: ObstacleType
    
    init(type: ObstacleType) {
        self.type = type
        let scene = SCNScene(named: "obstacle.scnassets/obstacle.scn")!
        guard let body = scene.rootNode.childNode(withName: type.identifier, recursively: true) else {
            fatalError("can not load Brick")
        }
        self.body = body
        super.init()
        body.position = SCNVector3()
        addChildNode(body)
        updatePhysicsBody(scale: 1)
    }
    
    func updatePhysicsBody(scale: CGFloat) {
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: SCNBox(width: 1 * scale, height: 1 * scale, length: 1 * scale, chamferRadius: 0), options: nil))
        physicsBody.mass = 0
        physicsBody.categoryBitMask = CollisionMask.obstacles.rawValue
        physicsBody.collisionBitMask = CollisionMask.bullet.rawValue | CollisionMask.tank.rawValue
        physicsBody.contactTestBitMask = CollisionMask.bullet.rawValue | CollisionMask.tank.rawValue
        self.physicsBody = physicsBody
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
