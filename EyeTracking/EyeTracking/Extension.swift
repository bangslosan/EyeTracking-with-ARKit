//
//  Extension.swift
//  EyeTracking
//
//  Created by youngjun goo on 22/04/2019.
//  Copyright © 2019 youngjun goo. All rights reserved.
//

import Foundation
import UIKit


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
