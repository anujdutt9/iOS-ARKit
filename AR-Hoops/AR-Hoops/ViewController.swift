//
//  ViewController.swift
//  AR-Hoops
//
//  Created by Anuj Dutt on 11/20/17.
//  Copyright © 2017 Anuj Dutt. All rights reserved.
//

import UIKit
import ARKit
import Each
class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var planeDetected: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    // Check if basketball scene in root node
//    var basketAdded: Bool {
//        return self.sceneView.scene.rootNode.childNode(withName: "basket", recursively: false) != nil
//    }
    var basketAdded: Bool = false
    var power:Float = 1
    let timer = Each(0.05).seconds
    let configuration = ARWorldTrackingConfiguration()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.session.run(configuration)
        self.sceneView.autoenablesDefaultLighting = true
        self.configuration.planeDetection = .horizontal
        self.sceneView.delegate = self
        let tapGesturerecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGesturerecognizer)
        tapGesturerecognizer.cancelsTouchesInView = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {return}
        DispatchQueue.main.async {
            self.planeDetected.isHidden = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
            self.planeDetected.isHidden = true
        }
    }
    
    @objc func handleTap(sender:UITapGestureRecognizer){
        guard let sceneView = sender.view as? ARSCNView else {return}
        let touchLocation = sender.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchLocation, types: [.existingPlaneUsingExtent])
        if !hitTestResult.isEmpty{
            self.addBasket(hitTestResult: hitTestResult.first!)
        }
    }
    
    func addBasket(hitTestResult: ARHitTestResult){
        if basketAdded == false{
        let basketScene = SCNScene(named: "Basketball.scnassets/basketball.scn")
        let basketNode = basketScene?.rootNode.childNode(withName: "basket", recursively: false)
        let positionOfPlane = hitTestResult.worldTransform.columns.3
        let xPosition = positionOfPlane.x
        let yPosition = positionOfPlane.y
        let zPosition = positionOfPlane.z
        basketNode?.position = SCNVector3(xPosition,yPosition,zPosition)
        // Recognize the torus, its hole and let ball interact with that
        basketNode?.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: basketNode!, options: [SCNPhysicsShape.Option.keepAsCompound: true, SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
        self.sceneView.scene.rootNode.addChildNode(basketNode!)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
            self.basketAdded = true
        }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.basketAdded == true{
            timer.perform(closure: { () -> NextStep in
                self.power = self.power + 1
                return .continue
            })
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.basketAdded == true{
            self.timer.stop()
            self.shootball()
        }
        self.power = 1
    }
    
    deinit {
        self.timer.stop()
    }
    
    func addVectors(first:SCNVector3,second:SCNVector3) -> SCNVector3{
        return SCNVector3Make(first.x + second.x, first.y + second.y, first.z + second.z)
    }
    
    func shootball(){
        guard let pointOfView = self.sceneView.pointOfView else {return}
        self.removeBalls()
        // self.power = 10
        let transform = pointOfView.transform
        let location = SCNVector3(transform.m41,transform.m42,transform.m43)
        let orientation = SCNVector3(-transform.m31,-transform.m32,-transform.m33)
        let position = self.addVectors(first: location, second: orientation)
        let ball = SCNNode(geometry: SCNSphere(radius: 0.25))
        ball.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "ball")
        ball.position = position
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: ball))
        ball.physicsBody = body
        ball.name = "Basketball"
        // Energy lost when two objects collide
        //if val == 1, ball returns back with same speed/energy
        body.restitution = 0.2
        // Provide force to the ball. Setting asImpulse=true gives acceleration to the ball body
        ball.physicsBody?.applyForce(SCNVector3(orientation.x * power,orientation.y * power,orientation.z * power), asImpulse: true)
        self.sceneView.scene.rootNode.addChildNode(ball)
    }
    
    func removeBalls(){
        self.sceneView.scene.rootNode.enumerateChildNodes{ (node,_) in
            if node.name == "Basketball"{
                node.removeFromParentNode()
            }
        }
    }
    
}

