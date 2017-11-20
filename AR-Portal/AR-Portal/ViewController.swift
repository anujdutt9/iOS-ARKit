//
//  ViewController.swift
//  AR-Portal
//
//  Created by Anuj Dutt on 2017-11-17.
//  Copyright © 2017 Anuj Dutt. All rights reserved.
//

import UIKit
import ARKit
class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var planeDetected: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        // Detect the Horizontal Planes
        self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
        // Execute the delegate function
        self.sceneView.delegate = self
        // Add the Tap Gesture, if a tap is recognized, execute the Handle Tap function
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        // Add tap gesture recognizer to the Scene View
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // Function to handle Tap Gesture in Scene View
    @objc func handleTap(sender: UITapGestureRecognizer) {
        // Check if tap was performed, then move forward else, return
        guard let sceneView = sender.view as? ARSCNView else {return}
        // Get the location of the touch in the Scene View
        let touchLocation = sender.location(in: sceneView)
        // use hit test to get the location of tap
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        if !hitTestResult.isEmpty {
            // if tap is recognized, add the portal in front of camera
            self.addPortal(hitTestResult: hitTestResult.first!)
        } else {
            ////
        }
    }
    
    // Function to add the Portal in front of the Camera location
    func addPortal(hitTestResult: ARHitTestResult) {
        // Define the Portal Scene
        let portalScene = SCNScene(named: "Portal.scnassets/Portal.scn")
        // Create the portal node, recursive as there are multiple levels in its children
        let portalNode = portalScene!.rootNode.childNode(withName: "Portal", recursively: false)!
        // Get the transform matrix from the hit test
        let transform = hitTestResult.worldTransform
        
        // get the x, y and z positions from the transform matrix
        let planeXposition = transform.columns.3.x
        let planeYposition = transform.columns.3.y
        let planeZposition = transform.columns.3.z
        
        // Place the portal in the location of the x ,y ,z coordinates obtained
        portalNode.position =  SCNVector3(planeXposition, planeYposition, planeZposition)
        // Add the portal node to thee scene view
        self.sceneView.scene.rootNode.addChildNode(portalNode)
        
        // Add image to the walls on inside of the portal room
        self.addPlane(nodeName: "roof", portalNode: portalNode, imageName: "top")
        self.addPlane(nodeName: "floor", portalNode: portalNode, imageName: "bottom")
        self.addWalls(nodeName: "backWall", portalNode: portalNode, imageName: "back")
        self.addWalls(nodeName: "sideWallA", portalNode: portalNode, imageName: "sideA")
        self.addWalls(nodeName: "sideWallB", portalNode: portalNode, imageName: "sideB")
        self.addWalls(nodeName: "sideDoorA", portalNode: portalNode, imageName: "sideDoorA")
        self.addWalls(nodeName: "sideDoorB", portalNode: portalNode, imageName: "sideDoorB")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {return}
        DispatchQueue.main.async {
            // Keep the plane detected label as hidden
            self.planeDetected.isHidden = false
        }
        
        // if horizontal plane found, display plane detected for 3 seconds and then make it hidden
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.planeDetected.isHidden = true
        }
    }
    
    // Add images to the walls of the portal
    func addWalls(nodeName: String, portalNode: SCNNode, imageName: String) {
        // Add top and bottom to the portal
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Portal.scnassets/\(imageName).png")
        // By default the rendering order of walls, roof and bottom is "0".
        // More the rendering Order, more the transparency
        // Using this, the mask will be rendered first and then the walls. so, they appear transparent
        child?.renderingOrder = 200
        if let mask = child?.childNode(withName: "mask", recursively: false) {
            // Make masks completely Transparent
            mask.geometry?.firstMaterial?.transparency = 0.000001
        }
    }
    
    // Add images to the roof and floor of the portal
    // Rule of Thumb: If an opaque object is rendered way after the translucent object, then the colors will mix.
    // Since mask is transparent, it'll make the walls to appear transparent as well.
    func addPlane(nodeName: String, portalNode: SCNNode, imageName: String) {
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Portal.scnassets/\(imageName).png")
        // render floor and ceiling after the mask rendering
        child?.renderingOrder = 200
    }
    
}

