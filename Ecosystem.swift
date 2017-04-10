//
//  Ecosystem.swift
//  Ecolo Model Testing
//
//  Created by Jonathan J. Lee on 2/28/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import Foundation

protocol EcosystemProtocol {
    func add(_ factor: Factor)
    func addPairing(factor1: Factor, factor2: Factor, effect1: Double, effect2: Double) -> Bool
    func nextCycle()
}

protocol FactorDelegate {
    func getCycle() -> Int
    func getEulerIntervals() -> Int
    func getInteractionMatrix() -> InteractionMatrix
    func getMortalityMatrix() -> Matrix
    func getFactors() -> TwoWayDictionary<Int, Factor>
}

class Ecosystem: CustomStringConvertible, EcosystemProtocol, FactorDelegate {
    
    var nextFactorIndex = 0
    var factors = TwoWayDictionary<Int, Factor>()
    var interactionMatrix = InteractionMatrix(size: 1)!
    var mortalityMatrix = Matrix(rowsY: 1, columnsX: 1)!
    
    var cycle = 0
    var description: String
    var eulerIntervals = 100
    
    init(name: String) {
        description = name
    }
    
    func add(_ factor: Factor) {
        factors[nextFactorIndex] = factor
        if nextFactorIndex > 0 {
            interactionMatrix.increaseSize()
            mortalityMatrix.increaseRows()
        }
        nextFactorIndex += 1
    }
    
    @discardableResult func addPairing(factor1: Factor, factor2: Factor, effect1: Double, effect2: Double) -> Bool {
        guard factors.values.contains(factor1) && factors.values.contains(factor2) && interactionMatrix.size >= nextFactorIndex else {
            print("Failed to add relationship \(effect1) to \(factor1) with \(effect2) to \(factor2)")
            return false
        }
        interactionMatrix.setElement(rowY: factors[factor1]!, columnX: factors[factor2]!, newElement: effect1)
        interactionMatrix.setElement(rowY: factors[factor2]!, columnX: factors[factor1]!, newElement: effect2)
        return true
    }
    
    @discardableResult func addNaturalChangeConstant(factor: Factor, constant: Double) -> Bool {
        guard factors.values.contains(factor) && mortalityMatrix.rowsY >= nextFactorIndex else {
            print("Failed to add change constant \(constant) to \(factor)")
            return false
        }
        mortalityMatrix.setElement(rowY: factors[factor]!, columnX: 0, newElement: constant)
        return true
    }
    
    func getCycle() -> Int {
        return cycle
    }
    
    func getEulerIntervals() -> Int {
        return eulerIntervals
    }
    
    func getInteractionMatrix() -> InteractionMatrix {
        return interactionMatrix
    }
    
    func getMortalityMatrix() -> Matrix {
        return mortalityMatrix
    }
    
    func getFactors() -> TwoWayDictionary<Int, Factor> {
        return factors
    }
 
    func nextCycle() {
        cycle += 1
        for _ in 0..<eulerIntervals {
            /*for factor in factors.values {
                factor.nextCycle()
            }*/
            for factor in factors.values {
                
                factor.update()
            }
        }
    }
    
    func printFactors() {
        for factor in factors.values {
            print(factor)
        }
    }
}



