//
//  FRCircleSlider.swift
//
//  Created by Nikola Ristic on 2/28/16.
//  Copyright © 2016 nr. All rights reserved.
//

import UIKit
import GLKit

@IBDesignable
open class FRCircleSlider: UIControl {

    @IBInspectable public var selectedColor: UIColor = UIColor.blue
    @IBInspectable public var firstDotColor: UIColor = UIColor.gray
    @IBInspectable public var secondDotColor: UIColor = UIColor.gray
    @IBInspectable public var connectorColor: UIColor = UIColor.yellow

    var circleRadius: CGFloat = 250
    var lineWidth: CGFloat = 1
    var circleWidth: CGFloat = 3
    var connectorWidth: CGFloat = 10
    var lineHeight: CGFloat = 10
    let arcRadius: CGFloat = 30

    var touchBegin: CGPoint?

    public var value1: CGFloat = 0.1 {
        willSet(value) {
            if value != value1 {
                angle = value.convertValueToRadians()
                rotateMovingView()
            }
        }
    }

    public var value2: CGFloat = 0.5

    var dot1Layer: CALayer!
    var dot2Layer: CALayer!
    var connectorLayer: CAShapeLayer!
    var movingView: UIView!
    var angle: CGFloat = 0.0

    var hapticGenerator: NSObject?

    var endpointsDifference: CGFloat {
        return (value2 - value1).normalizeValue()
    }

    // MARK: - Initialization

    override public init(frame: CGRect) {
        super.init(frame: frame)
        controlSetup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        controlSetup()
    }

    func controlSetup() {
        movingView = UIView(frame: frame)
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        movingView.isUserInteractionEnabled = false
        movingView.translatesAutoresizingMaskIntoConstraints = false
        movingView.clipsToBounds = true
        addSubview(movingView)
        bringSubview(toFront: movingView)
        addConstraints([
            movingView.widthAnchor.constraint(equalTo: widthAnchor),
            movingView.heightAnchor.constraint(equalTo: heightAnchor),
            movingView.centerXAnchor.constraint(equalTo: centerXAnchor),
            movingView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        if #available(iOS 10, *) {
            hapticGenerator = UISelectionFeedbackGenerator()
        }
    }

    override open func layoutSubviews() {
        calculateElementSizes()
        super.layoutSubviews()
    }

    // MARK: - Tracking user actions

    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard dot1Layer != nil, dot2Layer != nil, connectorLayer != nil else { return false }
        let val = touch.location(in: movingView)
        //Funky calculation of connector layer frame...it works...somehow
        let rect = CGRect(x: min(dot1Layer.frame.origin.x, dot2Layer.frame.origin.x),
                          y: min(dot1Layer.frame.origin.y, dot2Layer.frame.origin.y),
                          width: connectorLayer.path!.boundingBoxOfPath.width,
                          height: connectorLayer.path!.boundingBoxOfPath.height)

        if dot1Layer.frame.contains(val) || dot2Layer.frame.contains(val) || rect.contains(val) {
            touchBegin = val
        } else {
            touchBegin = nil
        }
        super.beginTracking(touch, with: event)
        return touchBegin != nil
    }

