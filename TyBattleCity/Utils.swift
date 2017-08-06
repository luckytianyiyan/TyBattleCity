//
//  Utils.swift
//  TyBattleCity
//
//  Created by luckytianyiyan on 2017/8/7.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import SceneKit

extension SCNMaterial {
    public convenience init(named: String) {
        self.init()
        lightingModel = .physicallyBased
        diffuse.contents = UIImage(named: "Assets.scnassets/\(named)")
        diffuse.wrapS = .repeat
        diffuse.wrapT = .repeat
    }
}
