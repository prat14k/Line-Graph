////
////  Chart.swift
////  ChartsDemo
////
////  Created by Prateek Sharma on 7/19/18.
////  Copyright © 2018 Prateek Sharma. All rights reserved.
////
//
//import UIKit
//
//
//protocol ChartDataSource: class {
//    func numberofConcentricCircles(forChart chart: Chart) -> Int
//    func numberOfSlices(forChart chart: Chart) -> Int
//    
//    func sliceArea(fromChart chart: Chart, atIndex index: Int) -> ChartSlice
//    func circle(forChart chart: Chart, atIndex index: Int) -> ChartCircle
//    
//    func imageAsset(forDividerIndex: Int, chart: Chart) -> ImageAsset
//}
//
//
//@objc protocol ChartDelegate: class {
//    @objc optional func maximumRadiusValue(forChart chart: Chart) -> CGFloat
//    @objc optional func didTapSlice(atIndex index: Int)
//    @objc optional func didRotateChart()
//}
//
//
//class Chart: UIControl {
//    
//    static let imageSize: CGFloat = 35
//    
//    weak var dataSource: ChartDataSource?
//    weak var delegate: ChartDelegate?
//    
//    var dividerLineWidth: CGFloat = 1.5
//    var dividerLineColor: UIColor = .white
//    
//    private var slicesCount: Int = 0
//    private var slices = [ChartSlice]()
//    private var circlesCount: Int = 0
//    private var chartCircles = [ChartCircle]()
//    
//    private var maximumRadius: CGFloat = 0
//    
//    private var isInitialSetupCompleted = false
//    
//    private var arcSlices = [CAShapeLayer]()
//    
//    var selectedSliceLineWidth: CGFloat? = 4
//    var selectedSliceLineColor: UIColor? = UIColor.cyan
//    var selectedSliceFillColor: UIColor? = UIColor.yellow
//    
//    var isTapGestureEnabled: Bool = true
//    var isRotationGestureEnabled: Bool = true
//    
//    private(set) var selectedIndex: Int? {
//        didSet {
//            selectedIndex != nil ? delegate?.didTapSlice?(atIndex: selectedIndex!) : nil
//        }
//    }
//    
//    private var viewFrameCenter: CGPoint { return CGPoint(x: bounds.width / 2, y: bounds.height / 2) }
//    
//    
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        addGestures()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        addGestures()
//    }
//    
//}
//
//
//extension Chart {
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        guard !isInitialSetupCompleted  else { return }
//        reloadData()
//        isInitialSetupCompleted = !isInitialSetupCompleted
//    }
//    
//    
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//        print("Draw REct Called")
//        
//        drawCircles()
//        drawSlices()
//        drawLinesAndImages()
//    }
//    
//}
//
//
//extension Chart {
//    
//    func reloadData() {
//        subviews.forEach { $0.removeFromSuperview() }
//        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
//        setupGraph()
//        
//        fetchChartCircles()
//        fetchChartSlices()
//        
//        if isInitialSetupCompleted {
//            setNeedsDisplay()
//        }
//    }
//    
//    private func setupGraph() {
//        arcSlices.removeAll()
//        guard let circlesCount = dataSource?.numberofConcentricCircles(forChart: self),
//              let slicesCount = dataSource?.numberOfSlices(forChart: self)
//        else { return }
//        
//        let maximumRadius = delegate?.maximumRadiusValue?(forChart: self) ?? ((bounds.height / 2) - 50)
//        
//        if slicesCount < 0 || maximumRadius < 0 || circlesCount < 0  {
//            breakExecution(message: "Negative values cannot be sent from the delegate methods")
//        }
//        
//        self.circlesCount = circlesCount
//        self.slicesCount = slicesCount
//        self.maximumRadius = maximumRadius
//    }
//    
//    private func fetchChartSlices() {
//        slices.removeAll()
//        guard let dataSource = dataSource, slicesCount > 0  else { return }
//        for i in 0..<slicesCount {
//            slices.append(dataSource.sliceArea(fromChart: self, atIndex: i))
//        }
//    }
//    
//    private func fetchChartCircles() {
//        chartCircles.removeAll()
//        guard let dataSource = dataSource, circlesCount > 0  else { return }
//        for i in 0..<circlesCount {
//            chartCircles.append(dataSource.circle(forChart: self, atIndex: i))
//        }
//    }
//    
//}
//
//
//extension Chart {
//    
//    private func breakExecution(message: String) -> Never {
//        fatalError(message)
//    }
//    
//    private func createLabel(for chartLabel: ChartLabel) -> UILabel {
//        let lbl = UILabel()
//        lbl.text = chartLabel.text
//        lbl.font = chartLabel.font
//        lbl.sizeToFit()
//        lbl.textColor = chartLabel.color
//        return lbl
//    }
//    
//    private func createImageView(withAsset asset: ImageAsset, center: CGPoint) -> UIImageView {
//        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: Chart.imageSize, height: Chart.imageSize))
//        imageView.image = UIImage(asset: asset)
//        imageView.contentMode = .scaleAspectFit
//        imageView.center = center
//        return imageView
//    }
//    
//}
//
//
//extension Chart {
//    
//    private func drawLinesAndImages() {
//        
//        guard slices.count > 0  else { return }
//        
//        let dividerLine = UIBezierPath()
//    
//        for index in 0..<slices.count {
//            let sliceAngle = (2 * CGFloat.pi) / CGFloat(slices.count)
//            let angle = CGFloat(index) * sliceAngle + ((2 * CGFloat.pi) * (3 / 4))
//            
//            var nextPoint = CGPoint.zero
//            nextPoint.x = viewFrameCenter.x + maximumRadius * cos(angle)
//            nextPoint.y = viewFrameCenter.y + maximumRadius * sin(angle)
//            
//            dividerLine.move(to: viewFrameCenter)
//            dividerLine.addLine(to: nextPoint)
//            
//            guard let dividerImageAsset = dataSource?.imageAsset(forDividerIndex: index, chart: self)   else { continue }
//            addDividerImage(asset: dividerImageAsset, atExtendedAngle: angle)
//        }
//        
//        dividerLine.lineWidth = dividerLineWidth
//        dividerLineColor.setStroke()
//        dividerLine.stroke()
//    }
//    
//    private func addDividerImage(asset: ImageAsset, atExtendedAngle angle: CGFloat) {
//        
//        let imageCenter = CGPoint(x: viewFrameCenter.x + (maximumRadius + 25) * cos(angle), y: viewFrameCenter.x + (maximumRadius + 25) * sin(angle))
//        let imageView = createImageView(withAsset: asset, center: imageCenter)
//        addSubview(imageView)
//        imageView.transform = CGAffineTransform(rotationAngle: angle)
//    }
//    
//}
//
//extension Chart {
//    
//    private func drawCircles() {
//        let concentricCirclesGap = maximumRadius / CGFloat(chartCircles.count)
//        var currentRadius = concentricCirclesGap
//        
//        for chartCircle in chartCircles {
//            
//            drawCircle(withRadius: currentRadius, forChartCircle: chartCircle)
//            addCircleTitleLabel(radius: currentRadius, chartLabel: chartCircle.chartLabel)
//            
//            currentRadius += concentricCirclesGap
//        }
//        
//        maximumRadius = currentRadius - concentricCirclesGap
//    }
//    
//    private func addCircleTitleLabel(radius: CGFloat, chartLabel: ChartLabel) {
//        let lbl = createLabel(for: chartLabel)
//        lbl.frame = CGRect(x: viewFrameCenter.x + 4, y: (viewFrameCenter.y - radius) + 4, width: lbl.frame.width, height: lbl.frame.height)
//        lbl.font = chartLabel.font
//        addSubview(lbl)
//    }
//    
//    private func drawCircle(withRadius radius: CGFloat, forChartCircle chartCircle: ChartCircle) {
//        let circle = UIBezierPath()
//        circle.addArc(withCenter: viewFrameCenter, radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
//        circle.close()
//        
//        circle.lineWidth = chartCircle.lineWidth
//        
//        if let lineDash = chartCircle.lineDash {
//            circle.setLineDash([lineDash.length, lineDash.gap], count: 2, phase: 0)
//        }
//        
//        chartCircle.lineColor.setStroke()
//        circle.stroke()
//        chartCircle.fillColor.setFill()
//        circle.fill()
//    }
//    
//}
//
//
//extension Chart {
//    
//    private func drawSlices() {
//        
//        guard slices.count > 0  else { return }
//        
//        for index in 0..<slices.count {
//            let slice = slices[index]
//            let deltaAngle = (2 * CGFloat.pi) / CGFloat(slices.count)
//
//            let startAngle = CGFloat(index) * deltaAngle + ((2 * CGFloat.pi) * (3 / 4))
//            let endAngle = CGFloat(index + 1) * deltaAngle + ((2 * CGFloat.pi) * (3 / 4))
//
//            let actualRadius = slice.radiusMultiplier * maximumRadius
//
//            drawSlice(ofRadius: actualRadius, startAngle: startAngle, endAngle: endAngle, chartSlice: slice)
//        }
//        
//    }
//    
//    
//    private func drawSlice(ofRadius radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, chartSlice: ChartSlice) {
//        drawArc(forSlice: chartSlice, startAngle: startAngle, endAngle: endAngle, radius: radius)
//        drawTitle(forSlice: chartSlice, startAngle: startAngle, endAngle: endAngle)
//    }
//    
//    private func drawArc(forSlice chartSlice: ChartSlice, startAngle: CGFloat, endAngle: CGFloat, radius: CGFloat) {
//        
//        let arc = UIBezierPath()
//        
////        arc.lineWidth = chartSlice.lineWidth
//        arc.move(to: viewFrameCenter)
//        
//        var nextPoint = CGPoint.zero
//        
//        nextPoint.x = viewFrameCenter.x + radius * cos(startAngle)
//        nextPoint.y = viewFrameCenter.y + radius * sin(startAngle)
//        
//        arc.addLine(to: nextPoint)
//        arc.addArc(withCenter: viewFrameCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
//        arc.addLine(to: viewFrameCenter)
//        
////        chartSlice.lineColor.setStroke()
////        arc.stroke()
////        chartSlice.fillColor.setFill()
////        arc.fill()
//        
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.fillColor = chartSlice.fillColor.cgColor
//        shapeLayer.strokeColor = chartSlice.lineColor.cgColor
//        shapeLayer.lineWidth = chartSlice.lineWidth
//        shapeLayer.path = arc.cgPath
//        
//        layer.insertSublayer(shapeLayer, at: 0)
//        arcSlices.append(shapeLayer)
//    }
//    
//    
//    private func drawTitle(forSlice chartSlice: ChartSlice, startAngle: CGFloat, endAngle: CGFloat) {
//        guard let context = UIGraphicsGetCurrentContext()  else { return }
//        context.saveGState()
//        
//        let size = bounds.size
//        context.translateBy (x: size.width / 2, y: size.height / 2)
//        context.scaleBy (x: 1, y: -1)
//        
//        let centreAngle = ((startAngle + endAngle) / 2).truncatingRemainder(dividingBy: CGFloat.pi * 2)
//        var direction: Bool = true
//        if centreAngle >= 0 && centreAngle <= CGFloat.pi { direction = false }
//        
//        centreArcPerpendicular(chartLabel: chartSlice.chartLabel, context: context, radius: maximumRadius + 15, angle: -(startAngle + endAngle) / 2, clockwise: direction)
//        
//        context.restoreGState()
//    }
//    
//    
//}
//
//
//
//extension Chart {
//    
//    private func addTapGesture() {
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
//        tapGesture.numberOfTapsRequired = 1
//        tapGesture.numberOfTouchesRequired = 1
//        addGestureRecognizer(tapGesture)
//    }
//    
//    private func addRotationGesture() {
//        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(gesture:)))
//        addGestureRecognizer(rotationGesture)
//    }
//    
//    private func addGestures() {
//        addTapGesture()
//        addRotationGesture()
//    }
//    
//}
//
//
//extension Chart {
//    
//    func deSelectAllSlices() {
//        guard slices.count > 0 else { return }
//        for i in 0..<slices.count {
//            deSelectArc(atIndex: i)
//        }
//    }
//    
//    func selectArc(atIndex index: Int) {
//        guard index < slices.count, index >= 0  else { return }
//        deSelectAllSlices()
//        
//        let arc = arcSlices[index]
//        let slice = slices[index]
//
//        arc.lineWidth = selectedSliceLineWidth ?? slice.lineWidth
//        arc.strokeColor = (selectedSliceLineColor ?? slice.lineColor).cgColor
//        arc.fillColor = (selectedSliceFillColor ?? slice.fillColor).cgColor
//        
////        arc.lineWidth = selectedSliceLineWidth ?? slice.lineWidth
////        (selectedSliceLineColor ?? slice.lineColor).setStroke()
////        arc.stroke()
////        (selectedSliceFillColor ?? slice.fillColor).setFill()
////        arc.fill()
//    }
//    
//    func deSelectArc(atIndex index: Int) {
//        guard index < slices.count, index >= 0  else { return }
//        let arc = arcSlices[index]
//        let slice = slices[index]
//        
//        arc.lineWidth = slice.lineWidth
//        arc.strokeColor = slice.lineColor.cgColor
//        arc.fillColor = slice.fillColor.cgColor
//        
////        arc.lineWidth = slice.lineWidth
////        slice.lineColor.setStroke()
////        arc.stroke()
////        slice.fillColor.setFill()
////        arc.fill()
//    }
//
//}
//
//
//extension Chart {
//    
//    @objc private func handleTap(gesture: UITapGestureRecognizer) {
//        guard isTapGestureEnabled  else { return }
//        let tapPoint = gesture.location(in: self)
//        var index = 0
//        
//        for arcSlice in arcSlices {
//            guard !(arcSlice.path?.contains(tapPoint) ?? false)
//            else { selectedIndex = index; break; }
//            index += 1
//        }
//    }
//    
//    @objc private func handleRotation(gesture: UIRotationGestureRecognizer) {
//        guard isRotationGestureEnabled  else { return }
//        transform = transform.rotated(by: gesture.rotation)
//        gesture.rotation = 0
//        delegate?.didRotateChart?()
//    }
//    
//}
//
//
//
//
//extension Chart {
//
//    private func centreArcPerpendicular(chartLabel: ChartLabel, context: CGContext, radius r: CGFloat, angle theta: CGFloat, clockwise: Bool){
//        // *******************************************************
//        // This draws the String str around an arc of radius r,
//        // with the text centred at polar angle theta
//        // *******************************************************
//        
//        let characters: [String] = chartLabel.text.map { String($0) } // An array of single character strings, each character in str
//        let l = characters.count
//        let attributes = [NSAttributedStringKey.font: chartLabel.font]
//        
//        var arcs: [CGFloat] = [] // This will be the arcs subtended by each character
//        var totalArc: CGFloat = 0 // ... and the total arc subtended by the string
//        
//        // Calculate the arc subtended by each letter and their total
//        for i in 0 ..< l {
//            arcs += [chordToArc(characters[i].size(withAttributes: attributes).width, radius: r)]
//            totalArc += arcs[i]
//        }
//        
//        // Are we writing clockwise (right way up at 12 o'clock, upside down at 6 o'clock)
//        // or anti-clockwise (right way up at 6 o'clock)?
//        let direction: CGFloat = clockwise ? -1 : 1
//        let slantCorrection: CGFloat = clockwise ? -.pi / 2 : .pi / 2
//        
//        // The centre of the first character will then be at
//        // thetaI = theta - totalArc / 2 + arcs[0] / 2
//        // But we add the last term inside the loop
//        var thetaI = theta - direction * totalArc / 2
//        
//        for i in 0 ..< l {
//            thetaI += direction * arcs[i] / 2
//            // Call centerText with each character in turn.
//            // Remember to add +/-90º to the slantAngle otherwise
//            // the characters will "stack" round the arc rather than "text flow"
//            centre(text: characters[i], context: context, radius: r, angle: thetaI, colour: chartLabel.color, font: chartLabel.font, slantAngle: thetaI + slantCorrection)
//            // The centre of the next character will then be at
//            // thetaI = thetaI + arcs[i] / 2 + arcs[i + 1] / 2
//            // but again we leave the last term to the start of the next loop...
//            thetaI += direction * arcs[i] / 2
//        }
//    }
//    
//    private func chordToArc(_ chord: CGFloat, radius: CGFloat) -> CGFloat {
//        return 2 * asin(chord / (2 * radius))
//        /// bcoz the angle extended at the center is two times that of the top. Also, when extended to the diameter, it will be a 90 deg triangle for sure (traingle with diameter as a side incribed in a circle will always be a right triangle). So, sin can be calculated easily.
//    }
//    
//    private func centre(text str: String, context: CGContext, radius r: CGFloat, angle theta: CGFloat, colour c: UIColor, font: UIFont, slantAngle: CGFloat) {
//        // *******************************************************
//        // This draws the String str centred at the position
//        // specified by the polar coordinates (r, theta)
//        // i.e. the x= r * cos(theta) y= r * sin(theta)
//        // and rotated by the angle slantAngle
//        // *******************************************************
//        
//        
//        // Set the text attributes
//        let attributes = [NSAttributedStringKey.foregroundColor: c, NSAttributedStringKey.font: font]
//        //let attributes = [NSForegroundColorAttributeName: c, NSFontAttributeName: font]
//        // Save the context
//        context.saveGState()
//        // Undo the inversion of the Y-axis (or the text goes backwards!)
//        context.scaleBy(x: 1, y: -1)
//        // Move the origin to the centre of the text (negating the y-axis manually)
//        context.translateBy(x: r * cos(theta), y: -(r * sin(theta)))
//        // Rotate the coordinate system
//        context.rotate(by: -slantAngle)
//        // Calculate the width of the text
//        let offset = str.size(withAttributes: attributes)
//        // Move the origin by half the size of the text
//        context.translateBy (x: -offset.width / 2, y: -offset.height / 2) // Move the origin to the centre of the text (negating the y-axis manually)
//        // Draw the text
//        str.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
//        // Restore the context
//        context.restoreGState()
//    }
//
//}
//
//
//extension CGFloat {
//    func toRadians() -> CGFloat {
//        return self * CGFloat.pi / 180.0
//    }
//}
