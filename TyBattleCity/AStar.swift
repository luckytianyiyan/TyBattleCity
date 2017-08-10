//
//  AStar.swift
//  TyBattleCity
//
//  Created by luckytianyiyan on 2017/8/11.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import Foundation

class AStarStep {
    var g: Int = 0
    var h: Int = 0
    var f: Int {
        return g + h
    }
    var position: CGPoint
    var last: AStarStep?
    
    init(_ position: CGPoint) {
        self.position = position
    }
}

extension AStarStep: CustomStringConvertible {
    var description: String {
        return "(position: \(position), g: \(g), h: \(h), f: \(f)"
    }
}

protocol AStarDelegate: class {
    func coat(from lhs: CGPoint, to rhs: CGPoint) -> Int
    
    func isPassable(_ position: CGPoint) -> Bool
}

class AStar {
    var open: [AStarStep] = []
    var closed: [AStarStep] = []
    private(set) var stepDistance: CGFloat
    weak var delegate: AStarDelegate?
    
    init(stepDistance: CGFloat = 1) {
        self.stepDistance = stepDistance
    }
    
    func execute(from src: CGPoint, to dst: CGPoint) -> [CGPoint] {
        var paths: [CGPoint] = []
        guard let delegate = delegate else {
            return paths
        }
        open = []
        closed = []
        open.append(AStarStep(src))
        
        repeat {
            let currentStep = open.removeFirst()
            print("crrent: \(currentStep)")
            closed.append(currentStep)
            
            if currentStep.position == dst {
                print("finished :P")
                var tmpStep: AStarStep? = currentStep
                repeat {
                    paths.insert(tmpStep!.position, at: 0)
                    tmpStep = tmpStep!.last
                } while tmpStep != nil
                
                open = []
                closed = []
                break
            }
            
            var borderPositions = borderMovablePoints(position: currentStep.position)
            
            var idx = 0
            
            repeat {
                let position = borderPositions[idx]
                // Check if the step isn't already in the closed set
                if let _ = closed.index(where: { position == $0.position }) {
                    borderPositions.remove(at: idx)
                    // skip idx += 1
                    continue
                }
                
                var step: AStarStep
                let moveCost = delegate.coat(from: position, to: dst)
                if let index = open.index(where: { $0.position == position }) {
                    step = open[index]
                    if currentStep.g + moveCost < step.g {
                        step.g = currentStep.g + moveCost
                        open.remove(at: index)
                        appendToOpen(step: step)
                    }
                } else {
                    step = AStarStep(position)
                    step.last = currentStep
                    step.g = currentStep.g + moveCost
                    let distancePoint = CGPoint(x: position.x - dst.x, y: position.y - dst.y)
                    step.h = Int(abs(distancePoint.x) + abs(distancePoint.y))
                    appendToOpen(step: step)
                }
                
                idx += 1
            } while idx < borderPositions.count
            
            for var idx in 0..<borderPositions.count {
                
            }
        } while open.count > 0
        
        return paths
    }
    
    func appendToOpen(step: AStarStep) {
        var idx = 0
        for s in open {
            if step.f <= s.f {
                break
            }
            idx += 1
        }
        open.insert(step, at: idx)
    }
    
    func borderMovablePoints(position: CGPoint) -> [CGPoint] {
        guard let delegate = delegate else {
            return []
        }
        let borderPoints = [CGPoint(x: position.x, y: position.y - stepDistance),//< top
                            CGPoint(x: position.x, y: position.y + stepDistance),//< bottom
                            CGPoint(x: position.x - stepDistance, y: position.y),//< left
                            CGPoint(x: position.x + stepDistance, y: position.y)]//< right
        return borderPoints.filter { delegate.isPassable($0) }
    }
}
