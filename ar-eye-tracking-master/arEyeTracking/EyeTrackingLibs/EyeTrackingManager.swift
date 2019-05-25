//
//  EyeTrackingManager.swift
//  arEyeTracking
//
//  Created by seungwook.jung on 2018. 8. 08..
//  Copyright © 2018년 NW. All rights reserved.
//

import Foundation
import ARKit
import UIKit


//MARK: 눈동자 추적에 대한 이벤트
@objc(NWEyeTrackingDelegate)
public protocol EyeTrackingDelegate: NSObjectProtocol {
    
    /**
     ARFaceAnchor로 감지된 사용자가 디바이스 화면을 바라보고있을때 발생하는 이벤트입니다.
     
     - Parameter state: 화면의 어느부분을 바라보고있는지 나타내줍니다.
     - Parameter scrollOffset: 이 값 만큼 스크롤을 시키면 자연스럽게 스크롤이 동작합니다.
     */
    @objc func didChange(lookAtPoint: CGPoint)
    
    /**
     눈동자 추적의 상태 변화에 대한 이벤트입니다.
     
     추적이 시작되었을때와 추적이 중단되었을때에 호출됩니다.
     */
    @objc func didChange(eyeTrackingState: EyeTrackingState)
}


/**
 현재 시점의 EyeTracking 상태를 나타냅니다.
 
 - tracking: EyeTracking이 정상적으로 동작중인 상태
 - notTracked: 초기상태 또는 시선정보가 없어 tracking이 아루어지고 있지 않은 상태
 */
@objc public enum EyeTrackingState: Int {
    /// EyeTracking이 정상적으로 동작중인 상태
    case tracking = 0
    /// 전면 카메라에 얼굴이 인식되지 않아 EyeTracking이 중단된 상태
    case notTracked = 1
}


/**
 TrueDepthCamera를 통해 사용자의 시선을 추적해 화면의 상단, 하단부를 바라보고 있는 상태를 감지합니다.
 
 라이브러리와 어플리케이션간의 통신은 모두 EyeTrackingManager를 통해 이루어집니다.
 - iOS 12.0 + , TrueDepthCamera 를 사용할수 있는 device에서 사용가능합니다.
 */
@objc(NWEyeTrackingManager)
public class EyeTrackingManager: NSObject {
    
    /**
     EyeTracking기능의 사용가능 여부를 나타냅니다.
     
     아래 조건을 만족하는 기기에서 사용 가능하며, true 를 반환합니다.
     - SW : iOS 12.0+
     - HW : TrueDepth Camera 를 지원하는 기기
     
     2018년 8월 현재 iPhoneX 기종만이 사용 가능합니다.
     */
    @objc public class var isSupported: Bool {
        get {
            if #available(iOS 12.0, *) {
                return ARFaceTrackingConfiguration.isSupported
            } else {
                return false
            }
        }
    }
    
    /**
     이 오브젝트는 EyeTreacking 에 대한 delegate 입니다.
     
     이 delegate는 EyeTrackingDelegate의 구현체가 할당되어야 합니다.
     */
    @objc public var delegate: EyeTrackingDelegate?
    
    private var trackingState: EyeTrackingState = .notTracked {
        didSet { testUtility.trackingState = trackingState }
    }
    
    private struct Constants {
        static let ERR_MESSAGE: String = "iOS 12 버전 이상, TrueDepthCamera 를 지원하는 디바이스에서만 사용가능합니다."
        static let TRACHING_STARTED: String = "추적이 시작되었습니다."
        static let TRACHING_STOPPED: String = "추적이 중단되었습니다."
        static let FUNC_NOT_DECLARED: String = "함수가 구현되지 않았습니다."
    }
    
    private var eyeLTransformBuffer: [simd_float4x4] = []
    private var eyeRTransformBuffer: [simd_float4x4] = []
    
    private var sessionManager: AnyObject?
    private var dataManager: AnyObject?
    
    private var portraitScreenSize: CGRect?
    private var screenSize = UIScreen.main.bounds
    
    private let testUtility = EyeTrackingTestUtility()
    
    /**
     EyeTrackingManager의 초기화 구문입니다.
    
     EyeTracking 기능의 사용 가능여부를 판단하여 사용가능 할 경우에 ARSession과 다른 EyeTracking을 위한 환경을 구성합니다.
     시선 추적 이벤트에 대한 처리를 위하서 EyeTrackingDelegate의 구현체가 할당되어야 합니다.
     */
    @objc public override init() {
        super.init()
        if #available(iOS 12.0, *) {
            if EyeTrackingManager.isSupported {
                self.dataManager = EyeTrackingDataManager()
                self.sessionManager = EyeTrackingSessionManager()
                if let sessionManager = self.sessionManager as? EyeTrackingSessionManager {
                    sessionManager.delegate = self
                }
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
            } else {
                print(Constants.ERR_MESSAGE)
            }
        } else {
            print(Constants.ERR_MESSAGE)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}


