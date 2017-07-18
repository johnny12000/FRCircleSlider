//
//  CGUtilities.swift
//  Pods
//
//  Created by Nikola Ristic on 7/18/17.
//
//

import Foundation

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

}
