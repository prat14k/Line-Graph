//
//  ViewController.swift
//  LineGraph
//
//  Created by Prateek Sharma on 8/14/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var graphView: LineGraph! {
        didSet {
            graphView.delegate = self
            graphView.dataSource = self
        }
    }
}

extension ViewController: LineGraphDataSource, LineGraphDelegate {
    func maxValues(forGraph graph: LineGraph) -> (maxX: Double, maxY: Double) {
        return (maxX: 100, maxY: 100)
    }
    
    func numberOfHorizontalDividers(forGraph graph: LineGraph) -> Int {
        return 11
    }
    
    func numberOfVerticalDividers(forGraph graph: LineGraph) -> Int {
        return 7
    }
    
    func divider(forGraph graph: LineGraph, atIndex index: Int, forAxis axis: Axis) -> GraphDivider {
        return GraphDivider(chartLabel: GraphLabel(text: "\(index)", color: .black))
    }
    
    func numberOfPlottingPoints(forGraph graph: LineGraph) -> Int {
        return 7
    }
    
    func pointForPlotting(onGraph graph: LineGraph, atIndex index: Int) -> GraphPoint {
        return GraphPoint(x: Double((index + 1) * 10), y: Double((index + 1) * 10), radius: 5)
    }
}
