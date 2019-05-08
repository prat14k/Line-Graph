//
//  LineGraphView.swift
//  LineGraph
//
//  Created by Prateek Sharma on 8/14/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit

enum Axis {
    case horizontal, vertical
}

protocol LineGraphDataSource: class {
    func numberOfHorizontalDividers(forGraph graph: LineGraph) -> Int
    func numberOfVerticalDividers(forGraph graph: LineGraph) -> Int
    func maxValues(forGraph graph: LineGraph) -> (maxX: Double, maxY: Double)
    func divider(forGraph graph: LineGraph, atIndex index: Int, forAxis axis: Axis) -> GraphDivider?
    func numberOfPlottingPoints(forGraph graph: LineGraph) -> Int
    func pointForPlotting(onGraph graph: LineGraph, atIndex index: Int) -> GraphPoint
}

@objc protocol LineGraphDelegate: class {
    @objc optional func sizeOffset(forChart chart: LineGraph) -> CGSize
}

class LineGraph: UIControl {
    
    @IBInspectable private var highlightPeak: Bool = true
    @IBInspectable private var graphCurveWidth: CGFloat = 1
    @IBInspectable private var graphCurveColor: UIColor = .white
    
    private let graphPadding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    weak var dataSource: LineGraphDataSource?
    weak var delegate: LineGraphDelegate?
    
    var plotValues: (maxX: Double, maxY: Double)!
    
    private var isInitialSetupCompleted = false
    
    private var verticalAxisLines = [GraphDivider]()
    private var horizontalAxisLines = [GraphDivider]()
    private var graphPoints = [GraphPoint]()
    private var customDotLayers = [CALayer]()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard !isInitialSetupCompleted  else { return }
        
        reloadData()
        isInitialSetupCompleted = !isInitialSetupCompleted
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        drawHorizontalLines()
        drawVerticalLines()
        drawLineCurve()
    }
    
}

extension LineGraph {

    private func reloadData() {
        clearOut()
        plotValues = dataSource?.maxValues(forGraph: self) ?? (maxX: 0, maxY: 0)
        fetchDataForVerticalAxis()
        fetchDataForHorizontalAxis()
        fetchPoints()
    }
    
    private func clearOut() {
        customDotLayers.removeAll()
        subviews.forEach { $0.removeFromSuperview() }
        layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        verticalAxisLines.removeAll()
        horizontalAxisLines.removeAll()
    }
    
    private func isPeakPoint(atIndex index: Int) -> Bool {
        guard (graphPoints.count - 1) > index, index > 0  else { return false }
        return (graphPoints[index - 1].y < graphPoints[index].y) && (graphPoints[index].y > graphPoints[index + 1].y)
    }
    
}

extension LineGraph {

    private func fetchDataForVerticalAxis() {
        let axis = Axis.vertical
        guard let ds = dataSource else { return }
        let verticalLines = ds.numberOfVerticalDividers(forGraph: self)
        if verticalLines <= 0  { return }
        
        for i in 0..<verticalLines {
            guard let line = ds.divider(forGraph: self, atIndex: i, forAxis: axis)
            else { continue }
            verticalAxisLines.append(line)
        }
    }
    
    private func fetchDataForHorizontalAxis() {
        let axis = Axis.horizontal
        guard let ds = dataSource else { return }
        let horizontalLines = ds.numberOfHorizontalDividers(forGraph: self)
        if horizontalLines <= 0  { return }
        
        for i in 0..<horizontalLines {
            guard let line = ds.divider(forGraph: self, atIndex: i, forAxis: axis)
            else { continue }
            horizontalAxisLines.append(line)
        }
    }
    
    private func fetchPoints() {
        guard let ds = dataSource  else { return }
        let numberOfPoints = ds.numberOfPlottingPoints(forGraph: self)
        if numberOfPoints <= 0 { return }
        
        for i in 0..<numberOfPoints {
            graphPoints.append(ds.pointForPlotting(onGraph: self, atIndex: i))
        }
        print(graphPoints)
    }
    
}

extension LineGraph {
    
    private func drawHorizontalLines() {
        let availableHeight = bounds.height - graphPadding.top - graphPadding.bottom
        if availableHeight <= 0 { return }
        let lineSpacing = availableHeight / CGFloat(horizontalAxisLines.count - 1)
        
        var startPoint = CGPoint(x: bounds.width - graphPadding.right, y: bounds.height - graphPadding.bottom)
        for line in horizontalAxisLines {
            addLine(startPoint: startPoint, endPoint: CGPoint(x: graphPadding.left, y: startPoint.y), line: line)
            startPoint.y = startPoint.y - lineSpacing
        }
    }
    
    private func drawVerticalLines() {
        let availableWidth = bounds.width - graphPadding.left - graphPadding.right
        if availableWidth <= 0 { return }
        let lineSpacing = availableWidth / CGFloat(verticalAxisLines.count)
        var startPoint = CGPoint(x: graphPadding.left, y: bounds.height - graphPadding.bottom)
        for line in verticalAxisLines {
            addLine(startPoint: startPoint, endPoint: CGPoint(x: startPoint.x, y: graphPadding.top), line: line)
            startPoint.x = startPoint.x + lineSpacing
        }
    }
    
    private func addLine(startPoint: CGPoint, endPoint: CGPoint, line: GraphDivider) {
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        path.lineWidth = line.lineWidth
        line.lineColor.setStroke()
        path.stroke()
        if let lineDash = line.lineDash { path.setLineDash([lineDash.length, lineDash.gap], count: 2, phase: 0) }
    }
    
}

extension LineGraph {
    
    private func drawCircle(center: CGPoint, graphPoint: GraphPoint) {
        let circle = UIBezierPath(arcCenter: center, radius: graphPoint.radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        circle.lineWidth = graphPoint.borderWidth
        graphPoint.borderColor.setStroke()
        circle.stroke()
        graphPoint.fillColor.setFill()
        circle.fill()
    }
    
    private func drawLineCurve() {
        let graphWidth = bounds.width - graphPadding.left - graphPadding.right
        let graphHieght = bounds.height - graphPadding.top - graphPadding.bottom
        guard graphWidth > 0, graphHieght > 0, plotValues.maxX > 0, plotValues.maxY > 0
        else { fatalError("Cannot draw graph for wrong values") }
        
        var centers = [CGPoint]()
        for (index, point) in graphPoints.enumerated() {
            guard plotValues.maxX >= point.x, plotValues.maxY >= point.y  else { continue }
            let pointXValue = graphWidth * CGFloat(point.x / plotValues.maxX)
            let pointYValue = graphHieght * CGFloat(1 - (point.y / plotValues.maxY))
            let pointCoordinate = CGPoint(x: graphPadding.left + pointXValue, y: graphPadding.top + pointYValue)
            if isPeakPoint(atIndex: index) {
                drawCircle(center: pointCoordinate, graphPoint: point)
            }
            centers.append(pointCoordinate)
        }
        
        drawConnectingLine(points: centers, lineColor: graphCurveColor, lineWidth: graphCurveWidth)
    }
    
    private func drawConnectingLine(points: [CGPoint], lineColor: UIColor, lineWidth: CGFloat) {
        guard points.count > 1 else { return }
        let lineCurve = UIBezierPath()
        lineCurve.move(to: points[0])
        
        for i in 1..<points.count {
            lineCurve.addLine(to: points[i])
        }
        lineCurve.lineWidth = lineWidth
        lineColor.setStroke()
        lineCurve.stroke()
    }
    
}

