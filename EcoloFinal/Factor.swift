//
//  SavannaAbioticElement.swift
//  Ecolo Model Testing
//
//  Created by Jonathan J. Lee on 2/28/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import Foundation

enum FactorType: String {
    case Producer
    case Consumer
    case Resource
}

class Factor: CustomStringConvertible, Hashable {
    
    private static var nextHashValue = 0
    let hashValue: Int
    let name: String
    var level: Double
    let delegate: FactorDelegate
    let type: FactorType
    private var delta = 0.0
    var description: String {
        return "\(name) – lvl \(level)"
    }
    
    init(_ name: String, type: FactorType, level: Double, delegate: FactorDelegate) {
        self.name = name
        self.type = type
        self.level = level
        self.delegate = delegate
        hashValue = Factor.nextHashValue
        Factor.nextHashValue += 1
    }
    
    static func ==(f1: Factor, f2: Factor) -> Bool {
        return f1.hashValue == f2.hashValue
    }
    
    
    func calculateDelta() {
        switch type {
            case .Producer: lvProducer()
            case .Consumer: lvConsumer()
            default: break
        }
    }
    
    func addDeltaToLevel() {
        level += delta / Double(delegate.getEulerIntervals())
        if level < delegate.getExtinctionThreshold() {
            level = 0
        }
    }
    
    private func lvProducer() {
        delta = 0.0
        var carryingCapacityReduction = 0.0
        var naturalChangeRate = 0.0
        if let interactions = delegate.getFactorsWithInteractions()[self] {
            for (affectingFactor, effectCoefficient) in interactions {
                if affectingFactor.type == .Resource {
                    carryingCapacityReduction += effectCoefficient * self.level * affectingFactor.level
                } else if affectingFactor == self {
                    naturalChangeRate = effectCoefficient
                } else {
                    delta += effectCoefficient * self.level * affectingFactor.level
                }
            }
            delta += naturalChangeRate * self.level * (1 - carryingCapacityReduction)
        }
    }
    
    private func lvConsumer() {
        delta = 0.0
        if let interactions = delegate.getFactorsWithInteractions()[self] {
            for (affectingFactor, effectCoefficient) in interactions {
                delta += effectCoefficient * self.level * affectingFactor.level
            }
        }
    }
}
