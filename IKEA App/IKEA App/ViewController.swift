//
//  ViewController.swift
//  IKEA App
//
//  Created by Anuj Dutt on 11/14/17.
//  Copyright © 2017 Anuj Dutt. All rights reserved.
//

import UIKit
import ARKit
class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ARSCNViewDelegate {
    
    @IBOutlet weak var planeDetected: UILabel!
    let itemsArray: [String] = ["cup","vase","boxing","table"]
    @IBOutlet weak var itemsCollectionView: UICollectionView!
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    var selectedItem: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,ARSCNDebugOptions.showFeaturePoints]
        self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
        // Runs the Function to configure cell in a Collection View
        self.itemsCollectionView.dataSource = self
        // Runs the function to turn the selected cell to Green
        self.itemsCollectionView.delegate = self
        self.sceneView.delegate = self
        self.registerGestureRecognizers()
        // Add Omnidirectional Light 
        self.sceneView.autoenablesDefaultLighting = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // How many cells the colection displays
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsArray.count
    }

    // Configures every single source cell in collection view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! itemCell
        // Shows the Values from Array to Text Label
        cell.itemLabel.text = self.itemsArray[indexPath.row]
        return cell
    }

    // Function to turn the label to green when the item is selected
    // This function gets triggered whenever we select a cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        self.selectedItem = itemsArray[indexPath.row]
        cell?.backgroundColor = UIColor.green
    }
    
     // Function to change the cell color back to normal on deselction
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.orange
    }
    
    // Recognize Horizontal Plane
    // Recognize Zoom in/out
    // Long Press: to rotate object about its axis
    func registerGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        longPressGestureRecognizer.minimumPressDuration = 0.1
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        self.sceneView.addGestureRecognizer(pinchGestureRecognizer)
        self.sceneView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    // Function to Detect Tap
    @objc func tapped(sender: UITapGestureRecognizer){
        // Find out the tap only on the horizontal surface found in Scene View
        let sceneView = sender.view as! ARSCNView
        let tapLocation = sender.location(in: sceneView)
        // Match the location of tap with the location of the Horizontal Plane
        // Checks that the location of tap "tapLocation" matches the location of plane "existingPlaneUsingExtent"
        // If the tap is on plane, the hitTest array will have result values or else it'll be empty
        let hitTest = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        if !hitTest.isEmpty{
            // print("Touched a Horizontal Surface !!")
            self.addItem(hitTestResult: hitTest.first!)
        }
        // else{
           //  print("Tapped somewhere else in the Scene !!")
        // }
    }
    
    // Function to Zoom in or Zoom out the Objects
    @objc func pinch(sender: UIPinchGestureRecognizer){
        let sceneView = sender.view as! ARSCNView
        let pinchLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(pinchLocation)
        if !hitTest.isEmpty{
            let results = hitTest.first
            let node = results?.node
            let pinchAction = SCNAction.scale(by: sender.scale, duration: 0)
            // print(sender.scale)
            node?.runAction(pinchAction)
            sender.scale = 1.0
        }
    }
    
    // Function to detect Long Press
    // If Long Press: Rotate Object
    @objc func longPress(sender: UILongPressGestureRecognizer){
        let sceneView = sender.view as! ARSCNView
        // Get location of Holding in Scene View
        let holdLocation = sender.location(in: sceneView)
        // Check If location of holding matches the location of the object placed in scene view
        let hitTest = sceneView.hitTest(holdLocation)
        if !hitTest.isEmpty{
            // If holding, rotate the object node
            let results = hitTest.first
            // let node = results?.node
            
            // If currently pressing in scene view
            if sender.state == .began{
                // Rotate the Object along y axis 360 degrees
                let nodeAction = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 1)
                // Keep on Rotating
                let forever = SCNAction.repeatForever(nodeAction)
                results?.node.runAction(forever)
                print("Holding")
            }
            else if sender.state == .ended{
                // Stop rotation when no long hold
                results?.node.removeAllActions()
                print("Released")
            }
        }
    }
    
    // Function to Place items on a Horizontal Surface
    func addItem(hitTestResult: ARHitTestResult){
        if let selectedItem = self.selectedItem {
            // When Plane is detected, place the object on that
            let scene = SCNScene(named: "Models.scnassets/\(selectedItem).scn")
            let node = (scene?.rootNode.childNode(withName: selectedItem,recursively:false))!
            // Get transform matrix to get the values to place objects right on top of horzontal surface detected
            let transform = hitTestResult.worldTransform
            // Position of detected surface is in 3rd column of transform matrix
            let thirdColumn = transform.columns.3
            // Position the Object node right where the detected surface is
            node.position = SCNVector3(thirdColumn.x,thirdColumn.y,thirdColumn.z)
            // Rotate Table around itself
            if selectedItem == "table"{
                self.centerPivot(for: node)
            }
            self.sceneView.scene.rootNode.addChildNode(node)
        }
    }
    
    // Check if Plane Anchor Detected or not
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {return}
        // Run this code on the main Thread
        DispatchQueue.main.async {
            // If Plane detected, unhide the planeLabel and show "Plane Detected"
            self.planeDetected.isHidden = false
            // After 3 seconds, hide the label again
            DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                self.planeDetected.isHidden = true
                }
        }
    }
    
    // Function to make Table rotate along y-axis
    func centerPivot(for node: SCNNode) {
        let min = node.boundingBox.min
        let max = node.boundingBox.max
        node.pivot = SCNMatrix4MakeTranslation(
            min.x + (max.x - min.x)/2,
            min.y + (max.y - min.y)/2,
            min.z + (max.z - min.z)/2
        )
    }
}

extension  Int {
    var degreesToRadians: Double {return Double(self) * .pi/180}
}
