//
//  ViewController.swift
//  Plane Detection
//
//  Created by Anuj Dutt on 11/14/17.
//  Copyright © 2017 Anuj Dutt. All rights reserved.
//

// Lava on a Plane App

import UIKit
import ARKit
class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.session.run(configuration)
        // session configured to detect horizontal surfaces
        self.configuration.planeDetection = .horizontal
        self.sceneView.delegate = self
        // let lavaNode = createLava()
        // self.sceneView.scene.rootNode.addChildNode(lavaNode)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func createLava(planeAnchor: ARPlaneAnchor) -> SCNNode{
        let lavaNode = SCNNode(geometry: SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z)))
        lavaNode.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "lava")
        lavaNode.geometry?.firstMaterial?.isDoubleSided = true
        lavaNode.position = SCNVector3(planeAnchor.center.x,planeAnchor.center.y,planeAnchor.center.z)
        lavaNode.eulerAngles = SCNVector3(90.degreesToRadians,0,0)
        return lavaNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // If the Anchor added was a plane anchor, this statement will succeed
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        let lavaNode = createLava(planeAnchor: planeAnchor)
        node.addChildNode(lavaNode)
        print("New Horizontal surface detected, ARPlaneAnchor Added")
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // planeAnchor contains Orientation, position and size of a Horizontal Surface
        // As it gets to see more of floor, it updates its anchor
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        print("Updating Floor's Anchor...")
        node.enumerateChildNodes{(childNode,_) in
            childNode.removeFromParentNode()
        }
        let lavaNode = createLava(planeAnchor: planeAnchor)
        node.addChildNode(lavaNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let _ = anchor as? ARPlaneAnchor else {return}
        print("Removed Second ARPlane Anchor !!")
        node.enumerateChildNodes{(childNode,_) in
            childNode.removeFromParentNode()
        }
    }
}

// Convert Degrees to Radians
extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180}
}

