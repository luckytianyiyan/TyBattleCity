//
//  GameMap.swift
//  TyBattleCity
//
//  Created by luckytianyiyan on 2017/8/4.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import Foundation
import SceneKit

extension int2 {
    static func point(_ dic: [String: Int]) -> int2 {
        return int2(x: Int32(dic["x"] ?? 0), y: Int32(dic["y"] ?? 0))
    }
    
    static func size(_ dic: [String: Int]) -> int2 {
        return int2(x: Int32(dic["width"] ?? 0), y: Int32(dic["height"] ?? 0))
    }
}

class GameMap: SCNNode {
    var mapSize: int2 = int2()
    var obstacles: [Obstacle] = []
    private(set) var origin: float2 = float2(0.5, 0.5)
    private let world: SCNNode
    private let floor: SCNNode
    
    override init() {
        guard let scene = SCNScene(named: "Assets.scnassets/game.scn"),
            let world = scene.rootNode.childNode(withName: "world", recursively: false),
            let floor = world.childNode(withName: "floor", recursively: true) else {
            fatalError("can not int map")
        }
        self.world = world
        self.floor = floor
        let floorGeometry = floor.geometry as! SCNBox
        origin = float2(x: 0.5 - floorGeometry.width / 2, y: 0.5 - floorGeometry.length / 2)
        super.init()
        world.position = SCNVector3()
        addChildNode(world)
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 15)
        cameraNode.look(at: SCNVector3())
        world.addChildNode(cameraNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load(mapSize: int2, datas: String) {
        // clear
        for obstacle in obstacles {
            obstacle.removeFromParentNode()
        }
        obstacles.removeAll()
        
        // load
        self.mapSize = mapSize
        let floorGeometry = floor.geometry as! SCNBox
        floorGeometry.width = CGFloat(mapSize.x)
        floorGeometry.length = CGFloat(mapSize.y)
        floorGeometry.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(Float(mapSize.x), Float(mapSize.x), 0)
        origin = float2(x: 0.5 - floorGeometry.width / 2, y: 0.5 - floorGeometry.length / 2)
        
        for (idx, data) in datas.characters.enumerated() {
            guard let typeRaw = Int(String(data)), typeRaw != 0, let type = ObstacleType(rawValue: typeRaw) else {
                continue
            }
            let obstacle = Obstacle(type: type)
            let x = idx % Int(mapSize.x)
            let y = Int(idx / Int(mapSize.y))
            obstacle.position = SCNVector3(x: origin.x + Float(x), y: 0, z: origin.y + Float(y))
            obstacles.append(obstacle)
            world.addChildNode(obstacle)
        }
    }
    
    func place(tank: Tank, position: CGPoint) {
        tank.removeFromParentNode()
        world.addChildNode(tank)
        tank.position = SCNVector3(x: origin.x + Float(position.x), y: 0, z: origin.y + Float(position.y))
    }
    
    func remove(obstacle: Obstacle) {
        if let idx = obstacles.index(of: obstacle) {
            obstacles.remove(at: idx)
        }
        obstacle.removeFromParentNode()
    }
    
    func isPassable(_ next: SCNVector3) -> Bool {
        guard next.x >= origin.x, next.x <= origin.x + Float(mapSize.x - 1), next.z >= origin.y, next.z <= origin.y + Float(mapSize.y - 1) else {
            return false
        }
        return !obstacles.contains(where: {
            let position = $0.position
            let distanceX = abs(next.x - position.x)
            let distanceY = abs(next.z - position.z)
            if (distanceX < 1), (distanceY < 1) {
                return true
            }
            return false
        })
    }
}

extension GameMap: AStarDelegate {
    func coat(from lhs: CGPoint, to rhs: CGPoint) -> Int {
        return 1
    }
    
    func isPassable(_ position: CGPoint) -> Bool {
        return isPassable(SCNVector3(x: Float(position.x), y: 0, z: Float(position.y)))
    }
}

