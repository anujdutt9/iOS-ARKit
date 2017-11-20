//
//  ViewController.swift
//  ARShooter
//
//  Created by Anuj Dutt on 11/20/17.
//  Copyright © 2017 Anuj Dutt. All rights reserved.
//

import UIKit
import ARKit
enum BitMaskCategory: Int {
    case bullet = 2
    case target = 3
}

class ViewController: UIViewController, SCNPhysicsContactDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    var power:Float = 50
    var Target: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.session.run(configuration)
        self.sceneView.autoenablesDefaultLighting = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(gestureRecognizer)
        self.sceneView.scene.physicsWorld.contactDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // place the targets at given positions
    @IBAction func addTargets(_ sender: Any) {
        self.addEgg(x: 5, y: 0, z: -40)
        self.addEgg(x: 0, y: 0, z: -40)
        self.addEgg(x: -5, y: 0, z: -40)
    }

    func addEgg(x: Float, y:Float, z:Float){
        let eggScene = SCNScene(named: "egg.scnassets/egg.scn")
        let eggNode = eggScene?.rootNode.childNode(withName: "egg", recursively: false)
        eggNode?.position = SCNVector3(x,y,z)
        eggNode?.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: eggNode!, options:nil))
        // Categorize the egg
        eggNode?.physicsBody?.categoryBitMask = BitMaskCategory.target.rawValue
        // Check for egg collision with the bullet
        eggNode?.physicsBody?.contactTestBitMask = BitMaskCategory.bullet.rawValue
        self.sceneView.scene.rootNode.addChildNode(eggNode!)
    }
 
    @objc func handleTap(sender: UITapGestureRecognizer){
        guard let sceneView = sender.view as? ARSCNView else {return}
        guard let pointOfview = sceneView.pointOfView else {return}
        let transform = pointOfview.transform
        let orientation = SCNVector3(-transform.m31,-transform.m32,-transform.m33)
        let location = SCNVector3(transform.m41,transform.m42,transform.m43)
        let position = addVector(first: location, second: orientation)
        let bullet = SCNNode(geometry: SCNSphere(radius: 0.1))
        bullet.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        bullet.position = position
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: bullet, options: nil))
        body.isAffectedByGravity = false
        bullet.physicsBody = body
        bullet.physicsBody?.applyForce(SCNVector3(orientation.x * power,orientation.y * power,orientation.z * power), asImpulse: true)
        // Categorize the Bullet using bitmap
        bullet.physicsBody?.categoryBitMask = BitMaskCategory.bullet.rawValue
        // check bullet for any collision with the egg
        bullet.physicsBody?.contactTestBitMask = BitMaskCategory.target.rawValue
        self.sceneView.scene.rootNode.addChildNode(bullet)
        // Disappear bullets after 2 sec
        bullet.runAction(
        SCNAction.sequence([SCNAction.wait(duration: 2.0), SCNAction.removeFromParentNode()])
        )
    }
    
    func addVector(first: SCNVector3, second:SCNVector3) -> SCNVector3 {
        return SCNVector3Make(first.x + second.x, first.y + second.y, first.z + second.z)
    }
    
    // Function to blow up the egg on contact with bullet
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        if nodeA.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue{
            self.Target = nodeA
        }
        else if nodeB.physicsBody?.categoryBitMask == BitMaskCategory.target.rawValue{
            self.Target = nodeB
        }
        let confetti = SCNParticleSystem(named: "egg.scnassets/Confetti.scnp", inDirectory: nil)
        // Play it only once nd not in loops
        confetti?.loops = false
        // Lasts for 4 sec
        confetti?.particleLifeSpan = 4
        // confetti takes shape of egg
        confetti?.emitterShape = Target?.geometry
        let confettiNode = SCNNode()
        confettiNode.addParticleSystem(confetti!)
        // Place animation right at place of contact
        confettiNode.position = contact.contactPoint
        self.sceneView.scene.rootNode.addChildNode(confettiNode)
        // Remove egg from scene
        Target?.removeFromParentNode()
    }
}

