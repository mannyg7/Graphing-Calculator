//
//  GraphingViewController.swift
//  Calculator
//
//  Created by Manmitha Gundampalli on 9/17/17.
//  Copyright © 2017 MannyG. All rights reserved.
//

import UIKit

class GraphingViewController: UIViewController {
    
    var graphingFunction: ((Double) -> Double?)? {
        didSet {
            graphingView?.graphingFunction = graphingFunction
        }
    }
    
    
    @IBOutlet weak var graphingView: GraphingView! {
        didSet {
            let doubleTapREcognizer = UITapGestureRecognizer(target: graphingView, action: #selector(GraphingView.doubleTapping(tapRecognizer:)))
            doubleTapREcognizer.numberOfTapsRequired = 2
            graphingView.addGestureRecognizer(doubleTapREcognizer)
            
            let zoomRecognizer = UIPinchGestureRecognizer(target: graphingView, action: #selector(GraphingView.zooming(pinchRecognizer:)))
            graphingView.addGestureRecognizer(zoomRecognizer)
            
            let panningRecognizer = UIPanGestureRecognizer(target: graphingView, action: #selector(GraphingView.panning(panRecognizer:)))
            graphingView.addGestureRecognizer(panningRecognizer)
            
            graphingView?.graphingFunction = graphingFunction
        }
    }
    
    
    
    

    
}
