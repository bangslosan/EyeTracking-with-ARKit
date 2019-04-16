# EyeTracking-with-ARKit

ARKit 의 Face Tracking을 기반으로 사용자의 시선을 감지하고 추적하여 UI 컴포넌트 제어에 대해서 학습하는 공간입니다.


### Eye Tracking Basic

- 필요한 SCNNNode
  - FaceNode : 사용자의 얼굴을 tracking할 Node
  - Eye Node(Left, Right) : 사용자의 face에서 두눈을 Tracking 할 Node
  - TragetEyeNode : Phone View 에 targeting 될 즉 시선이 폰에 닿을 때의 Node
  - VirtualPhoneNode: 두 눈의 시선이 닿을 Phone위의 가상 Node
  - VirtualScreenNode: Phone위의 시선이 닿을 가상 Screen Node

- SCNNode Layer

```swift
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
```        
