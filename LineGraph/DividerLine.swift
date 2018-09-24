//
//  DividerLine.swift
//  LineGraph
//
//  Created by Prateek Sharma on 8/14/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit


struct LineDash {
    var length: CGFloat
    var gap: CGFloat
}


struct GraphDivider {
    
    var graphLabel: GraphLabel
    var lineDash: LineDash?
    
    let lineWidth: CGFloat
    let lineColor: UIColor
    
    init(graphLabel: GraphLabel, lineWidth: CGFloat = 1, lineColor: UIColor = UIColor.white) {
        self.graphLabel = graphLabel
        self.lineWidth = lineWidth
        self.lineColor = lineColor
    }
    
}
