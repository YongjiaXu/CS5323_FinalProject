//
//  SceneKitViewController.swift
//  Relax Your Neck
//
//  Created by xuan zhai on 12/11/21.
//

import UIKit
import SceneKit
import ARKit

protocol SceneKitViewControllerDelegate  : NSObject{
    func CatchResult(controller:SceneKitViewController, data:Int)
}


class SceneKitViewController: UIViewController, ARSCNViewDelegate, SCNSceneRendererDelegate{

    // A static variable for updating the position of nose
    static var charheight = CGFloat()
    static var scoreresult = 0
    var sceneView: ARSCNView!       // SceneKit is used for face tracking
    var delegate: SceneKitViewControllerDelegate?   // A delegate for passing data
    var sceneHeight = CGFloat()
    
    
    // Set up the game with SpriteKit
    func setSKScene(){
        if let scene = SNGameScene(fileNamed: "SNGameScene"){
            scene.scaleMode = .aspectFill
            scene.gamevc = self
            scene.size = self.view.bounds.size
            scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            self.sceneView.overlaySKScene = scene // Let it be overlaid on the ARSCNView
            sceneHeight = sceneView.frame.height
            SceneKitViewController.charheight = sceneHeight/2 // Initialize the position of nose
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView = ARSCNView(frame: UIScreen.main.bounds) // Set the size of ARSCNView
        self.view.addSubview(sceneView)
        guard ARFaceTrackingConfiguration.isSupported else { fatalError() }  // Prepare for face traking
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.contentMode = .scaleToFill
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        setSKScene()
        // Set the scene to the view
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARFaceTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)            // Start face tracking
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }


    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
    // Update the location of nose
    func updateFeatures(for node: SCNNode, using anchor: ARFaceAnchor){
        
        
        var v1 = SCNVector3(0, 0, 0)
        var v2 = SCNVector3(0, 0, 0)
        
        let child = node.childNode(withName: "nose", recursively: false)  // Find the nose
        
        let vertices = [anchor.geometry.vertices[9]]
        let newPos = vertices.reduce(vector_float3(), +) / Float(vertices.count)
        child?.position = SCNVector3(newPos)
        
        
        v1 = child?.boundingBox.min ?? v1
        v2 = child?.boundingBox.max ?? v2           // Get the bounding of the nose
    
        let v1w = child?.convertPosition(v1, to: sceneView.scene.rootNode)
        let v2w = child?.convertPosition(v2, to: sceneView.scene.rootNode)
        
        let v1p = sceneView.projectPoint(v1w!)
        let v2p = sceneView.projectPoint(v2w!)
        
        let avgheight = CGFloat(v2p.y + (v1p.y-v2p.y)/2) // Avg the bounding to get the mid point
        
        let newy = sceneHeight - avgheight // Since the size is started at top left, we need to convert it to the height that from bottom
        
        SceneKitViewController.charheight = newy  // Update the height of the nose
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        if(delegate != nil){        // Catch the result and send back
            let result = SceneKitViewController.scoreresult
            delegate?.CatchResult(controller: self, data: result)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}


extension SceneKitViewController{
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let faceAnchor = anchor as? ARFaceAnchor,
            let device = sceneView.device else{
            return nil
        }                               // Check if the device is supported
        let faceGeometry = ARSCNFaceGeometry(device: device)        // Get face geo
        let node = SCNNode(geometry: faceGeometry)
        node.geometry?.firstMaterial?.fillMode = .lines
        node.geometry?.firstMaterial?.transparency = 0.0
        let noseNode = SCNNode(geometry: SCNSphere(radius: 0.01))
        noseNode.physicsBody? = .static()
        noseNode.geometry?.firstMaterial?.transparency = 0.0
        noseNode.name = "nose"
        node.addChildNode(noseNode)                 // We need to track the nose, so add it as the child node
        
        updateFeatures(for: node, using: faceAnchor)  // Update that child
        
        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor,
              let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
                  return
              }
        faceGeometry.update(from: faceAnchor.geometry)
        updateFeatures(for: node, using: faceAnchor)
    }
}
