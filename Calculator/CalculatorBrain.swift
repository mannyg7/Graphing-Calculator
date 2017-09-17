//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Manmitha Gundampalli on 9/9/17.
//  Copyright © 2017 MannyG. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case equals
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt, {"√" + "(" + $0 + ")"}),
        "cos" : Operation.unaryOperation(cos, {"cos" + "(" + $0 + ")"}),
        "sin" : Operation.unaryOperation(sin, {"sin" + "(" + $0 + ")"}),
        "tan" : Operation.unaryOperation(tan, {"tan" + "(" + $0 + ")"}),
        "±" : Operation.unaryOperation({-$0}, {"±" + "(" + $0 + ")"}),
        "log" : Operation.unaryOperation(log10, {"log" + "(" + $0 + ")"}),
        "ln" : Operation.unaryOperation(log, {"ln" + "(" + $0 + ")"}),
        "×" : Operation.binaryOperation({$0 * $1}, {$0 + " " + "×" + " " + $1}),
        "÷" : Operation.binaryOperation({$0 / $1}, {$0 + " " + "÷" + " " + $1}),
        "+" : Operation.binaryOperation({$0 + $1}, {$0 + " " + "+" + " " + $1}),
        "-" : Operation.binaryOperation({$0 - $1}, {$0 + " " + "-" + " " + $1}),
        "=" : Operation.equals
    ]
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
        
        let sequenceOfOperationsFunction: (String, String) -> String
        
        let firstSequence: String
        
        func combineSequences(with secondSequence: String) -> String {
            return sequenceOfOperationsFunction(firstSequence, secondSequence)
        }
    }
    
    func evaluate (using variables: Dictionary<String,Double>? = nil)
        -> (result: Double?, isPending: Bool, description: String){
            
            var accumulator: Double?
            
            var sequenceOfOperands: String?
            
            var pendingBinaryOperation: PendingBinaryOperation?
            
            
            func clear() {
                accumulator = 0;
                pendingBinaryOperation = nil;
                sequenceOfOperands = ""
            }

            
            func setOperand(_ operand: Double) {
                accumulator = operand
                sequenceOfOperands = String(operand)
            }
            
            func setOperand(varible named: String) {
                if variables?[named] != nil {
                    accumulator = variables?[named]
                } else {
                    accumulator = 0
                }
                sequenceOfOperands = named
                
            }
            
            var result: Double? {
                get {
                    return accumulator
                }
            }
            
            var description: String? {
                get {
                    if pendingBinaryOperation != nil {
                        if sequenceOfOperands != nil {
                            return pendingBinaryOperation!.sequenceOfOperationsFunction(pendingBinaryOperation!.firstSequence, sequenceOfOperands!)
                        } else {
                            return pendingBinaryOperation!.sequenceOfOperationsFunction(pendingBinaryOperation!.firstSequence, "")
                        }
                    }  else {
                        return sequenceOfOperands
                    }
                }
            }
            
            var resultIsPending: Bool {
                get {
                    return pendingBinaryOperation != nil
                }
            }
            
            func performPendingBinaryOperation() {
                if pendingBinaryOperation != nil && accumulator != nil {
                    accumulator = pendingBinaryOperation!.perform(with: accumulator!)
                    sequenceOfOperands = pendingBinaryOperation!.combineSequences(with: sequenceOfOperands!)
                    pendingBinaryOperation = nil
                    
                }
            }
            
            func performOperation(_ symbol: String) {
                if let operation = operations[symbol] {
                    switch operation {
                    case .constant(let value):
                        accumulator = value
                        sequenceOfOperands = symbol
                    case .unaryOperation(let function, let sequenceFunction):
                        if accumulator != nil {
                            accumulator = function(accumulator!)
                            if sequenceOfOperands != nil {
                                sequenceOfOperands = sequenceFunction(sequenceOfOperands!)
                            }
                        }
                    case .binaryOperation(let function, let sequenceFunction):
                        performPendingBinaryOperation()
                        if accumulator != nil {
                            pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!, sequenceOfOperationsFunction: sequenceFunction, firstSequence: sequenceOfOperands!)
                            sequenceOfOperands = nil
                            accumulator = nil
                        }
                    case .equals:
                        performPendingBinaryOperation()
                        
                    }
                    
                }
            }
            
            func calculate() {
                pendingBinaryOperation = nil;
                for eachOperation in historyOfOperations {
                    switch eachOperation {
                    case .number(let number):
                        setOperand(number)
                    case .variable(let named):
                        setOperand(varible: named)
                    case .operators(let symbol):
                        performOperation(symbol)
                    }
                }
                
            }
            
            
            
            if historyOfOperations.count == 0 {
                return (nil, false, "")
            } else {
                calculate()
            }
            if description != nil {
                return (result, resultIsPending, description!)
            } else {
                return (result, resultIsPending, "")
                
            }
            
            
    }
    
    @available(iOS, deprecated)
    var result: Double? {
        get {
            return evaluate().result
        }
    }
    @available(iOS, deprecated)
    var description: String? {
        get {
            return evaluate().description
        }
    }
    @available(iOS, deprecated)
    var resultIsPending: Bool {
        get {
            return evaluate().isPending
        }
    }
 
    private enum OperationValues {
        case number(Double)
        case variable(String)
        case operators(String)
    }
    
    private var historyOfOperations = [OperationValues]()
    
    mutating func setOperand(_ operand: Double) {
        historyOfOperations.append(OperationValues.number(operand))
    }
    
    mutating func setOperand(varible named: String) {
        historyOfOperations.append(OperationValues.variable(named))
    }
    
    mutating func performOperation(_ symbol: String) {
        historyOfOperations.append(OperationValues.operators(symbol))
    }
    
    mutating func clear() {
        historyOfOperations.removeAll()
    }
    
    mutating func undo() {
        if historyOfOperations.count != 0 {
            historyOfOperations.remove(at: historyOfOperations.index(before: historyOfOperations.endIndex))
        }
    }

}
