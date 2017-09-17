//
//  GraphingView.swift
//  Calculator
//
//  Created by Manmitha Gundampalli on 9/17/17.
//  Copyright © 2017 MannyG. All rights reserved.
//

import UIKit

@IBDesignable
class GraphingView: UIView {

    @IBInspectable
    var scale: CGFloat = 50.0 {
        didSet
        {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var color = UIColor.black { didSet{setNeedsDisplay()}}
    
    @IBInspectable
    var lineWidth: CGFloat = 1.0 { didSet{setNeedsDisplay()}}
    
    var graphingFunction: ((Double) -> Double?)? { didSet{ setNeedsDisplay()}}
    
    var origin: CGPoint! { didSet {setNeedsDisplay()}}
    
    private var drawer = AxesDrawer()

   
    override func draw(_ rect: CGRect) {
        drawer.color = UIColor.red
        origin = origin ?? CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        if (graphingFunction != nil) {
            let path = UIBezierPath()
            path.lineWidth = lineWidth
            var xcoord: CGFloat
            var ycoord: CGFloat
            var lastPointInvalid = true
            let pixelsAcrossWidth = Int(contentScaleFactor*bounds.size.width)
            for pixel in 0...pixelsAcrossWidth{
                xcoord = CGFloat(pixel)/contentScaleFactor
                if let y = graphingFunction!(Double((xcoord - origin.x) / scale)) {
                    if y.isNormal || y.isZero {
                        ycoord = origin.y - CGFloat(y) * scale
                        if lastPointInvalid {
                            path.move(to: CGPoint(x: xcoord, y: ycoord))
                            lastPointInvalid = false
                        } else {
                            path.addLine(to: CGPoint(x: xcoord, y: ycoord))
                        }
                    } else {
                        lastPointInvalid = true
                    }
                } else {
                    lastPointInvalid = true
                }
            }
            path.stroke()
        }
        drawer.drawAxes(in: bounds, origin: origin, pointsPerUnit: scale)
    }
    
    
    func zooming(pinchRecognizer: UIPinchGestureRecognizer) {
        if pinchRecognizer.state == .changed {
            scale *= pinchRecognizer.scale
            pinchRecognizer.scale = 1.0
        }
    }
    
    
    func doubleTapping(tapRecognizer: UITapGestureRecognizer) {
        if tapRecognizer.state == .ended {
            origin = tapRecognizer.location(in: self)
        }
    }
    
    func panning(panRecognizer: UIPanGestureRecognizer) {
        switch panRecognizer.state {
        case .ended: fallthrough
        case .changed:
            let translation = panRecognizer.translation(in: self)
            origin.x += translation.x
            origin.y += translation.y
            panRecognizer.setTranslation(CGPoint.zero, in: self)
        default: break
        }
    }

}
