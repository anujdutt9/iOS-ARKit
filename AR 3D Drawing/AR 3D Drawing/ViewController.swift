//
//  ViewController.swift
//  AR 3D Drawing
//
//  Created by Anuj Dutt on 11/6/17.
//  Copyright © 2017 Anuj Dutt. All rights reserved.
//

import UIKit
import ARKit
class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var draw: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    
    let config = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.showsStatistics = true
        self.sceneView.session.run(config)
        // Call the rendering function while the Scene is being rendered
        self.sceneView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Function gets called every time our app is about to render a Scene
    // Scene rendering is being done at 60fps. So as long as something is being rendered, this function gets called
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        // print("Rendering Scene")
        
        // Get current position of Camera wrt Origin 60 fps
        // Position is the combination of Orientation in space of camera and location
        // pointOfView: contains the current location and orientation of Camera View wrt Origin
        // Location & Orientation present in form of Transform Matrix inside pointOfView
        guard let pointOfView = sceneView.pointOfView else {return}
        
        // Transform Matrix
        let transform = pointOfView.transform
        
        // -------- Get the current Location and Orientation of Camera from Transform Matrix -------------
        
        // Orientation: where your phone is facing/oriented wrt origin
        // Orientation values are always in third column of the Transform Matrix
        // transform.m31: Orientation of "x" value of camera
        // transform.m32: Orientation of "y" value of camera
        // transform.m33: Orientation of "z" value of camera
        let cameraOrientation = SCNVector3(-transform.m31,-transform.m32,-transform.m33)
        // print("Camera Orientation is: ",[cameraOrientation.x,cameraOrientation.y,cameraOrientation.z])
        
        // Location values of the Camera wrt Origin/Scene View
        // transform.m41: Location of "x" value of camera
        // transform.m42: Location of "y" value of camera
        // transform.m43: Location of "z" value of camera
        let cameraLocation = SCNVector3(transform.m41,transform.m42,transform.m43)
        // print("Camera Location is: ",[cameraLocation.x,cameraLocation.y,cameraLocation.z])
        
        // Get current position of camera using Location and Orientation
        let cameraCurrentPosition = cameraOrientation + cameraLocation
        
        // Run this in Main Thread else the app will crash as rest of it runs in the background thread
        DispatchQueue.main.async {
            // Check if Button is pressed or not and draw content
            if self.draw.isHighlighted{
                let sphereNode  = SCNNode(geometry: SCNSphere(radius: 0.02))
                // Put Sphere node in camera view
                sphereNode.position = cameraCurrentPosition
                self.sceneView.scene.rootNode.addChildNode(sphereNode)
                sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                print("Draw Button is Pressed")
            }
                // if person is not drawing, place a pointer in that location
            else{
                let pointer = SCNNode(geometry: SCNSphere(radius: 0.01))
                pointer.name = "pointer"
                // Put pointer in current position of camera
                pointer.position = cameraCurrentPosition
                
                // before adding the new pointer to scrreen, delete every old pointer
                // else it forms a line
                self.sceneView.scene.rootNode.enumerateChildNodes({(node,_) in
                    if node.name == "pointer"{
                        node.removeFromParentNode()
                    }
                })
                
                self.sceneView.scene.rootNode.addChildNode(pointer)
                pointer.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            }
        }
        
        
    }
}


func +(left:SCNVector3,right:SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
