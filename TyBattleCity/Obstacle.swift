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
        body.position = SCNVector3(x: 0, y: Float((body.geometry as! SCNBox).height / 2), z: 0)
        self.body = body
        super.init()
        addChildNode(body)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
