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
    var planeGeometry: SCNBox
    
    init(anchor: ARPlaneAnchor) {
        self.anchor = anchor
        planeGeometry = SCNBox(width: CGFloat(anchor.extent.x), height: 0.01, length: CGFloat(anchor.extent.z), chamferRadius: 0)
        super.init()
        
        let transparentMaterial = SCNMaterial()
        transparentMaterial.diffuse.contents = UIColor.clear
        planeGeometry.materials = [transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, SCNMaterial(named: "tron-albedo"), transparentMaterial]
        
        geometry = planeGeometry
        position = SCNVector3(x: 0, y: -0.005, z: 0)
        physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: planeGeometry, options: nil))
        updateTextureScale()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(anchor: ARPlaneAnchor) {
        planeGeometry.length = CGFloat(anchor.extent.z)
        planeGeometry.width = CGFloat(anchor.extent.x)
        
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        
        physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: planeGeometry, options: nil))
        updateTextureScale()
    }
    
    private func updateTextureScale() {
        let width: Float = Float(planeGeometry.width)
        let height: Float = Float(planeGeometry.length)
        
        let material = self.planeGeometry.materials[4];
        let scaleFactor: Float = 1
        let matrix: SCNMatrix4 = SCNMatrix4MakeScale(width * scaleFactor, height * scaleFactor, 1)
        material.diffuse.contentsTransform = matrix
        material.roughness.contentsTransform = matrix
        material.metalness.contentsTransform = matrix
        material.normal.contentsTransform = matrix
    }
}

extension SCNMaterial {
    public convenience init(named: String) {
        self.init()
        lightingModel = .physicallyBased
        diffuse.contents = UIImage(named: "Assets.scnassets/\(named)")
        diffuse.wrapS = .repeat
        diffuse.wrapT = .repeat
    }
}
