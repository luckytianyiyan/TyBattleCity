//
//  GameController.swift
//  TyBattleCity
//
//  Created by luckytianyiyan on 2017/8/4.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import SceneKit
import Yams

struct CollisionMask : OptionSet {
    let rawValue: Int
    
    static let obstacles  = CollisionMask(rawValue: 1 << 0)
    static let tank = CollisionMask(rawValue: 1 << 1)
    static let bullet  = CollisionMask(rawValue: 1 << 2)
}

class GameController: NSObject {
    static let shared = GameController()
    var part: Part?
    var player: Tank = Tank()
    var enemies: [Enemy] = []
    var map: GameMap = GameMap()
    var movingSpace: CGFloat = 3
    private var bullets: [Bullet] = []
    var displayLink: CADisplayLink?
    var aiTimer: Timer?
    var neededRunAI: Bool = false
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
    
    func resetPhysicsBodyTransform() {
        for obstacle in map.obstacles {
            obstacle.physicsBody?.resetTransform()
        }
    }
    
    func load(yaml file: String) {
        let part = Part(yaml: file)
        map.load(mapSize: part.mapSize, datas: part.mapDatas)
        
        map.place(tank: player, position: CGPoint(x: CGFloat(part.playerStartPosition.x), y: CGFloat(part.playerStartPosition.y)))
        
        for p in part.enemyPositions {
            let enemy = Enemy()
            map.place(tank: enemy, position: CGPoint(x: CGFloat(p.x), y: CGFloat(p.y)))
            enemies.append(enemy)
        }
        self.part = part
    }
    
    func prepare(partName: String) {
        guard let filepath = Bundle.main.path(forResource: partName, ofType: "yml") else {
            fatalError("can not load map")
        }
        load(yaml: filepath)
        player.firingRange = CGFloat(map.mapSize.x * 2 + 10)
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
        neededRunAI = true
    }
    
    // MARK: Game Control
    
    func startGame() {
        aiTimer?.invalidate()
        neededRunAI = true
        for enemy in enemies {
            let completion: (Bullet) -> Void = { [weak self] (bullet) in
                self?.remove(bullet: bullet)
            }
            enemy.autoFiring(begin: { [weak self] bullet in
                self?.bullets.append(bullet)
                }, completion: completion)
        }
        runAIfNeeded()
        aiTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (_) in
            self.runAIfNeeded()
        })
    }
    
    func endGame() {
        aiTimer?.invalidate()
        aiTimer = nil
        for enemy in enemies {
            enemy.stopFiring()
        }
        let alertController = UIAlertController(title: NSLocalizedString("game.over", comment: "game"), message: NSLocalizedString("game.over.killed", comment: "game"), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("game.restart", comment: "game"), style: .default, handler: { _ in
            self.startGame()
        }))
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
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
        let nearNextPosition = player.nearNextPosition
        if nearNextPosition.x == player.position.x, nearNextPosition.y == player.position.z {
            player.state = .normal
            return
        }
        
        let dst = SCNVector3(x: Float(nearNextPosition.x), y: player.position.y, z: Float(nearNextPosition.y))
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
    
    // MARK: Helper
    
    func clear() {
        for enemy in enemies {
            enemy.removeFromParentNode()
        }
        enemies.removeAll()
        
        for bullet in bullets {
            bullet.removeFromParentNode()
        }
        bullets.removeAll()
    }
    
    func remove(bullet: Bullet) {
        if let idx = bullets.index(of: bullet) {
            bullets.remove(at: idx)
        }
        DispatchQueue.main.async {
            bullet.removeFromParentNode()
        }
    }
    
    // MARK: AI
    func runAIfNeeded() {
        guard neededRunAI else {
            return
        }
        let aStar = AStar(stepDistance: 0.5)
        aStar.delegate = map
        for enemy in enemies {
            let enemyPosition = enemy.nearPosition
            let playerNextPosition = player.nearNextPosition
            let source = CGPoint(x: CGFloat(enemyPosition.x), y: CGFloat(enemyPosition.y))
            let dst = CGPoint(x: CGFloat(playerNextPosition.x), y: CGFloat(playerNextPosition.y))
            let paths = aStar.execute(from: source, to: dst)
            var actions: [SCNAction] = []
            var lastPosition = source
            for path in paths {
                let last = CGPoint(x: lastPosition.x, y: lastPosition.y)
                let action = SCNAction.run({ (node) in
                    guard let tank = node as? Tank else {
                        return
                    }
                    let direction: Direction = Direction.direction(from: last, to: path) ?? tank.direction
                    print("enemy from: \(last), to: \(path), trun to: \(direction)")
                    tank.trun(to: direction)
                })
                actions.append(action)
                let distanceX = abs(lastPosition.x - path.x)
                let distanceY = abs(lastPosition.y - path.y)
                let distance = sqrt(distanceX * distanceX + distanceY * distanceY)
                let duration = Float(distance) / enemy.movingSpeed
                let movementAction = SCNAction.move(to: SCNVector3(x: Float(path.x), y: 0, z: Float(path.y)), duration: TimeInterval(duration))
                actions.append(movementAction)
                lastPosition = path
            }
            print("Run API!!!")
            enemy.runAction(SCNAction.sequence(actions))
        }
        
        neededRunAI = false
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
            neededRunAI = true
        } else if (maskA | maskB) == (CollisionMask.bullet.rawValue | CollisionMask.tank.rawValue) {
            var bullet: Bullet
            var target: Tank
            if let tank = nodeA as? Tank {
                bullet = nodeB as! Bullet
                target = tank
            } else if let tank = nodeB as? Tank {
                bullet = nodeA as! Bullet
                target = tank
            } else {
                return
            }
            guard target != bullet.owner else {
                return
            }
            remove(bullet: bullet)
            if target == player {
                endGame()
                return
            }
            if let enemy = target as? Enemy, let idx = enemies.index(of: enemy) {
                enemies.remove(at: idx)
            }
            target.removeFromParentNode()
            neededRunAI = true
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
        
    }
}
