//
//  ViewController.swift
//  CNM_ARKit
//
//  Created by Anh Nguyễn Hoàng on 06/06/2021.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    private var fishNode: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.autoenablesDefaultLighting = true
        // Create a new scene
        let scene = SCNScene()
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
        addTapGesture()
        addPinchGesture()
        addRotationGesture()
        addMoveGesture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - OTHER FUNCTION
    // Add model to new positionn
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        self.sceneView.addGestureRecognizer(tapGesture)
    }
    
    @objc func didTap(_ gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: self.sceneView)
        let results = self.sceneView.hitTest(tapLocation, types: .featurePoint)
        guard let result = results.first else {
            return
        }
        let translation = result.worldTransform.translation3x3
        guard let node = self.fishNode else {
            self.addNewLocationForFish()
            return
        }
        node.position = SCNVector3Make(translation.x, translation.y, translation.z)
        self.sceneView.scene.rootNode.addChildNode(self.fishNode)
    }
    
    // Scale model
    private func addPinchGesture() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(_:)))
        self.sceneView.addGestureRecognizer(pinchGesture)
    }
    
    @objc func didPinch(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            gesture.scale = CGFloat(fishNode.scale.x)
        case .changed:
            var newScale: SCNVector3
            if gesture.scale < 0.1 {
                newScale = SCNVector3(x: 0.1, y: 0.1, z: 0.1)
            } else if gesture.scale > 1 {
                newScale = SCNVector3(1, 1, 1)
            } else {
                newScale = SCNVector3(gesture.scale, gesture.scale, gesture.scale)
            }
            fishNode.scale = newScale
        default:
            break
        }
    }
    
    // Rotate the model
    private func addRotationGesture() {
        let panGesture = UIRotationGestureRecognizer(target: self, action: #selector(didRotate(_:)))
        self.sceneView.addGestureRecognizer(panGesture)
    }
    
    private var lastRotation: Float = 0
    
    @objc func didRotate(_ gesture: UIRotationGestureRecognizer) {
        switch gesture.state {
        case .changed:
            self.fishNode.eulerAngles.y = self.lastRotation + Float(gesture.rotation)
        case .ended:
            self.lastRotation += Float(gesture.rotation)
        default:
            break
        }
    }
    
    // Move the model to new position
    private func addMoveGesture() {
        let tapGesture = UIPanGestureRecognizer(target: self, action: #selector(moveModel))
        self.sceneView.addGestureRecognizer(tapGesture)
    }
    
    @objc func moveModel(panGesture: UIPanGestureRecognizer) {
        guard let view = self.sceneView else { return }
        let location = panGesture.location(in: view)
        guard let hitNodeResult = view.hitTest(location, types: .featurePoint).first else { return }
        let worldTransform = hitNodeResult.worldTransform.translation3x3
        let position = SCNVector3(worldTransform.x, worldTransform.y, worldTransform.z)
        self.fishNode.position = position
    }
    
    func addNewLocationForFish() {
        // get node from childNode of scene fish model
        guard let fishNode = SCNScene(named: "fish.dae")?.rootNode.childNode(withName: "fishModel", recursively: true) else {
            print("Fish model not found")
            return
        }
        self.fishNode = fishNode
        self.fishNode.scale = SCNVector3(x: 0.1, y: 0.1, z: 0.1)
        sceneView.scene.rootNode.addChildNode(self.fishNode)
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
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

extension float4x4 {
    var translation3x3: SIMD3<Float> {
        let translation = self.columns.3
        return SIMD3<Float>(translation.x, translation.y, translation.z)
    }
}
