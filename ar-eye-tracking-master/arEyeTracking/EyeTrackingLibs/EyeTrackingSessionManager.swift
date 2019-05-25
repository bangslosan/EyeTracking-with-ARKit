//
//  EyeTrackingSessionManager.swift
//  arEyeTracking
//
//  Created by seungwook.jung on 2018. 8. 08..
//  Copyright © 2018년 NW. All rights reserved.
//

import ARKit

//MARK: EyeTrackingSessionManagerDelegate
@available(iOS 12.0, *)
protocol EyeTrackingSessionManagerDelegate {
    func update(withFaceAnchor: ARFaceAnchor)
}


//MARK: EyeTrackingSessionManager
@available(iOS 12.0, *)
internal class EyeTrackingSessionManager: NSObject {
    
    private struct Constants {
        static let ERR_MESSAGE_NOT_SUPPORTED : String = "NWEyeTracker : ARFaceTracking 이 지원되지 않는 기기입니다."
    }
    
    private var session: ARSession = ARSession()
    internal var delegate: EyeTrackingSessionManagerDelegate?
    
    internal func run() {
        self.session.delegate = self
        guard ARFaceTrackingConfiguration.isSupported else {
            print(Constants.ERR_MESSAGE_NOT_SUPPORTED)
            return
        }
        
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = false
        configuration.worldAlignment = .camera
        
        self.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    internal func pause() {
        self.session.pause()
    }
}


//MARK: ARSessionDelegate 구현
@available(iOS 12.0, *)
extension EyeTrackingSessionManager: ARSessionDelegate {

    internal func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors[0] as? ARFaceAnchor else { return }
        self.delegate?.update(withFaceAnchor: faceAnchor)
    }
    
    internal func session(_ session: ARSession, didFailWithError error: Error) {
        print(error)
    }
}
