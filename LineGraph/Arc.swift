//
//  Arc.swift
//  LancomeNanoentek
//
//  Created by Prateek Sharma on 9/7/18.
//  Copyright © 2018 Loreal. All rights reserved.
//

import UIKit


struct Arc {
    
    let radius: CGFloat
    let center: CGPoint
    var startAngle: CGFloat
    var endAngle: CGFloat
    var clockWise: Bool
    var lineWidth: CGFloat
    var lineColor: UIColor
    var fillColor: UIColor
    var lineDash: LineDash?
    
    init(center: CGPoint, radius: CGFloat, startAngle: CGFloat = 0, endAngle: CGFloat = (CGFloat.pi * 2), clockWise: Bool = true, lineWidth: CGFloat = 1, lineColor: UIColor = .black, fillColor: UIColor = .clear) {
        self.center = center
        self.radius = radius
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.clockWise = clockWise
        self.lineWidth = lineWidth
        self.lineColor = lineColor
        self.fillColor = fillColor
    }
    
}

extension CAShapeLayer {
    
    convenience init(circle: Arc, frame: CGRect) {
        self.init()
        let circlePath = UIBezierPath(arcCenter: circle.center, radius: circle.radius, startAngle: circle.startAngle, endAngle: circle.endAngle, clockwise: circle.clockWise)
        
        self.frame = frame
        path = circlePath.cgPath
        lineWidth = circle.lineWidth
        strokeColor = circle.lineColor.cgColor
        fillColor = circle.fillColor.cgColor
        strokeStart = 0
        strokeEnd = 1
        lineDashPattern = (circle.lineDash != nil ? [circle.lineDash!.length, circle.lineDash!.gap] : nil) as [NSNumber]?
    }
    
}
