//
//  ViewController.swift
//  Calculator
//
//  Created by Manmitha Gundampalli on 9/7/17.
//  Copyright © 2017 MannyG. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var displayMValue: UILabel!
    
    private var userIsInTheMiddleOfTyping: Bool = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            if digit != "." || display.text!.contains(".") == false {
                display.text = textCurrentlyInDisplay + digit
            }
            
        } else {
            if digit == "." {
                display.text = "0\(digit)"
            } else {
                display.text = digit
            }
            
            userIsInTheMiddleOfTyping = true
        }
        
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    
    
    private var brain = CalculatorBrain()
    
    private func displayEvaluatedResult (_ evalResult: (result: Double?, isPending: Bool, description: String)) {
        if (evalResult.result != nil) {
            displayValue = evalResult.result!
        }
        if (evalResult.description != "") {
            if evalResult.isPending {
                descriptionLabel.text = evalResult.description + " ..."
            } else {
                descriptionLabel.text = evalResult.description + " ="
            }
        } else {
            descriptionLabel.text = evalResult.description
        }
        if variables["M"] != nil {
            displayMValue.text = String(describing: variables["M"]!)
        } else {
            displayMValue.text = ""
        }
        
        
    }
    
    private var variables = [String: Double]()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayEvaluatedResult(brain.evaluate(using: variables))
        
    }
    
    @IBAction func setM(_ sender: UIButton) {
        brain.setOperand(varible: sender.currentTitle!)
        displayEvaluatedResult(brain.evaluate(using: variables))
        
    }
    
    @IBAction func clear(_ sender: UIButton) {
        brain.clear()
        variables.removeAll()
        displayValue = 0
        displayMValue.text = ""
        descriptionLabel.text = ""
        userIsInTheMiddleOfTyping = false
    }
    
    @IBAction func undo(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping == true {
            if display.text!.characters.count != 0 {
                display.text!.remove(at: display.text!.index(before: display.text!.endIndex))
                display.text = display.text!
            }
        } else {
            brain.undo()
            displayEvaluatedResult(brain.evaluate(using: variables))
        }
    }
    
    @IBAction func loadM(_ sender: UIButton) {
        variables["M"] = Double(displayValue)
        displayEvaluatedResult(brain.evaluate(using: variables))
        userIsInTheMiddleOfTyping = false
    }
    
}

