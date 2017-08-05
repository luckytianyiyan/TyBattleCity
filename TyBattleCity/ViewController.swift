//
//  ViewController.swift
//  TyBattleCity
//
//  Created by luckytianyiyan on 2017/8/1.
//  Copyright © 2017年 luckytianyiyan. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

enum GameState: Int {
    case selectPlane
    case startGame
}

class ViewController: UIViewController {
    
    var state: GameState = .selectPlane {
        didSet {
            switch state {
            case .startGame:
                for p in planes {
                    p.value.isHidden = true
                }
                selectedPlane?.isHidden = false
                selectedPlane?.geometry = nil
                break
            default:
                break
            }
        }
    }
    let gameSceneScale: Float = 0.05

    @IBOutlet var sceneView: ARSCNView!
    var planes: [ARPlaneAnchor: PlaneNode] = [:]
    var selectedPlane: PlaneNode?
    var controlViewController: ControlViewController?
    var axis: Axis? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        axis = Axis()
        axis?.scale = SCNVector3(x: gameSceneScale, y: gameSceneScale, z: gameSceneScale)
        
        GameController.shared.prepare(partName: "part-1")
        GameController.shared.map.transform = SCNMatrix4MakeRotation(Float.pi / 2, 1.0, 0.0, 0.0)
        GameController.shared.map.scale = SCNVector3(x: 0.05, y: 0.05, z: 0.05)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognize:)))
        sceneView.addGestureRecognizer(tapGesture)
        
        controlViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "control") as? ControlViewController
        view.addSubview(controlViewController!.view)
        addChildViewController(controlViewController!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: Gesture Recognizer
    @objc func handleTap(recognize: UIGestureRecognizer) {
        guard state == .selectPlane else {
            return
        }
        let location = recognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, options: [:])
        guard let result = hitResults.first, let selectedNode = result.node as? PlaneNode else {
            return
        }
        selectedPlane = selectedNode
        print("selected: \(selectedNode)")
        let node = GameController.shared.map
        selectedNode.addChildNode(node)
        selectedNode.addChildNode(axis!)
        updateMapPosition(anchor: selectedNode.anchor)
        state = .startGame
        GameController.shared.startGame()
    }
    
    func updateMapPosition(anchor: ARPlaneAnchor) {
        let mapSize = GameController.shared.map.mapSize
        GameController.shared.map.position = SCNVector3Make(anchor.center.x - Float(mapSize.x) * gameSceneScale * 0.5, anchor.center.y + Float(mapSize.y) * gameSceneScale * 0.5, anchor.center.z)
        axis?.position = SCNVector3(anchor.center)
    }
}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard state == .selectPlane, let anchor = anchor as? ARPlaneAnchor else {
            return
        }
        print("\(anchor)")
        let planeNode = PlaneNode(anchor: anchor)
        planes[anchor] = planeNode
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor, let planeNote = planes[anchor] else {
            return
        }
        planeNote.update(anchor: anchor)
        if selectedPlane?.anchor == anchor {
            updateMapPosition(anchor: anchor)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