//MARK: 세션관리
extension EyeTrackingManager {
    /**
     EyeTracking을 위한 ARSession을 실행해 줍니다.
     
     ARFaceTrackingConfiguration, worldAlignment = .camera, isLightEstimationEnabled = false,
     options = [.resetTracking, .removeExistingAnchors] 의 환경으로 ARSession을 실행시켜 줍니다.
     EyeTracking기능을 사용하는 ViewController의 viewWillAppear() 에서 호출해 주는 것을 권장합니다.
     */
    @objc public func run() {
        if #available(iOS 12.0, *) {
            if EyeTrackingManager.isSupported {
                if let sessionManager = self.sessionManager as? EyeTrackingSessionManager {
                    sessionManager.run()
                }
            }
        }
    }
    
    /**
     EyeTracking을 위한 ARSession을 중단해 줍니다.
     
     EyeTracking기능을 사용하는 ViewController의 viewWillDisappear() 에서 호출해 주는 것을 권장합니다.
     */
    @objc public func pause() {
        if #available(iOS 12.0, *) {
            if EyeTrackingManager.isSupported {
                if let sessionManager = self.sessionManager as? EyeTrackingSessionManager {
                    sessionManager.pause()
                }
            }
        }
    }
}


//MARK: 라이브러리 외부에서 호출할 수 있는 함수들.
extension EyeTrackingManager {
    
    /**
     현재 EyeTracking 상태를 나타내기 위한 UILabel을 보여줍니다.
     
     ViewController의 viewDidLoad() 에서 다음과 같이 사용합니다.
     ```
     eyeTrackingManager.showStatusView(parent: self.view)
     ```
     - Parameter parent: UILabel을 붙여줄 부모 View를 지정합니다.
     */
    @objc public func showStatusView(parent: UIView) {
        self.testUtility.showStatusView(parent: parent)
    }
    
    /**
     현재 EyeTracking 상태를 나타내기 위한 CursorView를 보여줍니다.
     
     ViewController의 viewDidLoad() 에서 다음과 같이 사용합니다.
     ```
     eyeTrackingManager.showCursorView(parent: self.view)
     ```
     - Parameter parent: UILabel을 붙여줄 부모 View를 지정합니다. 이 때, 부모 View는 ViewController 의 view를 사용합니다.
     
     */
    @objc public func showCursorView(parent: UIView) {
        self.testUtility.showCursorView(parent: parent)
    }
    
    /**
     현재 EyeTracking 상태를 나타내기 위한 UILabel을 숨겨줍니다.
     */
    @objc public func hideStatusView() {
        self.testUtility.hideStatusView()
    }
    
    /**
     현재 EyeTracking 상태를 나타내기 위한 CursorView를 숨겨줍니다.
     */
    @objc public func hideCursorView() {
        self.testUtility.hideCursorView()
    }
}


//MARK: EyeTrackingSessionManagerDelegate 의 구현. 이벤트를 발생시켜줍니다.
@available(iOS 12.0, *)
extension EyeTrackingManager: EyeTrackingSessionManagerDelegate {
    
