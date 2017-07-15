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

    @IBInspectable var selectedColor: UIColor = UIColor.blue
    @IBInspectable var dotColor: UIColor = UIColor.red
    @IBInspectable var connectorColor: UIColor = UIColor.yellow

    var circleRadius: CGFloat = 250
    var lineWidth: CGFloat = 1
    var circleWidth: CGFloat = 3
    var connectorWidth: CGFloat = 10
    var lineHeight: CGFloat = 10
    let arcRadius: CGFloat = 30

    var value1: CGFloat = 0.1 {
        willSet(value) {
            if value != value1 {
                getViewAngleFromValue(value)
                rotateMovingView()
            }
        }
    }

    var value2: CGFloat = 0.5

    var dot1Layer: CALayer?
    var dot2Layer: CALayer?
    var connectorLayer: CAShapeLayer?
    var selectedLayer: CALayer?
    var point: CGPoint?
    var movingView: UIView!
    var angle: CGFloat = 0.1

    // MARK: - Initialization

    override init(frame: CGRect) {
        point = CGPoint(x: 0, y: 0)
        movingView = UIView(frame: frame)
        super.init(frame: frame)
        controlSetup()
    }

    required public init?(coder aDecoder: NSCoder) {
        point = CGPoint(x: 0, y: 0)
        movingView = UIView(coder:aDecoder)
        super.init(coder: aDecoder)
        controlSetup()
    }

    func controlSetup() {
        backgroundColor = UIColor.clear
        tintColor = UIColor.white

        translatesAutoresizingMaskIntoConstraints = false
        movingView = UIView(frame: frame)
        movingView.isUserInteractionEnabled = false
        movingView.translatesAutoresizingMaskIntoConstraints = false
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

        return selectedLayer != nil
    }

    override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {

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

    override open func draw(_ rect: CGRect) {
        self.drawText(rect)
        self.drawProgressBackCircle(rect)
        self.drawTimeLines(rect)
        self.drawConnector(rect)
        self.drawDot1(rect)
        self.drawDot2(rect)
        self.bringSubview(toFront: movingView)
        rotateMovingView()
    }

    func drawText(_ rect: CGRect) {

        let text1 = "6"
        let text2 = "12"
        let text3 = "18"
        let text4 = "24"

        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize:12),
                          NSForegroundColorAttributeName: UIColor.white]

        let text1Size = text1.size(attributes: attributes)
        let text2Size = text2.size(attributes: attributes)
        let text3Size = text3.size(attributes: attributes)
        let text4Size = text4.size(attributes: attributes)

        let text1Rect = CGRect(x: rect.maxX - text1Size.width, y: rect.midY - text1Size.height/2,
                               width: text1Size.width, height: text1Size.height)

        let text2Rect = CGRect(x: rect.midX - text2Size.width/2, y: rect.maxY - text2Size.height,
                               width: text2Size.width, height: text2Size.height)

        let text3Rect = CGRect(x: rect.minX, y: rect.midY - text3Size.height/2,
                               width: text3Size.width, height: text3Size.height)

        let text4Rect = CGRect(x: rect.midX - text4Size.width/2, y: rect.minY,
                               width: text4Size.width, height: text4Size.height)

        text1.draw(in: text1Rect, withAttributes: attributes)
        text2.draw(in: text2Rect, withAttributes: attributes)
        text3.draw(in: text3Rect, withAttributes: attributes)
        text4.draw(in: text4Rect, withAttributes: attributes)
    }

    func drawTimeLines(_ rect: CGRect) {
        for i in 0...360/5 {
            let angle: Float = Float(i*5)
            drawLine(CGFloat(GLKMathDegreesToRadians(angle)), rect:rect)
        }
    }

    func drawLine(_ angle: CGFloat, rect: CGRect) {
        //create the path
        let plusPath = UIBezierPath()

        //set the path's line width to the height of the stroke
        plusPath.lineWidth = lineWidth

        //move the initial point of the path
        //to the start of the horizontal stroke
        plusPath.move(to: CGPoint(
            x:circleRadius/2 + 20,
            y:0))

        //add a point to the path at the end of the stroke
        plusPath.addLine(to: CGPoint(
            x:circleRadius/2 + lineHeight + 20,
            y:0))

        //set the stroke color
        tintColor.setStroke()

        let rotate = CGAffineTransform(rotationAngle: angle)
        let translate = CGAffineTransform(translationX: rect.width/2, y: rect.height/2)

        plusPath.apply(rotate)
        plusPath.apply(translate)
        //draw the stroke
        plusPath.stroke()
    }

    func drawDot1(_ rect: CGRect) {
        let angle = CGFloat(0)
        dot1Layer = drawDot(angle, rect:rect, color: UIColor.blue)
        movingView.layer.addSublayer(dot1Layer!)
    }

    func drawDot2(_ rect: CGRect) {
        var diff = value2 - value1
        if diff < 0 {
            diff = 1 + diff
        }

        let angle = valueToRadians(diff)
        dot2Layer = drawDot(angle, rect: rect, color: UIColor.orange)
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
        var diff = value2 - value1

        if diff < 0 {
            diff = 1 + diff
        }

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
        var newValue1 = self.radiansToValue(angle)
        var diff: CGFloat = value2 - value1

        if diff < 0 {
            diff = 1 + diff
        }

        if newValue1 < 0 {
            newValue1 += 1
        } else if newValue1 > 1 {
            newValue1 -= 1
        }

        var newValue2 = newValue1 + diff
        if newValue2 < 0 {
            newValue2 += 1
        } else if newValue2 > 1 {
            newValue2 -= 1
        }

        value1 = newValue1
        value2 = newValue2
    }

    func calculateElementSizes() {
        circleRadius = min(self.frame.height, self.frame.width) * 0.6
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
            rect.width/2 - arcRadius/2,
            rect.height/2 - arcRadius/2,
            0)
        let translateOnCircle = CATransform3DMakeTranslation(-arcRadius/2,
                                                             -circleRadius/2,
                                                             0)

        layer.transform =
            CATransform3DConcat(
                CATransform3DConcat(translateOnCircle, rotateAroundCircle),
                translateInViewCenter)
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
}
