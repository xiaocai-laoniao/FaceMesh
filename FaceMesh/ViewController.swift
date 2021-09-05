//
//  ViewController.swift
//  FaceMesh
//
//  Created by ChildhoodAndy on 2021/9/4.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var labelContainer: UIView!
    @IBOutlet var switchButton: UIButton!
    var analysis = ""
    
    var sketch: MyFaceSketch?
    var layer: CALayer?
    let configuration = ARFaceTrackingConfiguration()
    
    var sketchMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSketch()
        
        configuration.isLightEstimationEnabled = true
        
        sceneView.delegate = self
        sceneView.showsStatistics = false
        
        descLabel.text = ""
        
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("设备不支持AR人脸追踪")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    @IBAction func switchButtonClickHandler(_ sender: Any) {
        sketchMode = !sketchMode
        sceneView.session.run(configuration, options: [.resetTracking])
    }
    
    func initSketch() {
        sketch = MyFaceSketch()
        sketch!.isFaceFill = false
        sketch!.frame = self.view.bounds
        sketch!.sketchDelegate?.setup()
        sketch!.layer.bounds = self.view.bounds
        
        sceneView.delegate = self
        sceneView.showsStatistics = false
        
        layer = sketch!.layer
        layer?.isHidden = true
        self.view.addSubview(sketch!)
        
        self.view.bringSubviewToFront(switchButton)
    }

    // MARK: ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if sketchMode {
            let faceMesh = ARSCNFaceGeometry(device: sceneView.device!, fillMesh: sketch!.isFaceFill)
            
            let newMaterial = SCNMaterial()
            newMaterial.isDoubleSided = true
            layer?.isHidden = false
            newMaterial.diffuse.contents = layer!
            let scaleVal = SCNMatrix4MakeScale(0.5, 0.5, 0.5)
            newMaterial.diffuse.contentsTransform = scaleVal
            
            let node = SCNNode(geometry: faceMesh)
            node.geometry?.materials = [newMaterial]
            node.geometry?.firstMaterial?.fillMode = .fill
            
            return node
        } else {
            let faceMesh = ARSCNFaceGeometry(device: sceneView.device!)
            let node = SCNNode(geometry: faceMesh)
            node.geometry?.firstMaterial?.fillMode = .lines
            return node
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry {
            faceGeometry.update(from: faceAnchor.geometry)
            expression(anchor: faceAnchor)

            DispatchQueue.main.async {
                self.descLabel.text = self.analysis
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        print(error)
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("session was interrunpted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("session interruption ended")
    }
    
    func expression(anchor: ARFaceAnchor) {
        let eyeBlinkLeft = anchor.blendShapes[.eyeBlinkLeft]
        let eyeBlinkLeftValue = eyeBlinkLeft?.decimalValue ?? 0.0
        
        let eyeBlinkRight = anchor.blendShapes[.eyeBlinkRight]
        let eyeBlinkRightValue = eyeBlinkRight?.decimalValue ?? 0.0
        
        let smileLeft = anchor.blendShapes[.mouthSmileLeft]
        let smileLeftValue = smileLeft?.decimalValue ?? 0.0
        
        let smileRight = anchor.blendShapes[.mouthSmileRight]
        let smileRightValue = smileRight?.decimalValue ?? 0.0
        
        let cheekPuff = anchor.blendShapes[.cheekPuff]
        let cheekPuffValue = cheekPuff?.decimalValue ?? 0.0
        
        let tongue = anchor.blendShapes[.tongueOut]
        let tongueValue = tongue?.decimalValue ?? 0.0
        
        self.analysis = ""
        
        print("eyeBlinkLeft: \(eyeBlinkLeftValue)")
        print("eyeBlinkRight: \(eyeBlinkRightValue)")
        print("smileLeftValue: \(smileLeftValue)")
        print("smileRightValue: \(smileRightValue)")
        print("cheekPuffValue: \(cheekPuffValue)")
        print("tongueValue: \(tongueValue)")
        
        if eyeBlinkLeftValue > 0.45 {
            self.analysis += " 你眨左眼睛了"
        }
        
        if eyeBlinkRightValue > 0.45 {
            self.analysis += " 你眨右眼睛了"
        }
        
        if smileLeftValue + smileRightValue > 0.9 {
            self.analysis += " 你笑了"
        }
        
        if cheekPuffValue > 0.1 {
            self.analysis += " 你的腮帮子鼓起来了"
        }
        
        if tongueValue > 0.1 {
            self.analysis += " 你的舌头👅伸出来了"
        }
    }
}

