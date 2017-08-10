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
    var movingSpace: CGFloat = 3
    private var bullets: [Bullet] = []
    var displayLink: CADisplayLink?
    var mapScale: Float = 1 {
        didSet {
            map.scale = SCNVector3(x: mapScale, y: mapScale, z: mapScale)
            for item in map.obstacles {
                item.updatePhysicsBody(scale: CGFloat(mapScale))
            }
        }
    }
    
    private override init() {
        super.init()
        displayLink = CADisplayLink(target: self, selector: #selector(tankMovement))
        displayLink?.add(to: RunLoop.current, forMode: .commonModes)
    }
    
    func moving(direction: Direction) {
        guard player.state == .normal || player.state == .moving else {
            return
        }
        player.trun(to: direction)
        player.state = .moving
    }
    
    func stopMoving() {
        guard player.state == .moving else {
            return
        }
        player.state = .correcting
        let mapPosition = float2(x: player.position.x, y: player.position.z)
        let remainderX = mapPosition.x.truncatingRemainder(dividingBy: 0.5)
        let remainderY = mapPosition.y.truncatingRemainder(dividingBy: 0.5)
        let floorX = floor(mapPosition.x / 0.5) * 0.5
        let floorY = floor(mapPosition.y / 0.5) * 0.5
        var dstX: Float = player.position.x
        var dstY: Float = player.position.z
        switch player.direction {
        case .up:
            dstY = floorY
            break
        case .down:
            dstY = abs(remainderY) > 0 ? floorY + 0.5 : player.position.z
            break
        case .left:
            dstX = floorX
            break
        case .right:
            dstX = abs(remainderX) > 0 ? floorX + 0.5 : player.position.x
            break
        }
        if dstX == player.position.x, dstY == player.position.z {
            player.state = .normal
            return
        }
        
        let dst = SCNVector3(x: dstX, y: player.position.y, z: dstY)
        guard map.isPassable(dst) else {
            player.state = .normal
            return
        }
        let distanceX = abs(dst.x - player.position.x)
        let distanceY = abs(dst.z - player.position.z)
        let distance = sqrt(distanceX * distanceX + distanceY * distanceY)
        let duration = TimeInterval(distance / player.movingSpeed)
//        print("correcting: \(player.position) to \(dst), duration: \(duration)")
        player.runAction(SCNAction.move(to: dst, duration: duration), forKey: "correcting") {
            self.player.state = .normal
        }
    }
    
    func fire() {
        let completion: (Bullet) -> Void = { [weak self] (bullet) in
            self?.remove(bullet: bullet)
        }
        guard let bullet = player.fire(completion: completion) else {
            return
        }
        bullets.append(bullet)
    }
    
    func resetPhysicsBodyTransform() {
        for obstacle in map.obstacles {
            obstacle.physicsBody?.resetTransform()
        }
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
        
        
    }
    
    func endGame() {
        
    }
    
    func remove(bullet: Bullet) {
        if let idx = bullets.index(of: bullet) {
            bullets.remove(at: idx)
        }
        bullet.removeFromParentNode()
    }
    
    @objc func tankMovement() {
        guard player.state == .moving else {
            return
        }
        let offset = player.direction.offset
        let step = movingSpace / 60 / 0.5
        let next = player.position + SCNVector3(x: Float(offset.x * step), y: 0, z: Float(offset.y * step))
        guard map.isPassable(next) else {
            return
        }
        player.position = next
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
