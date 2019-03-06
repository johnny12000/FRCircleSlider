//
//  CALayer+Helpers.swift
//  FRCircleSlider
//
//  Created by Nikola Ristic on 3/6/19.
//

import Foundation

extension CALayer {

    /// Creates a layer with enpoint dot.
    /// - parameter color:     Color of the dot
    /// - parameter radius:    Radius of the dot
    /// - parameter lineWidth: Line width of the dot
    /// - returns: CALayer object with the dot
    class func drawDot(color: UIColor, radius: CGFloat, lineWidth: CGFloat) -> CALayer {
        let pathBottom = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: radius, height: radius))
        let layer = CAShapeLayer()
        layer.lineWidth = lineWidth
        layer.path = pathBottom.cgPath
        layer.strokeStart = 0
        layer.strokeEnd = 1
        layer.lineCap = CAShapeLayerLineCap(rawValue: "round")
        layer.strokeColor = color.cgColor
        layer.fillColor = color.cgColor
        layer.shadowColor = UIColor.clear.cgColor
        layer.shadowRadius = 0
        layer.shadowOpacity = 0
        layer.shadowOffset = CGSize.zero
        layer.frame = pathBottom.bounds
        return layer
    }

    /// Creates a layer with the connector object
    /// - parameter difference: Difference between start and stop endpoints of the connector. Value in radians.
    /// - parameter radius:     Radius of the arc of the connector
    /// - parameter color:      Color of the connector
    /// - parameter width:      Line width of the connector
    /// - returns: CALayer object with the connector
    class func drawConnector(difference: CGFloat, radius: CGFloat, color: UIColor, width: CGFloat) -> CAShapeLayer {
        let pathBottom = UIBezierPath(
            ovalIn: CGRect(x: -radius/2, y: -radius/2, width: radius, height: radius))
        let connector = CAShapeLayer()
        connector.lineWidth = width
        connector.path = pathBottom.cgPath
        connector.strokeStart = 0
        connector.strokeEnd = difference
        connector.lineCap = CAShapeLayerLineCap(rawValue: "round")
        connector.strokeColor = color.cgColor
        connector.fillColor = UIColor.clear.cgColor
        connector.shadowColor = UIColor.black.cgColor
        connector.shadowRadius = 0
        connector.shadowOpacity = 0
        connector.shadowOffset = CGSize.zero
        return connector
    }

    /// Creates a layer with progress back circle.
    /// - parameter bounds: Rectangle of the progress background
    /// - parameter radius: Radius of the progress background
    /// - parameter width: Line width of the progress background
    /// - parameter color: Color of the progress background line
    /// - returns: CALayer with progress background
    class func drawProgressBackCircle(bounds: CGRect, radius: CGFloat, width: CGFloat, color: UIColor) -> CALayer {
        let pathBottom = UIBezierPath(
            ovalIn: CGRect(x: (bounds.midX - (radius/2)),
                           y: (bounds.midY - (radius/2)),
                           width: radius,
                           height: radius))
        let arc = CAShapeLayer()
        arc.lineWidth = width
        arc.path = pathBottom.cgPath
        arc.strokeStart = 0
        arc.strokeEnd = 1
        arc.lineCap = CAShapeLayerLineCap(rawValue: "round")
        arc.strokeColor = color.cgColor
        arc.fillColor = UIColor.clear.cgColor
        arc.shadowColor = UIColor.clear.cgColor
        arc.shadowRadius = 0
        arc.shadowOpacity = 0
        arc.shadowOffset = CGSize.zero

        return arc
    }

}
