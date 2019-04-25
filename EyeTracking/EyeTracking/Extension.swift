//
//  Extension.swift
//  EyeTracking
//
//  Created by youngjun goo on 22/04/2019.
//  Copyright © 2019 youngjun goo. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension SCNVector3 {
    func length() -> Float {
        return sqrtf(x * x + y * y + z * z)
    }
}

func - (l: SCNVector3, r: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(l.x - r.x, l.y - r.y, l.z - r.z)
}

extension Collection where Element == CGFloat, Index == Int {
    var eyePositionEverage: CGFloat? {
        guard !isEmpty else {
            return nil
        }
        let sum = reduce(CGFloat(0)) { first, second -> CGFloat in
            return first + second
        }
        
        return sum / CGFloat(count)
    }
}

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

