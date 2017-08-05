//
//  GameMap.swift
//  TyBattleCity
//
//  Created by luckytianyiyan on 2017/8/4.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import Foundation
import Yams
import SceneKit

extension int2 {
    static func point(_ dic: [String: Int]) -> int2 {
        return int2(x: Int32(dic["x"] ?? 0), y: Int32(dic["y"] ?? 0))
    }
    
    static func size(_ dic: [String: Int]) -> int2 {
        return int2(x: Int32(dic["width"] ?? 0), y: Int32(dic["height"] ?? 0))
    }
}

class GameMap {
    var mapSize: int2 = int2()
    var startLocation: int2 = int2()
    var obstacles: [Obstacle] = []
    let node: SCNNode
    let floor: SCNNode
    
    init() {
        guard let scene = SCNScene(named: "game.scn"),
            let world = scene.rootNode.childNode(withName: "world", recursively: false),
            let floor = world.childNode(withName: "floor", recursively: true) else {
            fatalError("can not int map")
        }
        self.node = world
        self.floor = floor
    }
    
    func load(yaml file: String) {
        guard let content = try? String(contentsOfFile: file, encoding: .utf8),
            let yml = (try? Yams.load(yaml: content)) as? [String: Any],
            let size = yml["size"] as? [String: Int],
            let start = yml["start"] as? [String: Int],
            let datas = yml["datas"] as? String else {
                fatalError("can not be load map")
        }
        mapSize = int2.size(size)
        startLocation = int2.point(start)
        
        (floor.geometry as! SCNFloor).width = CGFloat(mapSize.x / 2)
        (floor.geometry as! SCNFloor).length = CGFloat(mapSize.y / 2)
        
        for (idx, data) in datas.characters.enumerated() {
            guard let typeRaw = Int(String(data)), typeRaw != 0, let type = ObstacleType(rawValue: typeRaw) else {
                continue
            }
            let obstacle = Obstacle(type: type)
            let x = idx % Int(mapSize.x)
            let y = Int(idx / Int(mapSize.y))
            obstacle.position = SCNVector3(x: Float(x), y: 0, z: Float(y))
            obstacles.append(obstacle)
            node.addChildNode(obstacle)
        }
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 15)
        cameraNode.look(at: SCNVector3())
        node.addChildNode(cameraNode)
    }
    
    func placePlayer(_ player: Tank) {
        player.removeFromParentNode()
        node.addChildNode(player)
        player.position = SCNVector3(x: Float(startLocation.x), y: 0, z: Float(startLocation.y))
        floor.pivot = SCNMatrix4MakeTranslation((Float(-mapSize.x) + 1) / 2, 0, (Float(-mapSize.y) + 1) / 2)
        floor.position = SCNVector3()
    }
    
    func isPassable(_ next: SCNVector3) -> Bool {
        guard (0..<mapSize.x).contains(Int32(next.x)), (0..<mapSize.y).contains(Int32(next.z)) else {
            return false
        }
        
        return !obstacles.contains(where: { SCNVector3EqualToVector3($0.position, next) })
    }
}

