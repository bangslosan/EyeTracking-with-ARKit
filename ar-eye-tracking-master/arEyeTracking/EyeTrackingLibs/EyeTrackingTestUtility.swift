//
//  EyeTrackingDebugViewManager.swift
//  arEyeTracking
//
//  Created by seungwook.jung on 2018. 8. 08..
//  Copyright © 2018년 NW. All rights reserved.
//

import UIKit

class EyeTrackingTestUtility {
    
    internal var trackingState: EyeTrackingState = .notTracked
    internal var semaphore: Bool = false
    
    internal var screenSize = UIScreen.main.bounds
    
    private var portraitScreenSize: CGRect?
    
    private var cursorView: UIView?
    private var statusLabel: UILabel?
    private var upperAreaView: UIView?
    private var bottomAreaView: UIView?
    
    internal init(){
        // 세로방향의 디바이스 스크린 크기 지정
        if UIScreen.main.bounds.width < UIScreen.main.bounds.height {
            self.portraitScreenSize = UIScreen.main.bounds
        } else {
            self.portraitScreenSize = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width)
        }
    }
    
    internal func showStatusView(parent: UIView) {
        if self.statusLabel == nil {
            let label = UILabel(frame: CGRect(x: 50,
                                                    y: screenSize.height / 2 - 15,
                                                    width: screenSize.width - 50,
                                                    height: 30))
            
            label.textAlignment = NSTextAlignment.left
            label.text = ""
            parent.addSubview(label)
            
            self.statusLabel = label
        }
        
        self.statusLabel?.isHidden = false
    }
    
    internal func showCursorView(parent: UIView) {
        if self.cursorView == nil {
            let size = CGFloat(12)
            let view = UIView(frame: CGRect(x: self.screenSize.width / 2 - size / 2,
                                            y: self.screenSize.height / 2 - size / 2,
                                            width: size,
                                            height: size))
            view.layer.cornerRadius = size / 2
            view.layer.masksToBounds = true
            view.backgroundColor = UIColor.red
            parent.addSubview(view)
            
            self.cursorView = view
        }
        
        self.cursorView?.isHidden = false
    }
    
    /**
     현재 EyeTracking 상태를 나타내기 위한 UILabel을 숨겨줍니다.
     */
    internal func hideStatusView() {
        self.statusLabel?.isHidden = true
    }
    
    /**
     현재 EyeTracking 상태를 나타내기 위한 CursorView를 숨겨줍니다.
     */
    internal func hideCursorView() {
        self.cursorView?.isHidden = true
    }
    
    internal func updateTestViews(with lookAtPoint: CGPoint) {
        //self.updateStatusLabel(with: lookAtPoint)
        self.updateCursorView(with: lookAtPoint)
    }
    
//    internal func updateStatusLabel(with lookAtPoint: CGPoint) {
//        guard let statusLabel = statusLabel else { return }
//        let x = max(-self.screenSize.width / 2, min(lookAtPoint.x, self.screenSize.width / 2))
//        let y = max(-self.screenSize.height / 2, min(lookAtPoint.y, self.screenSize.height / 2))
//        let point = CGPoint(x: self.screenSize.width / 2, y: self.screenSize.height / 2)
//        let transformedPoint = point.applying(CGAffineTransform(translationX: x, y: y))
//
//        statusLabel.text = "x : \(transformedPoint.x), y : \(transformedPoint.y)"
//    }
    
    internal func updateCursorView(with lookAtPoint: CGPoint) {
        guard let cursorView = cursorView else { return }
        
        var x = max(-self.screenSize.width / 2, min(lookAtPoint.x, self.screenSize.width / 2))
        var y = max(-self.screenSize.height / 2, min(lookAtPoint.y, self.screenSize.height / 2))
        
        switch UIDevice.current.orientation {
        case UIDeviceOrientation.landscapeLeft:
            let tmp = x
            x = y
            y = -tmp
            
        case UIDeviceOrientation.landscapeRight:
            let tmp = x
            x = y
            y = tmp
            
        default:
            break
        }
        
        if trackingState == .notTracked {
            cursorView.transform = CGAffineTransform(translationX: 0, y: 0)
            return
        }
        
        cursorView.transform = CGAffineTransform(translationX: x, y: y)
    }
    
    
    internal func rotated(){
        // 화면 회전할때 커서의 origin 이 제대로 안잡히는 버그가 존재
        let size: CGFloat = 12
        self.cursorView?.frame.origin.x = (self.screenSize.width / 2) - (size / 2)
        self.cursorView?.frame.origin.y = (self.screenSize.height / 2) - (size / 2)
        
        
        self.statusLabel?.frame = CGRect(x: self.screenSize.width / 2,
                                         y: self.screenSize.height / 2,
                                         width: self.screenSize.width - 50,
                                         height: 30)
    }
}
