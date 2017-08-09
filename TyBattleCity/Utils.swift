//
//  Utils.swift
//  TyBattleCity
//
//  Created by luckytianyiyan on 2017/8/7.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import SceneKit
import ARKit

extension SCNMaterial {
    public convenience init(named: String) {
        self.init()
        lightingModel = .physicallyBased
        diffuse.contents = UIImage(named: "Assets.scnassets/\(named)")
        diffuse.wrapS = .repeat
        diffuse.wrapT = .repeat
    }
}

extension ARCamera.TrackingState {
    var description: String {
        switch self {
        case .notAvailable:
            return "Tracking Unavailable"
        case .normal:
            return "Tracking Normal"
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                return "Tracking Limited: Too much camera movement"
            case .insufficientFeatures:
                return "Tracking Limited: Not enough surface detail"
            }
        }
    }
}

extension float2 {
    public init(x: CGFloat, y: CGFloat) {
        self.init(x: Float(x), y: Float(y))
    }
}

extension SCNVector3 {
    static func +(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        return SCNVector3(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
}
