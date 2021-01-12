//
//  ViewController.swift
//  Demo
//
//  Created by 张金虎 on 2021/1/5.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    var faceNode = SCNNode()
    var leftEye = SCNNode()
    var rightEye = SCNNode()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        setupEyeNode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard ARFaceTrackingConfiguration.isSupported else { return }
        // Create a session configuration
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        // Run the view's session
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    func setupEyeNode(){

            //1. Create A Node To Represent The Eye
            let eyeGeometry = SCNSphere(radius: 0.005)
            eyeGeometry.materials.first?.diffuse.contents = UIColor.cyan
            eyeGeometry.materials.first?.transparency = 1

            //2. Create A Holder Node & Rotate It So The Gemoetry Points Towards The Device
            let node = SCNNode()
            node.geometry = eyeGeometry
            node.eulerAngles.x = -.pi / 2
        node.position.z = 0.1

            //3. Create The Left & Right Eyes
            leftEye = node.clone()
            rightEye = node.clone()

        }
    
   
}

extension ViewController: ARSCNViewDelegate{

//    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
//        let face = ARSCNFaceGeometry(device: sceneView.device!)
//        let node = SCNNode(geometry: face)
//        node.geometry?.firstMaterial?.fillMode = .lines
//        return node
//    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {

        //1. Setup The FaceNode & Add The Eyes
        faceNode = node
        faceNode.addChildNode(leftEye)
        faceNode.addChildNode(rightEye)
        faceNode.transform = node.transform

        //2. Get The Distance Of The Eyes From The Camera
        trackDistance()
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {

        faceNode.transform = node.transform

        //2. Check We Have A Valid ARFaceAnchor
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }

        //3. Update The Transform Of The Left & Right Eyes From The Anchor Transform
        leftEye.simdTransform = faceAnchor.leftEyeTransform
        rightEye.simdTransform = faceAnchor.rightEyeTransform

        //4. Get The Distance Of The Eyes From The Camera
        trackDistance()
    }


    /// Tracks The Distance Of The Eyes From The Camera
    func trackDistance(){

        DispatchQueue.main.async {

            //4. Get The Distance Of The Eyes From The Camera
            let leftEyeDistanceFromCamera = self.leftEye.worldPosition - SCNVector3Zero
            let rightEyeDistanceFromCamera = self.rightEye.worldPosition - SCNVector3Zero

            //5. Calculate The Average Distance Of The Eyes To The Camera
            let averageDistance = (leftEyeDistanceFromCamera.length() + rightEyeDistanceFromCamera.length()) / 2
            let averageDistanceCM = (Int(round(averageDistance * 100)))
            print("Approximate Distance Of Face From Camera = \(averageDistanceCM)")
        }
    }

}

extension SCNVector3{

    ///Get The Length Of Our Vector
    func length() -> Float { return sqrtf(x * x + y * y + z * z) }

    ///Allow Us To Subtract Two SCNVector3's
    static func - (l: SCNVector3, r: SCNVector3) -> SCNVector3 { return SCNVector3Make(l.x - r.x, l.y - r.y, l.z - r.z) }
}
