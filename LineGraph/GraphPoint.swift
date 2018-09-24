//
//  GraphPoint.swift
//  LineGraph
//
//  Created by Prateek Sharma on 8/16/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit


struct GraphPoint {
    let x: Double
    let y: Double
    let radius: CGFloat
    let fillColor: UIColor
    let borderColor: UIColor
    let borderWidth: CGFloat
    
    init(x: Double, y: Double, radius: CGFloat, fillColor: UIColor = .clear, borderWidth: CGFloat = 1, borderColor: UIColor = .black) {
        self.x = x
        self.y = y
        self.radius = radius
        self.fillColor = fillColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }
    
}
