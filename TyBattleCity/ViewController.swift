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
    var planes: [ARPlaneAnchor: SCNNode] = [:]
    var selectedPlane: SCNNode?
    
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
        guard let result = hitResults.first else {
            return
        }
        selectedPlane = result.node
        print("selected: \(result.node)")
    }
}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else {
            return
        }
        print("\(anchor)")
        let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(x: anchor.center.x, y: 0, z: anchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1.0, 0.0, 0.0)
        planes[anchor] = planeNode
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor, let planeNote = planes[anchor] else {
            return
        }
        let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        planeNote.geometry = plane
        planeNote.position = SCNVector3(x: anchor.center.x, y: 0, z: anchor.center.z)
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

