//
//  CGUtilities.swift
//  Pods
//
//  Created by Nikola Ristic on 7/18/17.
//
//

import Foundation
import GLKit

extension CGFloat {

    /// Normalizes the value to the interval [0, 1].
    /// - returns: Normalized value.
    func normalizeValue() -> CGFloat {
        if self < 0 {
            return self + 1
        } else if self > 1 {
            return self - 1
        } else {
            return self
        }
    }

    /// Converts value -1...1 (percent of the whole circle) to radians
    /// - returns: Radians
    func convertValueToRadians() -> CGFloat {
        return CGFloat(GLKMathDegreesToRadians(360) * Float(self))
    }

    /// Converts radians to value -1...1 (percent of the whole circle)
    /// - returns: Radians
    func convertRadiansToValue() -> CGFloat {
        return CGFloat(Float(self)/GLKMathDegreesToRadians(360))
    }

}
