//
//  GameController.swift
//  TyBattleCity
//
//  Created by luckytianyiyan on 2017/8/4.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import SceneKit

struct CollisionMask : OptionSet {
    let rawValue: Int
    
    static let obstacles  = CollisionMask(rawValue: 1 << 0)
    static let tank = CollisionMask(rawValue: 1 << 1)
    static let bullet  = CollisionMask(rawValue: 1 << 2)
}

class GameController: NSObject {
    static let shared = GameController()
    var player: Tank = Tank()
    var map: GameMap = GameMap()
    private var timer: Timer?
    private var bullets: [Bullet] = []
    
    private override init() {
        super.init()
    }
    
    func trun(to direction: Direction) {
        player.trun(to: direction)
    }
    
    func fire() {
        let bullet = player.fire { [weak self] (bullet) in
            self?.remove(bullet: bullet)
        }
        bullets.append(bullet)
    }
    
    func prepare(partName: String) {
        guard let filepath = Bundle.main.path(forResource: partName, ofType: "yml") else {
            fatalError("can not load map")
        }
        map.load(yaml: filepath)
        map.placePlayer(GameController.shared.player)
        player.firingRange = CGFloat(map.mapSize.x * 2 + 10)
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
    
    func remove(bullet: Bullet) {
        if let idx = bullets.index(of: bullet) {
            bullets.remove(at: idx)
        }
        bullet.removeFromParentNode()
    }
}

extension GameController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        guard let maskA = nodeA.physicsBody?.categoryBitMask, let maskB = nodeB.physicsBody?.categoryBitMask else {
            return
        }
        if (maskA | maskB) == (CollisionMask.bullet.rawValue | CollisionMask.obstacles.rawValue) {
            var obstacle: Obstacle
            var bullet: Bullet
            if nodeA.categoryBitMask == CollisionMask.obstacles.rawValue {
                obstacle = nodeA as! Obstacle
                bullet = nodeB as! Bullet
            } else {
                obstacle = nodeB as! Obstacle
                bullet = nodeA as! Bullet
            }
            remove(bullet: bullet)
            if obstacle.type == .brick {
                map.remove(obstacle: obstacle)
            }
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
        
    }
}
