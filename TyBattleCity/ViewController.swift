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

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    var planes: [ARPlaneAnchor: PlaneNode] = [:]
    var selectedPlane: PlaneNode?
    var gameSceneNode: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        let gameScene = SCNScene(named: "art.scnassets/ship.scn")!
        gameSceneNode = gameScene.rootNode.childNode(withName: "shipMesh", recursively: true)
        gameSceneNode?.removeFromParentNode()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognize:)))
        sceneView.addGestureRecognizer(tapGesture)
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
        let location = recognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, options: [:])
        guard let result = hitResults.first, let selectedNode = result.node as? PlaneNode, let gameSceneNode = gameSceneNode else {
            return
        }
        selectedPlane = selectedNode
        print("selected: \(selectedNode)")
        selectedNode.addChildNode(gameSceneNode)
        gameSceneNode.position = SCNVector3(selectedNode.anchor.center)
    }
}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else {
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

