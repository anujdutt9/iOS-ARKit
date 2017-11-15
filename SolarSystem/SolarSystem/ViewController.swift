//
//  ViewController.swift
//  SolarSystem
//
//  Created by Anuj Dutt on 11/7/17.
//  Copyright © 2017 Anuj Dutt. All rights reserved.
//

import UIKit
import ARKit
class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.session.run(configuration)
        // Illuminates the light on surface of scene view
        self.sceneView.autoenablesDefaultLighting = true
    }

    
    override func viewDidAppear(_ animated: Bool) {
        // Create Parent nodes to provide planets individual speed
        let earthParent = SCNNode()
        let venusParent = SCNNode()
        let moonParent = SCNNode()

        // Sun
        let sun = SCNNode(geometry: SCNSphere(radius: 0.35))
        sun.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "Sun Diffuse")
        sun.position = SCNVector3(0,0,-1)
        self.sceneView.scene.rootNode.addChildNode(sun)
        
        earthParent.position = SCNVector3(0,0,-1)
        venusParent.position = SCNVector3(0,0,-1)
        moonParent.position = SCNVector3(1.5,0,0)
        self.sceneView.scene.rootNode.addChildNode(earthParent)
        self.sceneView.scene.rootNode.addChildNode(venusParent)
        
        // ---------------------------------- EARTH -------------------------------
        let earth = planet(geometry: SCNSphere(radius: 0.2), diffuse: #imageLiteral(resourceName: "Earth Day"), specular: #imageLiteral(resourceName: "Earth Specular"), emission: #imageLiteral(resourceName: "Earth Specular"), normal: #imageLiteral(resourceName: "Earth Normal"), position: SCNVector3(1.5,0,0))
        //earth.eulerAngles = SCNVector3(0,0.3978,0.9175)
        earth.eulerAngles = SCNVector3(0,CGFloat(23.degreesToRadians),0)
        
        // Make Earth rotate horizontally around its axis
        let earthRotation = rotation(time: 8)
        earth.runAction(earthRotation)
        
        // Earth Moon
        let earthMoon = planet(geometry: SCNSphere(radius:0.05), diffuse: #imageLiteral(resourceName: "Earth Moon"), specular: UIImage(), emission: UIImage(), normal: UIImage(), position: SCNVector3(0,0,-0.3))
        earth.addChildNode(earthMoon)
        // --------------------------------------------------------------------------
        
        // ---------------------------------- VENUS ---------------------------------
        let venus = planet(geometry: SCNSphere(radius: 0.1), diffuse: #imageLiteral(resourceName: "Venus Surface"), specular: UIImage(), emission: #imageLiteral(resourceName: "Venus Atmosphere"), normal: UIImage(), position: SCNVector3(0.7,0,0))
        // ----------------------------------------------------------------------------
        
        // Rotate Planets around SUN
        let sunAction = rotation(time: 8)
        sun.runAction(sunAction)
        
        // Earth Rotation
        let earthParentRotation = rotation(time: 14)
        earthParent.addChildNode(earth)
        earthParent.addChildNode(moonParent)
        earthParent.runAction(earthParentRotation)
        
        // Moon Rotation
        let moonRotation = rotation(time: 2)
        moonParent.addChildNode(earthMoon)
        moonParent.runAction(moonRotation)
        
        
        // Venus Rotation
        let venusParentRotation = rotation(time: 10)
        venusParent.addChildNode(venus)
        venusParent.runAction(venusParentRotation)
    }
    
    // Function to create a Planet
    func planet(geometry: SCNGeometry,diffuse: UIImage,specular: UIImage, emission: UIImage, normal: UIImage, position: SCNVector3) -> SCNNode{
        let planet = SCNNode(geometry: geometry)
        planet.geometry?.firstMaterial?.diffuse.contents = diffuse
        planet.geometry?.firstMaterial?.specular.contents = specular
        planet.geometry?.firstMaterial?.normal.contents = normal
        planet.position = position
        return planet
    }
    
    // Function to rotate Moon around Planets
    func rotation(time: TimeInterval) -> SCNAction{
        let planetRotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: time)
        let foreverRotation = SCNAction.repeatForever(planetRotation)
        return foreverRotation
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension Int{
    var degreesToRadians:Double { return Double(self) * .pi/180}
}

