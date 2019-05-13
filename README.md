# EyeTracking-with-ARKit

ARKit 의 Face Tracking을 기반으로 사용자의 시선을 감지하고 추적하여 UI 컴포넌트 제어에 대해서 학습하는 공간입니다.

> P.S : iPad Pro 11인치를 사용하여 Face Tracking을 구현 하였습니다. iPhone과는 다소 차이가 있을 수 있습니다.  

</br>
<hr>

## Eye Tracking Basic

![KakaoTalk_Video_2019-04-23-20-55-16](https://user-images.githubusercontent.com/33486820/56579248-a5455000-660a-11e9-9b13-67085d470c8c.gif)


### 필요한 SCNNode
  - FaceNode : 사용자의 얼굴을 tracking할 Node
  - Eye Node(Left, Right) : 사용자의 face에서 두눈을 Tracking 할 Node
  - TragetEyeNode : Pad View 에 targeting 될 즉 시선이 Pad에 닿을 때의 Node
  - VirtualPadNode: 두 눈의 시선이 닿을 Phone위의 가상 Node
  - VirtualScreenNode: Pad위의 시선이 닿을 가상 Screen Node
  
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
        sceneView.scene.rootNode.addChildNode(virtualPadNode)
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

### HitTest 

두눈의 EyeNode와 TargetEyeNode 사이의 HitTest값을 Phone screen 의 사이즈에 맞게 좌표를 변환하고 실시간으로 Hitting 즉 시선이 스크린으로 향하는 지점의 좌표를 가져와서 Controll 하는 것이 목표이다. 

- 실시간으로 Hitting이되는 양쪽 눈의 시선의 x,y 중간값을 저장하는 배열을 선언한다.

```swift
    var eyeLookAtPositionXs: [CGFloat] = []
    var eyeLookAtPositionYs: [CGFloat] = []
```

- `hitTestWithSegment(from:to:options:)` 메서드를 통해 hitting 되는 결과값 `[SCNHitTestResult]`를 반환한다.

```swift
            let phoneScreenEyeRHitTestResults = self.virtualPhoneNode.hitTestWithSegment(from: self.lookAtTargetEyeRNode.worldPosition, to: self.eyeRNode.worldPosition, options: nil)
            
            let phoneScreenEyeLHitTestResults = self.virtualPhoneNode.hitTestWithSegment(from: self.lookAtTargetEyeLNode.worldPosition, to: self.eyeLNode.worldPosition, options: nil)
```            

- [hitTestWithSegment(from:to:options:)](https://developer.apple.com/documentation/scenekit/scnnode/1407998-hittestwithsegment)  

```swift
func hitTestWithSegment(from pointA: SCNVector3, 
                     to pointB: SCNVector3, 
                options: [String : Any]? = nil) -> [SCNHitTestResult]
```  

- pointA: 탐색 할 선분의 끝점이며 노드의 로컬 좌표계에 지정된다.
- pointB: 탐색 할 선분의 다른 끝점이며 노드의 로컬 좌표계에 지정된다.
- options: 검색에 영향을 미치는 옵션 Dictionary
- reuselt : 검색 결과를 나타내는 `SCNHitTestResult` 객체의 배열  

히트 테스트는 장면의 좌표 공간 (또는 장면의 특정 노드)에서 지정된 선분을 따라 위치한 장면의 요소를 찾는 프로세스이다. 예를 들어,이 방법을 사용하여 게임 캐릭터가 시작한 발사체가 목표를 공격하는지 여부를 결정할 수 있다.  

렌더링 된 이미지의 2 차원 점에 해당하는 장면 요소를 검색하려면, renderer의 hitTest (_ : options :) 메서드를 사용하면된다.

- Pad 스크린 위의 좌표를 계산하기위해 필요한 것들
	- 실제 디바이스의 크기와, point 값
    
    ```swift
        // 실제 iPad pro 11인치 의 물리적 크기 17.85 cm x 24.76cm
    	let padScreenSize = CGSize(width: 0.1785, height: 0.2476)
    	// 실제 iPad 11인치의 Point Size 1194×834 points
    	let padScreenPointSize = CGSize(width: 834, height: 1194)
    ```
    
    - `[SCNitTestResult]`의 값을 받아 실제 디바이스위 의 좌표계로 변환 하기 위해 변수 두개를 선언하여 변환 한 값을 대입한다.
    
    ```swift
        var leftEyeHittingAt = CGPoint()
        var rightEyeHittingAt = CGPoint()
	```
- 스크린 위의 targetingView의 이동을 위해 `DispatchQueue`를 사용한다 (UI의 변경 -> main)

``` swift
	DispatchQueue.main.async {
    
    	 self.setUpTargetPosition(left: leftEyeHittingAt, right: rightEyeHittingAt)
	}
```       

지속적으로 `setUpTargetPosition()` 메서드를 호출하면서 targetingView의 위치를 변경 시켜준다.

```swift
// Screen 위의 Eye Trarget Position에 따라 eyeTrackingPositionView를 이동한다.
    func setUpTargetPosition(left leftEyeHittingAt: CGPoint, right rightEyeHittingAt: CGPoint)  {
        // X,Y Point 가 유효하게 저장되는 임계점 상수 설정
        let smoothThresHoldNum = 10
        // 왼쪽과 오른쪽 시선의 중앙값을 성정
        self.eyeLookAtPositionXs.append((rightEyeHittingAt.x + leftEyeHittingAt.x) / 2)
        self.eyeLookAtPositionYs.append(-(rightEyeHittingAt.y + leftEyeHittingAt.y) / 2)
        // 10개 까지의 값만 
        self.eyeLookAtPositionXs = Array(self.eyeLookAtPositionXs.suffix(smoothThresHoldNum))
        self.eyeLookAtPositionYs = Array(self.eyeLookAtPositionYs.suffix(smoothThresHoldNum))
    
        let smoothEyeLookAtPositionX = self.eyeLookAtPositionXs.eyePositionEverage
        let smoothEyeLookAtPositionY = self.eyeLookAtPositionYs.eyePositionEverage
        
        // update indicator position
        self.eyePositionIndicatorView.transform = CGAffineTransform(translationX: smoothEyeLookAtPositionX!, y: smoothEyeLookAtPositionY!)
        
        self.eyeTargetPositionX.text = "\(Int(round(smoothEyeLookAtPositionX! + self.padScreenPointSize.width / 2)))"
        self.eyeTargetPsoitionY.text = "\(Int(round(smoothEyeLookAtPositionY! + self.padScreenPointSize.height / 2)))"
       
    }
```


## 문제점

- 시선 자체가 굉장히 불안정하고 그로인해 타겟팅이 어렵다.
- 좌,우 eyeNode의 평균값을 이용해서 타겟팅을 해보았지만 여전히 사용자얼굴과 디바이스 사이의 각도에 의해 추적이 잘 안되는 문제점이 있다. 
- 얼굴과 디바이스 사이각을 이용하여 시선을 아래로 보던가 정면으로 바라 보던가 할때를 보정해야한다.
- 베지어 곡선을 이용하여 targeting시의 오차를 줄이는 방법 사용
	- [iOS Bezier curves](https://github.com/SwiftArchitect/BezierCurveView)
	- [Bezier curves Basic](http://blog.naver.com/PostView.nhn?blogId=ratoa&logNo=220649189397)

<hr>
</br>

## Reference

본 글은 
- [virakri/eye-tracking](https://github.com/virakri/eye-tracking-ios-prototype)  
- [raywenderlich ARKit tutorial](https://www.raywenderlich.com/5491-ar-face-tracking-tutorial-for-ios-getting-started)   
- [andrewzimmer906/HeatMapEyeTracking](https://github.com/andrewzimmer906/HeatMapEyeTracking)  
내용을 참고하여 작성하였습니다.

