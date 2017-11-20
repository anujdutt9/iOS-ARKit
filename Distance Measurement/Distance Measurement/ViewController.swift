//
//  ViewController.swift
//  Distance Measurement
//
//  Created by Anuj Dutt on 11/16/17.
//  Copyright © 2017 Anuj Dutt. All rights reserved.
//

import UIKit
import ARKit
class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var xlabel: UILabel!
    @IBOutlet weak var ylabel: UILabel!
    @IBOutlet weak var zlabel: UILabel!
    var startingPosition: SCNNode?
    
    let configuration = ARWorldTrackingConfiguration()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.showsStatistics = true
        self.sceneView.session.run(configuration)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        // Whenever you tap on scene View, thsi function gets executed
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        self.sceneView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Function to place a node in front on tap
    @objc func handleTap(sender: UITapGestureRecognizer){
        // If tap is in ARKit scene view, then do something else return
        guard let sceneView = sender.view as? ARSCNView else {return}
        // Use current frame information to place object in front of camera
        guard let currentFrame  = sceneView.session.currentFrame else {return}
        // If tapped again on the screen and distance is not null, then stop measuring and remove the starting position node
        if self.startingPosition != nil{
            self.startingPosition?.removeFromParentNode()
            self.startingPosition = nil
            return
        }
        // This gives us info about current position, orientation and imaging parameters of the camera
        // This info is presen in a transform matrix
        let camera = currentFrame.camera
        let transform = camera.transform
        var translationMatrix = matrix_identity_float4x4
        translationMatrix.columns.3.z = -0.1
        // New Matrix with z-value at -0.3: -0.1 + -0.2 = -0.3
        let modifiedMatrix = simd_mul(transform, translationMatrix)
        
        // Object to place in front of camera
        let sphere = SCNNode(geometry: SCNSphere(radius: 0.005))
        sphere.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
        // Make the node to be positioned exactly where the phone is present by making the transform matrix of the node equal to that of the camera
        sphere.simdTransform = modifiedMatrix
        self.sceneView.scene.rootNode.addChildNode(sphere)
        self.startingPosition = sphere
    }
    
    // Gets called once per frame
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Update Labels with distance travelled by the node
        // Only move forward if the user tapped on the sceneView and we have a starting position node
        guard let startingPosition = self.startingPosition else {return}
        // Get current camera location
        guard let pointOfView = self.sceneView.pointOfView else {return}
        // Get the Transform matrix
        let transform = pointOfView.transform
        // Get the current location of the phone from origin
        let location = SCNVector3(transform.m41,transform.m42,transform.m43)
        // Subtract current location of phone by the starting point, we get the actual distance travelled
        let xDistance = location.x - startingPosition.position.x
        let yDistance = location.y - startingPosition.position.y
        let zDistance = location.z - startingPosition.position.z
        
        // Update the Labels in the Main Thread
        DispatchQueue.main.async {
            self.xlabel.text = String(format: "%.2f",xDistance) + "m"
            self.ylabel.text = String(format: "%.2f",yDistance) + "m"
            self.zlabel.text = String(format: "%.2f",zDistance) + "m"
            // Diagonal Distance Travelled
            self.distance.text = String(format: "%.2f",self.distanceTravelled(x: xDistance, y: yDistance, z: zDistance)) + "m"
        }
    }
    
    // Function to Measure the Diagonal Distance
    func distanceTravelled(x: Float, y: Float, z: Float) -> Float {
        return (sqrtf(pow(x, 2) + pow(y, 2) + pow(z, 2)))
    }

}