    override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        touchBegin = nil
    }

    override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        if touchBegin != nil {
            let val = touch.location(in: self)
            getViewAngle(val)
            rotateMovingView()
            recalculate()
            if #available(iOS 10, *) {
                //(hapticGenerator as? UISelectionFeedbackGenerator)?.selectionChanged()
            }
            self.sendActions(for: UIControlEvents.valueChanged)
        }
        return super.continueTracking(touch, with: event)
    }

    // MARK: - Draw elements

    override open func draw(_ rect: CGRect) {
        super.draw(rect)

        let progressLayer = drawProgressBackCircle(rect)

        let dotOffsetAngle = CGFloat(0.15)

        connectorLayer = drawConnector(rect)
        let connectorAngle = CGFloat(GLKMathDegreesToRadians(-90))
        rotateConnector(connectorLayer, forAngle: connectorAngle)
        dot1Layer = drawDot(0, rect: rect, color: firstDotColor)
        rotateDot(dot1Layer, forAngle: dotOffsetAngle)
        let secondDotAngle = endpointsDifference.convertValueToRadians() + dotOffsetAngle
        dot2Layer = drawDot(secondDotAngle, rect: rect, color: secondDotColor)
        rotateDot(dot2Layer, forAngle: secondDotAngle)

        layer.addSublayer(progressLayer)

        movingView.layer.addSublayer(connectorLayer)
        movingView.layer.addSublayer(dot1Layer)
        movingView.layer.addSublayer(dot2Layer)
        bringSubview(toFront: movingView)
        rotateMovingView()
    }

    @discardableResult
    func drawDot(_ angle: CGFloat, rect: CGRect, color: UIColor) -> CALayer {
        let pathBottom = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: arcRadius, height: arcRadius))

        let layer = CAShapeLayer()
        layer.lineWidth = lineWidth
        layer.path = pathBottom.cgPath
        layer.strokeStart = 0
        layer.strokeEnd = 1
        layer.lineCap = "round"
        layer.strokeColor = color.cgColor
        layer.fillColor = color.cgColor
        layer.shadowColor = UIColor.clear.cgColor
        layer.shadowRadius = 0
        layer.shadowOpacity = 0
        layer.shadowOffset = CGSize.zero
        layer.frame = pathBottom.bounds

        return layer
    }

    @discardableResult
    func drawConnector(_ rect: CGRect) -> CAShapeLayer {
        let diff = endpointsDifference

        let arcRadius: CGFloat = circleRadius
        let color = connectorColor
        let pathBottom = UIBezierPath(
            ovalIn: CGRect(x: -arcRadius/2, y: -arcRadius/2, width: arcRadius, height: arcRadius))

        let connector = CAShapeLayer()
        connector.lineWidth = connectorWidth
        connector.path = pathBottom.cgPath
        connector.strokeStart = 0
        connector.strokeEnd = diff
        connector.lineCap = "round"
        connector.strokeColor = color.cgColor
        connector.fillColor = UIColor.clear.cgColor
        connector.shadowColor = UIColor.black.cgColor
        connector.shadowRadius = 0
        connector.shadowOpacity = 0
        connector.shadowOffset = CGSize.zero

        return connector
    }

    @discardableResult
    func drawProgressBackCircle(_ rect: CGRect) -> CALayer {
        let centerX = self.bounds.midX
        let centerY = self.bounds.midY
        let arcRadius: CGFloat = circleRadius
        let pathBottom = UIBezierPath(
            ovalIn: CGRect(x: (centerX - (arcRadius/2)),
                           y: (centerY - (arcRadius/2)),
                           width: arcRadius,
                           height: arcRadius))

        let arc = CAShapeLayer()
        arc.lineWidth = lineWidth
        arc.path = pathBottom.cgPath
        arc.strokeStart = 0
        arc.strokeEnd = 1
        arc.lineCap = "round"
        arc.strokeColor = tintColor.cgColor
        arc.fillColor = UIColor.clear.cgColor
        arc.shadowColor = UIColor.clear.cgColor
        arc.shadowRadius = 0
        arc.shadowOpacity = 0
        arc.shadowOffset = CGSize.zero

        return arc
    }

    // MARK: - Caculation helper methods

    func getViewAngle(_ val: CGPoint) {
        let rect = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        angle = getAngle(val, rect: rect) - getAngle(touchBegin!, rect: rect)
    }

    func recalculate() {
        let diff = endpointsDifference
        let newValue1 = angle.convertRadiansToValue()
        let newValue2 = newValue1 + diff

        value1 = newValue1.normalizeValue()
        value2 = newValue2.normalizeValue()
    }

    func calculateElementSizes() {
        circleRadius = min(self.frame.height, self.frame.width) - arcRadius - lineWidth * 2
    }

    /// Gets the angle between point and rectangle center in radians
    /// - parameter point: Point
    /// - parameter rect:
    /// - returns: Angle in radians
    func getAngle(_ point: CGPoint, rect: CGRect) -> CGFloat {
        let diffX = point.x - rect.midX
        let diffY = rect.midY - point.y

        var angle: Float = 0
        angle = atan2f(Float(diffX), Float(diffY))

        return CGFloat(angle)
    }

    // MARK: - Rotation of elements

    func rotateDot(_ layer: CALayer, forAngle angle: CGFloat) {
        let rect = self.frame
        let rotateAroundCircle = CATransform3DMakeRotation(angle, 0, 0, 1)
        let translateInViewCenter = CATransform3DMakeTranslation(
            rect.width/2 - arcRadius/2, rect.height/2 - arcRadius/2, 0)
        let translateOnCircle = CATransform3DMakeTranslation(-arcRadius/2, -circleRadius/2, 0)

        layer.transform =
            CATransform3DConcat(
                CATransform3DConcat(translateOnCircle, rotateAroundCircle), translateInViewCenter)
    }

    func rotateConnector(_ layer: CALayer, forAngle angle: CGFloat) {
        let rect = self.frame
        layer.setAffineTransform(CGAffineTransform(translationX: rect.width/2, y: rect.height/2).rotated(by: angle))
    }

    func rotateMovingView() {
        UIView.animate(withDuration: 0.1, animations: {
            self.movingView.layer.setAffineTransform(CGAffineTransform.identity.rotated(by: self.angle))
        })
    }

    override open var intrinsicContentSize: CGSize {
        if frame.size == CGSize.zero {
            let side = circleRadius + arcRadius + lineWidth * 2
            return CGSize(width: side, height: side)
        } else {
            return frame.size
        }
    }

    open override func prepareForInterfaceBuilder() {
        setNeedsLayout()
    }
}
