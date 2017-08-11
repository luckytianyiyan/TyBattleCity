//
//  Part.swift
//  TyBattleCity
//
//  Created by luckytianyiyan on 2017/8/12.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import SceneKit
import Yams

struct Part {
    var mapSize: int2
    var playerStartPosition: int2
    var enemyPositions: [int2]
    var mapDatas: String
    
    init(yaml file: String) {
        guard let content = try? String(contentsOfFile: file, encoding: .utf8),
            let yml = (try? Yams.load(yaml: content)) as? [String: Any],
            let size = yml["size"] as? [String: Int],
            let start = yml["start"] as? [String: Int],
            let datas = yml["datas"] as? String,
            let enemyDatas = yml["enemies"] as? [[String: Int]] else {
                fatalError("can not be load map")
        }
        mapSize = int2.size(size)
        playerStartPosition = int2.point(start)
        enemyPositions = enemyDatas.map { int2.point($0) }
        mapDatas = String(datas.unicodeScalars.filter({ !CharacterSet.whitespacesAndNewlines.contains($0) }))
    }
}
