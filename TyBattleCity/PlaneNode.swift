//
//  PlaneNode.swift
//  TyBattleCity
//
//  Created by luckytianyiyan on 2017/8/3.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import ARKit

class PlaneNode: SCNNode {
    let anchor: ARPlaneAnchor
    
    init(anchor: ARPlaneAnchor) {
        self.anchor = anchor
        super.init()
        let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        geometry = plane
        transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1.0, 0.0, 0.0)
        position = SCNVector3(x: anchor.center.x, y: 0, z: anchor.center.z)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(anchor: ARPlaneAnchor) {
        guard let plane = geometry as? SCNPlane else {
            return
        }
        plane.height = CGFloat(anchor.extent.z)
        plane.width = CGFloat(anchor.extent.x)
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
    }
}
