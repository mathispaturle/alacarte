//
//  CornersView.swift
//  A la carte
//
//  Created by Sopra on 24/02/2021.
//

import Foundation
import UIKit

@IBDesignable public class CornersView: UIView {
    var color = UIColor.black {
        didSet {
            setNeedsDisplay()
        }
    }

    var radius: CGFloat = 2 {
        didSet {
            setNeedsDisplay()
        }
    }

    var thickness: CGFloat = 2 {
        didSet {
            setNeedsDisplay()
        }
    }

    var length: CGFloat = 25 {
        didSet {
            setNeedsDisplay()
        }
    }

    override public func draw(_ rect: CGRect) {
        color.set()

        let halfThickness = thickness / 2
        let path = UIBezierPath()

        // Top left
        path.move(to: CGPoint(x: halfThickness, y: length + radius + halfThickness))
        path.addLine(to: CGPoint(x: halfThickness, y: radius + halfThickness))
        path.addArc(withCenter: CGPoint(x: radius + halfThickness, y: radius + halfThickness), radius: radius, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 3 / 2, clockwise: true)
        path.addLine(to: CGPoint(x: length + radius + halfThickness, y: halfThickness))

        // Top right
        path.move(to: CGPoint(x: frame.width - halfThickness, y: length + radius + halfThickness))
        path.addLine(to: CGPoint(x: frame.width - halfThickness, y: radius + halfThickness))
        path.addArc(withCenter: CGPoint(x: frame.width - radius - halfThickness, y: radius + halfThickness), radius: radius, startAngle: 0, endAngle: CGFloat.pi * 3 / 2, clockwise: false)
        path.addLine(to: CGPoint(x: frame.width - length - radius - halfThickness, y: halfThickness))

        // Bottom left
        path.move(to: CGPoint(x: halfThickness, y: frame.height - length - radius - halfThickness))
        path.addLine(to: CGPoint(x: halfThickness, y: frame.height - radius - halfThickness))
        path.addArc(withCenter: CGPoint(x: radius + halfThickness, y: frame.height - radius - halfThickness), radius: radius, startAngle: CGFloat.pi, endAngle: CGFloat.pi / 2, clockwise: false)
        path.addLine(to: CGPoint(x: length + radius + halfThickness, y: frame.height - halfThickness))

        // Bottom right
        path.move(to: CGPoint(x: frame.width - halfThickness, y: frame.height - length - radius - halfThickness))
        path.addLine(to: CGPoint(x: frame.width - halfThickness, y: frame.height - radius - halfThickness))
        path.addArc(withCenter: CGPoint(x: frame.width - radius - halfThickness, y: frame.height - radius - halfThickness), radius: radius, startAngle: 0, endAngle: CGFloat.pi / 2, clockwise: true)
        path.addLine(to: CGPoint(x: frame.width - length - radius - halfThickness, y: frame.height - halfThickness))

        path.lineWidth = thickness
        path.lineCapStyle = .round
        path.lineJoinStyle = .round

        path.stroke()
    }
}
