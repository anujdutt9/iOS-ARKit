//
//  ViewController.swift
//  RelativeObjectRotation
//
//  Created by Anuj Dutt on 11/6/17.
//  Copyright © 2017 Anuj Dutt. All rights reserved.
//

import UIKit
import ARKit
class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    
    // Declare a Configuration for the AR World Tracking
    // World Tracking used to get the Orientation of the Device in 3-D Coordinate System
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Show Scene View stats like fps
        sceneView.showsStatistics = true
        // Add Debug Options to the SceneView Session
        // Helps keep track of world origin at startup and feature points w.r.t that.
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
        // As soon as the view loads, run the World Tracking configuration to get the Device Configuration in Real World
        self.sceneView.session.run(configuration)
        
        // Load the Light Source for the box node
        // Puts an Omni-directional light source in the scene
        self.sceneView.autoenablesDefaultLighting = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func add(_ sender: Any) {
        // ---------------------- Relative Object Rotation ------------------------
//        let pyramid = SCNNode(geometry: SCNPyramid(width: 0.1, height: 0.1, length: 0.1))
//        pyramid.geometry?.firstMaterial?.specular.contents = UIColor.white
//        pyramid.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
//        pyramid.position = SCNVector3(0,0,-0.5)
//
//        let cylinder = SCNNode(geometry: SCNCylinder(radius: 0.01, height: 0.02))
//        cylinder.geometry?.firstMaterial?.specular.contents = UIColor.white
//        cylinder.geometry?.firstMaterial?.diffuse.contents = UIColor.red
//        cylinder.position = SCNVector3(0,0,-0.3)
//
//        // If the Cylinder is rotated, the Pyramid also rotates by same angle as it is aligned to it
//        cylinder.eulerAngles = SCNVector3(Float(90.degreesToRadians),0,0)
//        self.sceneView.scene.rootNode.addChildNode(cylinder)
//        cylinder.addChildNode(pyramid)
        // --------------------------------------------------------------
        
        let plane = SCNNode(geometry: SCNPlane(width: 0.1, height: 0.2))
        plane.geometry?.firstMaterial?.specular.contents = UIColor.white
        plane.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        plane.position = SCNVector3(0,0,0)
        plane.eulerAngles = SCNVector3(Float(-90.degreesToRadians),0,0)
        self.sceneView.scene.rootNode.addChildNode(plane)
        
        let pyramid = SCNNode(geometry: SCNPyramid(width: 0.1, height: 0.1, length: 0.1))
        pyramid.geometry?.firstMaterial?.specular.contents = UIColor.white
        pyramid.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        pyramid.position = SCNVector3(0,0,-0.5)
        plane.addChildNode(pyramid)
        
    }
    
    
    @IBAction func reset(_ sender: Any) {
        self.restartSession()
    }
    
    // Function to Pause current Session before Reset
    func restartSession(){
        // Pause the Session
        self.sceneView.session.pause()
        
        // Reset the Box Nodes
        // Enumerate through all child nodes for rootNode as parent and delete all of those
        self.sceneView.scene.rootNode.enumerateChildNodes{ (node,_) in node.removeFromParentNode()}
        
        // rerun the session so that it has the same configuration
        // resetTracking: forgets the old starting position and makes the current position as origin
        // removeExistingAnchors: removes the information about current existing objects wrt origin
        self.sceneView.session.run(configuration, options: [.resetTracking,.removeExistingAnchors])
    }
}

// Function to convert Degrees to Radians
extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180}
}
