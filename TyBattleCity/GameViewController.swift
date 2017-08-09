//
//  GameViewController.swift
//  TyBattleCity
//
//  Created by luckytianyiyan on 2017/8/3.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import UIKit
import SceneKit

class GameViewController: UIViewController {
    
    var controlViewController: ControlViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let scnView = self.view as? SCNView else {
            fatalError("view is not SCNView object")
        }
        
        GameController.shared.prepare(partName: "part-1")
        
        let scene = SCNScene()
        scene.rootNode.addChildNode(GameController.shared.map)
        scene.physicsWorld.contactDelegate = GameController.shared
//        scnView.debugOptions = [.showPhysicsShapes, .showBoundingBoxes]
        scnView.debugOptions = [.showPhysicsShapes]
        
        scnView.scene = scene
        scnView.showsStatistics = true
        scnView.backgroundColor = UIColor.black
        
        controlViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "control") as? ControlViewController
        view.addSubview(controlViewController!.view)
        addChildViewController(controlViewController!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GameController.shared.startGame()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
}