    func update(withFaceAnchor anchor: ARFaceAnchor) {
        guard let dataManager = self.dataManager as? EyeTrackingDataManager else {
            return
        }
        
        let lookAtPoint = dataManager.calculateEyeLookAtPoint(anchor: anchor)
        
        //ToDo: 순서가 중요합니다!
        self.findLookAt(with : lookAtPoint)
        self.checkTrackingState(withFaceAnchor: anchor)
        self.testUtility.updateTestViews(with: lookAtPoint)
    }
}


// MARK: orient 변화 관련 코드
extension EyeTrackingManager {
    
    @objc private func rotated() {
        guard let portraitScreenSize = portraitScreenSize else { return }
        
        switch UIDevice.current.orientation {
        case UIDeviceOrientation.portrait: fallthrough
        case UIDeviceOrientation.portraitUpsideDown:
            self.screenSize = portraitScreenSize
            break
        case UIDeviceOrientation.landscapeLeft: fallthrough
        case UIDeviceOrientation.landscapeRight:
            self.screenSize = CGRect.init(x: 0, y: 0, width: portraitScreenSize.height, height: portraitScreenSize.width)
            break
        default:
            // 이외의 경우 무시
            break
        }
        
        self.testUtility.screenSize = screenSize
        self.testUtility.rotated()
    }
    
}


//MARK: 이벤트 감지에 대한 코드
@available(iOS 12.0, *)
extension EyeTrackingManager {
    
    /// 어느부분을 바라보고있는지에 대한 이벤트 발생.
    private func findLookAt(with lookAtPoint: CGPoint) {
        // 추적이 동작하지 않는 상태에서는 return된다.
        if self.trackingState == .notTracked {
            return
        }
        
        
        guard let delegate = self.delegate else {
            return
        }
        
        
        if delegate.responds(to: #selector(EyeTrackingDelegate.didChange(lookAtPoint:))) {
            let x = max(-self.screenSize.width / 2, min(lookAtPoint.x, self.screenSize.width / 2))
            let y = max(-self.screenSize.height / 2, min(lookAtPoint.y, self.screenSize.height / 2))
            let point = CGPoint(x: self.screenSize.width / 2, y: self.screenSize.height / 2)
            let transformedPoint = point.applying(CGAffineTransform(translationX: x, y: y))
            
            delegate.didChange(lookAtPoint: transformedPoint)
        } else {
            print("didChange(eyeLookAtState:lookAtPoint:)  \(Constants.FUNC_NOT_DECLARED)")
        }
    }
    
    
    private func checkTrackingState(withFaceAnchor anchor: ARFaceAnchor) {
        let bufferSize = 6  // FPS 약 60, 약 0.1초 간격으로 체크될 수 있도록하였습니다.
        self.eyeLTransformBuffer.append(anchor.leftEyeTransform)
        self.eyeRTransformBuffer.append(anchor.rightEyeTransform)
        self.eyeLTransformBuffer = Array(self.eyeLTransformBuffer.suffix(bufferSize))
        self.eyeRTransformBuffer = Array(self.eyeRTransformBuffer.suffix(bufferSize))
        
        
        guard self.eyeLTransformBuffer.count >= bufferSize && self.eyeRTransformBuffer.count >= bufferSize else { return }
        guard let delegate = self.delegate else { return }
        let isTrackingStopped = self.eyeLTransformBuffer.isAllEqual! && self.eyeRTransformBuffer.isAllEqual!
        
        if isTrackingStopped && self.trackingState == .tracking {
            self.trackingState = .notTracked
            print(Constants.TRACHING_STOPPED)
            // 화면 sleep 되도록
            UIApplication.shared.isIdleTimerDisabled = false
        } else if !isTrackingStopped && self.trackingState == .notTracked {
            self.trackingState = .tracking
            print(Constants.TRACHING_STARTED)
            // 화면 sleep 되지 않도록
            UIApplication.shared.isIdleTimerDisabled = true
        } else {
            // 이외의 경우는 무시합니다.
        }
        
        if delegate.responds(to: #selector(EyeTrackingDelegate.didChange(eyeTrackingState:))) {
            delegate.didChange(eyeTrackingState: self.trackingState)
        } else {
            print("didChange(eyeTrackingState:)  \(Constants.FUNC_NOT_DECLARED)")
        }
    }
}



