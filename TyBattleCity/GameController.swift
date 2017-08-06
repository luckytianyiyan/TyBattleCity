//
//  GameController.swift
//  TyBattleCity
//
//  Created by luckytianyiyan on 2017/8/4.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import SceneKit

enum CollisionMask: Int {
    case obstacles = 1 // 0x1 << 0
    case tank = 2 // 0x1 << 1
    case bullet = 4 // 0x1 << 2
}

class GameController: NSObject {
    static let shared = GameController()
    var player: Tank = Tank()
    var map: GameMap = GameMap()
    private var timer: Timer?
    private override init() {
        super.init()
    }
    
    func trun(to direction: Direction) {
        player.trun(to: direction)
    }
    
    func fire() {
        let bullet = player.fire()
    }
    
    func prepare(partName: String) {
        guard let filepath = Bundle.main.path(forResource: partName, ofType: "yml") else {
            fatalError("can not load map")
        }
        map.load(yaml: filepath)
        map.placePlayer(GameController.shared.player)
    }
    
    func startGame() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (_) in
            let next = self.player.nextLocation
            guard self.map.isPassable(SCNVector3(x: Float(next.x), y: 0, z: Float(next.y))) else {
                return
            }
            self.player.move()
        })
    }
    
    func endGame() {
        timer?.invalidate()
    }
}

extension GameController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("didBegin")
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
        
    }
}
