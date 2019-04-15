//
//  ViewController.swift
//  EyeTracking
//
//  Created by youngjun goo on 12/04/2019.
//  Copyright © 2019 youngjun goo. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import WebKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var selectLabel: UILabel!
    @IBOutlet weak var eyePositionIndicatorView: UIView!
    @IBOutlet weak var eyeTrackingPositionView: UIView!
    
    

    var btnList: [UIButton] = [UIButton]()
    
    var faceNode: SCNNode = SCNNode()
    
    var leftEyeNode: SCNNode = {
        // 1. set Geometry "Cone"
        let geometry = SCNCone(topRadius: 0.005, bottomRadius: 0, height: 0.1)
        /// Cone 주의의 부드러운 곡선의 정도를 설정(기본 = 48, 최소 = 3)
        geometry.radialSegmentCount = 3
        geometry.firstMaterial?.diffuse.contents = UIColor.red
        // 2. SCNNode 생성후 geometry 설정
        let eyeNode = SCNNode()
        eyeNode.geometry = geometry
        eyeNode.eulerAngles.x = -.pi / 2
        // 초기위치
        eyeNode.position.z = 0.1
        let parentNode = SCNNode()
        parentNode.addChildNode(eyeNode)
        return parentNode
    }()
    
    var rightEyeNode: SCNNode = {
        // 1. set Geometry "Cone"
        let geometry = SCNCone(topRadius: 0.005, bottomRadius: 0, height: 0.1)
        /// Cone 주의의 부드러운 곡선의 정도를 설정(기본 = 48, 최소 = 3)
        geometry.radialSegmentCount = 3
        geometry.firstMaterial?.diffuse.contents = UIColor.red
        // 2. SCNNode 생성후 geometry 설정
        let eyeNode = SCNNode()
        eyeNode.geometry = geometry
        eyeNode.eulerAngles.x = -.pi / 2
        // 초기위치
        eyeNode.position.z = 0.1
        let parentNode = SCNNode()
        parentNode.addChildNode(eyeNode)
        return parentNode
    }()
    
    // Phone View에 타겟팅 될 SCNNode
    var targetLeftEyeNode: SCNNode = SCNNode()
    var targetRightEyeNode: SCNNode = SCNNode()
    
    // 각각의 eyeNode가 targeting 될 Phone의 가상 SCNNode
    var virtualPhoneNode: SCNNode = SCNNode()
    
    // Phone Screen 위의 가상 SCNNode
    var virtualScreenNode: SCNNode = {
        let screenGeometry = SCNPlane(width: 1, height: 1)
        // SceneKit이 표면의 앞면과 뒷면을 렌더링 해야하는지 여부를 결정
        screenGeometry.firstMaterial?.isDoubleSided = true
        screenGeometry.firstMaterial?.diffuse.contents = UIColor.green
        let vsNode = SCNNode()
        vsNode.geometry = screenGeometry
        return vsNode
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the button Array
        self.btnList = [self.button1, self.button2, self.button3, self.button4]
        
        
        // Set the SceneView's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        // 자동으로 SCNLight 생성 여부를 결정
        sceneView.automaticallyUpdatesLighting = true
        
        // Setup SceneGraph (SCNNode 의 순서를 결정)
        /// rootNode -> faceNode -> leftEyeNode -> targetLeftEyeNode
        ///                      -> rightEyeNode -> targetRightEyeNode
        ///          -> virtualPhoneNode -> virtualScreenNode
        sceneView.scene.rootNode.addChildNode(faceNode)
        sceneView.scene.rootNode.addChildNode(virtualPhoneNode)
        virtualPhoneNode.addChildNode(virtualScreenNode)
        faceNode.addChildNode(leftEyeNode)
        faceNode.addChildNode(rightEyeNode)
        leftEyeNode.addChildNode(targetLeftEyeNode)
        rightEyeNode.addChildNode(targetRightEyeNode)
        
        // Screen에 targeting ehlf
        
        
    }
}
