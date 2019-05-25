## iOS ARKit을 활용한 시선추적
### ARKit의 EyeTracking을 활용하여 어떤 것을 할까?
- NaverWetoon ;) https://youtu.be/t75ZZHF90qQ
- HawkEye Access https://itunes.apple.com/kr/app/hawkeye-access/id1439231627?mt=8

### Apple ARKit의 ARFaceAnchor
- Use [ARFaceAnchor's EyeTransform](https://developer.apple.com/documentation/arkit/arfaceanchor)

### 문제점은?
- 생각보다 사람의 시선은 굉장히 떨리고, 이 때문에 시선을 통한 타겟팅이 어렵다.
- 얼굴과 디바이스의 사이각에 따라 시선 인식률이 굉장히 저하된다.
- 시선 인식에 개인차가 커서 교정작업(Calibration)이 필요하다.

### 우리의 목표는?
- 다양한 방법(평균값 구하기, 이동제한, 선형대수, 베지어곡선...)으로 시선값을 보정하여 **최대한** 자연스럽고 정확한 시선 데이터를 도출
- 얼굴과 디바이스의 사이각을 구해서, 각도에 따른 시선값을 보정하기
- 위의 두 가지를 활용하여 사용자별로 교정작업이 필요없도록 만들기
- (도전과제)위의 기능을 UI 컴포넌트에서 쓸 수 있게 인터페이스를 구현

### 레퍼런스
- https://developer.apple.com/documentation/arkit/arfaceanchor
- https://github.com/andrewzimmer906/HeatMapEyeTracking/tree/master
- https://stackoverflow.com/questions/53352476/how-can-i-get-the-yaw-pitch-roll-of-an-aranchor-in-absolute-terms

### 샘플코드
``` swift
import Foundation
import ARKit

class EyeTrackingDataManager {

    // 실제 디바이스 사이즈 (미터단위)
    private let phoneScreenSize = CGSize(width: 0.0623908297, height: 0.135096943231532)

    private let screenSize: CGRect = UIScreen.main.bounds
    private let smoothingThreshold: Int = 8

    private var scene: SCNScene = SCNScene()
    private var faceNode : SCNNode = SCNNode()
    private var eyeLNode : SCNNode = SCNNode()
    private var eyeRNode : SCNNode = SCNNode()
    private var virtualPhoneNode: SCNNode = SCNNode()
    private var lookAtTargetEyeLNode: SCNNode = SCNNode()
    private var lookAtTargetEyeRNode: SCNNode = SCNNode()

    private var eyeLookAtPositionXs: [CGFloat] = []
    private var eyeLookAtPositionYs: [CGFloat] = []

    private var virtualScreenNode: SCNNode = {
        let parentNode = SCNNode()
        let node = SCNNode()
        let geometry =  SCNBox(width: 1, height: 1, length: 0.001, chamferRadius: 0)
        
        node.geometry = geometry
        parentNode.addChildNode(node)
        
        return parentNode
    }()

    public init() {
        self.lookAtTargetEyeLNode.position.z = 2
        self.lookAtTargetEyeRNode.position.z = 2

        self.eyeLNode.addChildNode(lookAtTargetEyeLNode)
        self.eyeRNode.addChildNode(lookAtTargetEyeRNode)

        self.faceNode.addChildNode(eyeLNode)
        self.faceNode.addChildNode(eyeRNode)

        self.virtualPhoneNode.addChildNode(virtualScreenNode)

        self.scene.rootNode.addChildNode(faceNode)
        self.scene.rootNode.addChildNode(virtualPhoneNode)
    }

    @available(iOS 12.0 , *)
    func calculateEyeLookAtPoint(anchor: ARFaceAnchor) -> CGPoint {
        self.faceNode.simdTransform = anchor.transform
        self.eyeLNode.simdTransform = anchor.leftEyeTransform
        self.eyeRNode.simdTransform = anchor.rightEyeTransform

        let phoneScreenEyeLHitTestResults = virtualScreenNode.hitTestWithSegment(from: self.lookAtTargetEyeLNode.worldPosition,
                                                                                 to: self.eyeLNode.worldPosition,
                                                                                 options: nil)
        let phoneScreenEyeRHitTestResults = virtualScreenNode.hitTestWithSegment(from:self.lookAtTargetEyeRNode.worldPosition,
                                                                                 to: self.eyeRNode.worldPosition,
                                                                                 options: nil)
        
        var eyeLLookAt = CGPoint()
        for result in phoneScreenEyeLHitTestResults {
            eyeLLookAt.x = CGFloat(result.worldCoordinates.x)
            eyeLLookAt.y = CGFloat(result.worldCoordinates.y)
        }

        self.eyeLookAtPositionXs.append((eyeRLookAt.y + eyeLLookAt.y) / 2)
        self.eyeLookAtPositionXs = Array(self.eyeLookAtPositionXs.suffix(smoothingThreshold))
        
        self.eyeLookAtPositionYs.append((eyeRLookAt.x + eyeLLookAt.x) / 2)
        self.eyeLookAtPositionYs = Array(self.eyeLookAtPositionYs.suffix(smoothingThreshold))
        
        let smoothEyeLookAtPositionX = self.eyeLookAtPositionXs.average!
        let smoothEyeLookAtPositionY = self.eyeLookAtPositionYs.average!
        
        let x = smoothEyeLookAtPositionX / (self.phoneScreenSize.width / 2) * self.screenSize.width
        let y = smoothEyeLookAtPositionY / (self.phoneScreenSize.height / 2) * self.screenSize.height

        return CGPoint.init(x: x, y: y)
    }
}
```

