//
//  Tank.swift
//  TyBattleCity
//
//  Created by luckytianyiyan on 2017/8/3.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import SceneKit

class Tank: SCNNode {
    var body: SCNNode
    
    override init() {
        let scene = SCNScene(named: "tank.scn")!
        body = scene.rootNode.childNode(withName: "tank", recursively: true)!
        super.init()
        addChildNode(body)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

