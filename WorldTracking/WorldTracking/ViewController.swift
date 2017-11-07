//  ViewController.swift
//  WorldTracking
//
//  Created by Anuj Dutt on 10/24/17.
//  Copyright © 2017 Anuj Dutt. All rights reserved.
//

// Enabled: Privacy-Camera Usage Description [Info.plist]
//Use: Asks the user to give camera access for the use case

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
    
    // Action for the Add Button
    // Every time you press the button, this action gets executed
    @IBAction func add(_ sender: Any) {
        // define a node in space
        // a node has no shape, size or color
        let node = SCNNode()
        
        // ----------------------------- Bezier Path ---------------------------
        // Used to create custom shapes from the path that you draw
        // Draw lines from one pont to other till we form a custom shape
        let path = UIBezierPath()
        path.move(to: CGPoint(x:0,y:0))
        
        // Add a line from this position
        path.addLine(to: CGPoint(x:0,y:0.2))
        
        // Add line going diagonally up from previous line
        path.addLine(to: CGPoint(x:0.2,y:0.3))
        
        // Add line going diagonally down from previous line
        path.addLine(to: CGPoint(x:0.4,y:0.2))
        
        // Add line going down to the base and complete the home
        path.addLine(to: CGPoint(x:0.4,y:0))
        
        // extrusionDepth: Thickness of the line
        let shape = SCNShape(path: path, extrusionDepth: 0.01)
        
        node.geometry = shape
        node.geometry?.firstMaterial?.specular.contents = UIColor.white
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        
        // ----------------------------------------------------------------------
        

        // ---------------------- Random x,y,z Co-ordinates -----------------
        // Get the random x,y,z values using the function randomNumbers()
        
        // let x = randomnumbers(firstNum: -0.3, secondNum: 0.3)
        // let y = randomnumbers(firstNum: -0.3, secondNum: 0.3)
        // let z = randomnumbers(firstNum: -0.3, secondNum: 0.3)
        
        //print("Value of x: ",x)
        //print("Value of y: ",y)
        //print("Value of z: ",z)
        // -------------------------------------------------------------------
        
        // give this box "node" a position wrt root node i.e. origin
        // 0,0,0 places the box at origin
        // Usage: node.position = SCNVector3(0,0,0)
        node.position = SCNVector3(0,0.3,0)
        
        // put node inside the scene view
        // a scene is what shows our axis in real world, we want to place our node in the scene
        // rootnode: has no size, shape or color; positioned exactly at world origin
        // maikng "node" a child of root node means, whatever position we give to our "node", it is positioned in space wrt root node.
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    
    // Code to Reset the World Origin
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
    
    // Function to Place the box nodes in random places instead of a fixed place
    func randomnumbers(firstNum: CGFloat,secondNum:CGFloat) -> CGFloat{
        return CGFloat(arc4random())/CGFloat(UINT32_MAX)*abs(firstNum-secondNum)+min(firstNum, secondNum)
    }
    
}

