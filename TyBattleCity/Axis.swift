//
//  Axis.swift
//  TyBattleCity
//
//  Created by luckytianyiyan on 2017/8/5.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import SceneKit

class Axis: SCNNode {
    var body: SCNNode
    
    override init() {
        let scene = SCNScene(named: "axis.scn")!
        body = scene.rootNode.childNode(withName: "axis", recursively: true)!
        super.init()
        addChildNode(body)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
