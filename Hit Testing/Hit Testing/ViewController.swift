//
//  ViewController.swift
//  Hit Testing
//
//  Created by Anuj Dutt on 11/13/17.
//  Copyright © 2017 Anuj Dutt. All rights reserved.
//

import UIKit
import ARKit
import Each
class ViewController: UIViewController {

    // Timer to count up by 1 sec
    var timer = Each(1).seconds
    var countDown = 10
    
    @IBOutlet weak var play: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.session.run(configuration)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func play(_ sender: Any) {
        // Set the Timer to find the Jellyfish
        self.setTimer()
        // Add the Jellyfish Node
        self.addNode()
        // If Play has been pressed once, don't add any more jellyfish if it is already present
        self.play.isEnabled = false
    }
    
    
    @IBAction func reset(_ sender: Any) {
        self.timer.stop()
        self.restoreTimer()
        self.play.isEnabled = true
        self.sceneView.scene.rootNode.enumerateChildNodes{ (node,_) in
            node.removeFromParentNode()
        }
    }
    
    
    // Function to add a Box node when Hit "Play"
    func addNode(){
        // Add Jellyfish 3-D Model
        let jellyFishScene = SCNScene(named: "art.scnassets/Jellyfish.scn")
        let jellyfishNode = jellyFishScene?.rootNode.childNode(withName: "Jellyfish", recursively: false)
        // Place Jellyfish at Random Positions every time
        jellyfishNode?.position = SCNVector3(randomNumbers(firstNum: -1, secondNum: 1),randomNumbers(firstNum: -0.5, secondNum: 0.5),randomNumbers(firstNum: -1, secondNum: 1))
        self.sceneView.scene.rootNode.addChildNode(jellyfishNode!)
        
        // ----------------- Code to Add a Box Node in Scene -----------------------
        // let node = SCNNode(geometry: SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0))
        // node.position = SCNVector3(0,0,-1)
        // node.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
        // self.sceneView.scene.rootNode.addChildNode(node)
    }
    
    
    // Function to Handle the Tap on the Box Node
    // UITapGestureRecognizer tells that there has been a tap on the screen in the scene view
    @objc func handleTap(sender: UITapGestureRecognizer){
        let sceneViewTappedOn = sender.view as! SCNView
        
        // Gives us the coordinates of where the user tapped on in the sceneView
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        
        // If you tap on an object in the sceneview, hittest gives the info of the object that you touched
        // If coordinates of where user touch on screen do not match with the object, hittest returns empty
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
        
        if hitTest.isEmpty{
            print("\nDidn't touch anything !!\n")
        }
        else{
            // Print the Type of Geometry Tapped On
            
            // print("\nHit Test Values: ",hitTest)
            // let results = hitTest.first
            // let hitnodeGeometry = results?.node.geometry
            // print(hitnodeGeometry)
            
            if countDown > 0{
            // Animate Node
            let results = hitTest.first
            let node = results?.node
            // Play the Animation only when the Animation Node Key is Empty
            if (node?.animationKeys.isEmpty)! {
                // Use a Scene Transaction to make sure the code is fully executed before removing the JellyFish Node
                SCNTransaction.begin()
                self.animateNode(node: node!)
                
                // once the transaction has completed, use the closure bloc to remove the node
                SCNTransaction.completionBlock = {
                    // remove node if it has been found and tapped at
                    node?.removeFromParentNode()
                    // add a new jellyfish Node
                    self.addNode()
                    // Restore Timer
                    self.restoreTimer()
                }
                SCNTransaction.commit()
            }
            print("\nTouched a JellyFish !!\n")
        }
        }
    }
    
    // Function to Animate JellyfISH nODE
    func animateNode(node: SCNNode) {
        let spin = CABasicAnimation(keyPath: "position")
        // presentation: current position of object in scene view
        spin.fromValue = node.presentation.position
        spin.toValue = SCNVector3(node.presentation.position.x - 0.2,node.presentation.position.y - 0.2 ,node.presentation.position.z - 0.2)
        spin.duration = 0.05
        spin.repeatCount = 5
        spin.autoreverses = true
        node.addAnimation(spin, forKey: "position")
    }
    
    // Function to get Random Numbers in a Range
    func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    // Function to set timer for game
    func setTimer() {
        self.timer.perform {() -> NextStep in
            self.countDown -= 1
            self.timerLabel.text = String(self.countDown)
            if self.countDown == 0 {
                self.timerLabel.text = String("You Lose !!")
                return .stop
            }
            return .continue
        }
    }
    
    // Function to restore the timer once game is done
    func restoreTimer(){
        self.countDown = 10
        self.timerLabel.text = String(self.countDown)
    }
}

