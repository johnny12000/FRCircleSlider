//
//  FRCircleSlider.swift
//
//  Created by Nikola Ristic on 2/28/16.
//  Copyright © 2016 nr. All rights reserved.
//

import UIKit
import GLKit

@IBDesignable
public class FRCircleSlider: UIControl {

    @IBInspectable var selectedColor: UIColor = UIColor.blue
    @IBInspectable var firstDotColor: UIColor = UIColor.gray
    @IBInspectable var secondDotColor: UIColor = UIColor.gray
    @IBInspectable var connectorColor: UIColor = UIColor.yellow

    var circleRadius: CGFloat = 250
    var lineWidth: CGFloat = 1
    var circleWidth: CGFloat = 3
    var connectorWidth: CGFloat = 10
    var lineHeight: CGFloat = 10
    let arcRadius: CGFloat = 30

    public var value1: CGFloat = 0.1 {
        willSet(value) {
            if value != value1 {
                getViewAngleFromValue(value)
                rotateMovingView()
            }
        }
    }

    public var value2: CGFloat = 0.5

    var dot1Layer: CALayer?
    var dot2Layer: CALayer?
    var connectorLayer: CAShapeLayer?
    var selectedLayer: CALayer?
    var movingView: UIView!
    var angle: CGFloat = 0.0

    // MARK: - Initialization

    override init(frame: CGRect) {
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
        addConstraints([
            NSLayoutConstraint(item: movingView, attribute: .width, relatedBy: .equal,
                               toItem: self, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: movingView, attribute: .height, relatedBy: .equal,
                               toItem: self, attribute: .height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: movingView, attribute: .centerX, relatedBy: .equal,
                               toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: movingView, attribute: .centerY, relatedBy: .equal,
                               toItem: self, attribute: .centerY, multiplier: 1, constant: 0)])
    }

    override open func layoutSubviews() {
        calculateElementSizes()
        super.layoutSubviews()
        self.bringSubview(toFront: movingView)
    }

    // MARK: - Tracking user actions

    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let val = touch.location(in: movingView)

        if dot1Layer?.frame.contains(val) == true {
            selectedLayer = dot1Layer
        } else if dot2Layer?.frame.contains(val) == true {
            selectedLayer = dot2Layer
        } else {
            selectedLayer = nil
        }

        super.beginTracking(touch, with: event)
        return selectedLayer != nil
    }

    override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
    }

    override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        if selectedLayer != nil {
            let val = touch.location(in: self)
            getViewAngle(val)
            rotateMovingView()
            recalculate()
            self.sendActions(for: UIControlEvents.valueChanged)
        }
        return super.continueTracking(touch, with: event)
    }

    // MARK: - Draw elements

    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        drawProgressBackCircle(rect)
        drawConnector(rect)
        drawDot1(rect)
        drawDot2(rect)
        bringSubview(toFront: movingView)
        rotateMovingView()
    }

    func drawDot1(_ rect: CGRect) {
        let angle = CGFloat(0)
        dot1Layer = drawDot(angle, rect:rect, color: firstDotColor)
        movingView.layer.addSublayer(dot1Layer!)
    }

    func drawDot2(_ rect: CGRect) {
        let diff = (value2 - value1).normalizeValue()
        let angle = valueToRadians(diff)
        dot2Layer = drawDot(angle, rect: rect, color: secondDotColor)
        movingView.layer.addSublayer(dot2Layer!)
    }

    func drawDot(_ angle: CGFloat, rect: CGRect, color: UIColor) -> CALayer {
        let pathBottom = UIBezierPath(ovalIn:CGRect(x: 0, y: 0, width: arcRadius, height: arcRadius))

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
        self.rotateDot(layer, forAngle: angle)

        return layer
    }

    func drawConnector(_ rect: CGRect) {
        var diff = (value2 - value1).normalizeValue()
        diff -= 0.02
        let angle = CGFloat(GLKMathDegreesToRadians(-90))

        let X = CGFloat(0)
        let Y = CGFloat(0)
        let arcRadius: CGFloat = circleRadius
        let color = connectorColor
        let pathBottom = UIBezierPath(
            ovalIn: CGRect(x: (X - (arcRadius/2)), y: (Y - (arcRadius/2)), width: arcRadius, height: arcRadius))

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

        rotateConnector(connector, forAngle: angle)

        movingView.layer.addSublayer(connector)
        connectorLayer = connector
        movingView.setNeedsLayout()
    }

    func drawProgressBackCircle(_ rect: CGRect) {
        let X = self.bounds.midX
        let Y = self.bounds.midY
        let arcRadius: CGFloat = circleRadius
        let pathBottom = UIBezierPath(
            ovalIn: CGRect(x: (X - (arcRadius/2)), y: (Y - (arcRadius/2)), width: arcRadius, height: arcRadius))

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

        layer.addSublayer(arc)
    }

    // MARK: - Caculation helper methods

    func valueToRadians(_ value: CGFloat) -> CGFloat {
        return CGFloat(GLKMathDegreesToRadians(360) * Float(value))
    }

    func radiansToValue(_ radians: CGFloat) -> CGFloat {
        return CGFloat(Float(radians)/GLKMathDegreesToRadians(360))
    }

    func getViewAngle(_ val: CGPoint) {
        let rect = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)

        if selectedLayer == dot1Layer {
            angle = self.getAngle(val, layer: dot1Layer!, rect: rect)
        } else if selectedLayer == dot2Layer {
            let angle2 = self.getAngle(val, layer: dot2Layer!, rect: rect)
            let currentValue = radiansToValue(angle2)
            let diff = value1 - value2
            angle = valueToRadians(diff + currentValue)
        }
    }

    func getViewAngleFromValue(_ value: CGFloat) {
        angle = valueToRadians(value)
    }

    func recalculate() {
        let diff = (value2 - value1).normalizeValue()
        let newValue1 = self.radiansToValue(angle)
        let newValue2 = newValue1 + diff

        value1 = newValue1.normalizeValue()
        value2 = newValue2.normalizeValue()
    }

    func calculateElementSizes() {
        circleRadius = min(self.frame.height, self.frame.width) - arcRadius - lineWidth * 2
    }

    func getAngle(_ point: CGPoint, layer: CALayer, rect: CGRect) -> CGFloat {
        let x = point.x - rect.midX
        let y = rect.midY - point.y

        var angle: Float = 0
        angle = atan2f(Float(x), Float(y))

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

    override public var intrinsicContentSize: CGSize {
        if frame.size == CGSize.zero {
            let side = circleRadius + arcRadius + lineWidth * 2
            return CGSize(width: side, height: side)
        } else {
            return frame.size
        }
    }

    public override func prepareForInterfaceBuilder() {
        setNeedsLayout()
    }
}
