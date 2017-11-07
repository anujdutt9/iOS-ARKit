//
//  ViewController.swift
//  RelativePosition
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
        // define a node in space
        // a node has no shape, size or color
        let node = SCNNode()
        
        // Placing Cylinder wrt Pyramid
        let cylinderNode = SCNNode(geometry: SCNCylinder(radius: 0.05, height: 0.5))
        
        // ----------------------------- Pyramid Geometry ----------------------
        node.geometry = SCNPyramid(width: 0.1, height: 0.1, length: 0.1)
        node.geometry?.firstMaterial?.specular.contents = UIColor.white
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.brown
        // give this box "node" a position wrt root node i.e. origin
        // 0,0,0 places the box at origin
        // Usage: node.position = SCNVector3(0,0,0)
        node.position = SCNVector3(0.2,0.3,-0.2)
        // ---------------------------------------------------------------------
        
        // ----------------------------- Cylinder Geometry -----------------------
        // Placing Cylinder wrt Pyramid
        // cylinderNode.geometry = SCNCylinder(radius: 0.1, height: 0.3)
        // Light color falling on surface of Cylinder
        cylinderNode.geometry?.firstMaterial?.specular.contents = UIColor.white
        // Color of Cylinder; Color spread across the surface of Node
        cylinderNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        
        //position cylinder wrt pyramind position
        // cylinderNode.position = SCNVector3(-0.1,0.5,-0.5)
        // self.sceneView.scene.rootNode.addChildNode(cylinderNode)
        cylinderNode.position = SCNVector3(-0.3,0.2,-0.3)
        // ------------------------------------------------------------------------
        
        // put node inside the scene view
        // a scene is what shows our axis in real world, we want to place our node in the scene
        // rootnode: has no size, shape or color; positioned exactly at world origin
        // maikng "node" a child of root node means, whatever position we give to our "node", it is positioned in space wrt root node.
        self.sceneView.scene.rootNode.addChildNode(node)
        
        // Make Cylinder Node child of Pyramid Node
        node.addChildNode(cylinderNode)
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

