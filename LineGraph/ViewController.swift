//
//  ViewController.swift
//  LineGraph
//
//  Created by Prateek Sharma on 8/14/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private let maxValues = (maxX: 60.0, maxY: 100.0)
    @IBOutlet weak var graphView: LineGraph! {
        didSet {
            graphView.delegate = self
            graphView.dataSource = self
        }
    }
}

extension ViewController: LineGraphDataSource, LineGraphDelegate {
    
    func maxValues(forGraph graph: LineGraph) -> (maxX: Double, maxY: Double) {
        return maxValues
    }
    
    func numberOfHorizontalDividers(forGraph graph: LineGraph) -> Int {
        return (Int(maxValues.maxY) / 10) + 1
    }
    
    func numberOfVerticalDividers(forGraph graph: LineGraph) -> Int {
        return (Int(maxValues.maxX) / 10) + 1
    }
    
    func divider(forGraph graph: LineGraph, atIndex index: Int, forAxis axis: Axis) -> GraphDivider? {
        return index == 0 ? GraphDivider(graphLabel: GraphLabel(text: "\(index)", color: .white), lineColor: .white) : nil
    }
    
    func numberOfPlottingPoints(forGraph graph: LineGraph) -> Int {
        return ((Int(maxValues.maxX) / 10) + 1) + 1
    }
    
    func pointForPlotting(onGraph graph: LineGraph, atIndex index: Int) -> GraphPoint {
        return GraphPoint(x: (Double(index) * maxValues.maxX) / Double(numberOfPlottingPoints(forGraph: graph) - 1), y: Double(arc4random_uniform(UInt32(Int(maxValues.maxY / 10))) + 1) * 10, borderColor: UIColor.green)
    }
}
