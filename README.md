# EyeTracking-with-ARKit

ARKit 의 Face Tracking을 기반으로 사용자의 시선을 감지하고 추적하여 UI 컴포넌트 제어에 대해서 학습하는 공간입니다.

## Reference

본 글은 아래의 내용을 참고하여 작성하였습니다.
- [virakri/eye-tracking](https://github.com/virakri/eye-tracking-ios-prototype)  
- [raywenderlich ARKit tutorial](https://www.raywenderlich.com/5491-ar-face-tracking-tutorial-for-ios-getting-started)   
- [andrewzimmer906/HeatMapEyeTracking](https://github.com/andrewzimmer906/HeatMapEyeTracking)  


## Eye Tracking Basic

### 필요한 SCNNNode
  - FaceNode : 사용자의 얼굴을 tracking할 Node
  - Eye Node(Left, Right) : 사용자의 face에서 두눈을 Tracking 할 Node
  - TragetEyeNode : Phone View 에 targeting 될 즉 시선이 폰에 닿을 때의 Node
  - VirtualPhoneNode: 두 눈의 시선이 닿을 Phone위의 가상 Node
  - VirtualScreenNode: Phone위의 시선이 닿을 가상 Screen Node
  
### Session Configuration 생성

```swift
    	// Face Tracking을 위한 session Configuration 생성
 		guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("이 장치에서는 얼굴 추적 기능이 지원 되지 않습니다.")
        }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        
        // Run the view's session
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
```

`isSupported`를 통해 FaceTracking이 지원 되는 장치인지 우선 검사를 해야한다  
그후 `ARFaceTrackingConfiguration` 을 생성 하고 session을 실행시킨다


### SCNNode Layer

Setup SceneGraph (SCNNode 의 순서를 결정)  

<img width="872" alt="image" src="https://user-images.githubusercontent.com/33486820/56290022-37f27480-615d-11e9-9961-6fdd48282294.png">


```swift
        sceneView.scene.rootNode.addChildNode(faceNode)
        sceneView.scene.rootNode.addChildNode(virtualPhoneNode)
        virtualPhoneNode.addChildNode(virtualScreenNode)
        faceNode.addChildNode(leftEyeNode)
        faceNode.addChildNode(rightEyeNode)
        leftEyeNode.addChildNode(targetLeftEyeNode)
        rightEyeNode.addChildNode(targetRightEyeNode)
```

### ARSCNViewDelegate

- 새로운 `ARAnchor`가 추가될때 마다 호출 되는 함수

```swift
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        faceNode.transform = node.transform
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
 
        updateAnchor(withFaceAnchor: faceAnchor)
    }
```

기존의 faceNode의 trasform값 (**rotation, position, scale**) SCNMatrix에 새롭게 추가된 node의 transform값을 넣는다.
그 후 `ARFaceAnchor`의 값을 가지고 `updateAnchor()`를 호출한다.  


- `updateAnchor()`  

```swift
        leftEyeNode.simdTransform = anchor.leftEyeTransform
        rightEyeNode.simdTransform = anchor.rightEyeTransform
```

양눈의 변환 행렬 반환  
이 속성의 값을 설정하면 노드의 simdRotation, simdOrientation, simdEulerAngles, simdPosition 및 simdScale 속성이 새 변환과 일치하도록 자동으로 변경  

- `ARAnchor` 의 `EyeTransform` 

![image](https://user-images.githubusercontent.com/33486820/56290551-59079500-615e-11e9-8101-7354b9e49beb.png)

위의 사진은 왼쪽 눈 기준  (오른쪽 눈또한 동일 하다)  
- 파랑 : Z
- 초록 : Y
- 빨강 : X













