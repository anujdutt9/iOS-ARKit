//
//  ViewController.swift
//  Distance Measurement
//
//  Created by Anuj Dutt on 11/16/17.
//  Copyright © 2017 Anuj Dutt. All rights reserved.
//

import UIKit
import ARKit
class ViewController: UIViewController {

    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var xlabel: UILabel!
    @IBOutlet weak var ylabel: UILabel!
    @IBOutlet weak var zlabel: UILabel!
    
    let configuration = ARWorldTrackingConfiguration()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.showsStatistics = true
        self.sceneView.session.run(configuration)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        // Whenever you tap on scene View, thsi function gets executed
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
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
    }

}

