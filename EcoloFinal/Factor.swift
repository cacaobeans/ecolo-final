//
//  Factor.swift
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

enum MovementType: String {
    case Aerial
    case Terrestrial
    case Static
}

class Factor: CustomStringConvertible, Hashable {
    
    // Factor-specific data required for rendering the correct number of sprites on screen.
    // Eventually, these will be set by the initializer from data stored in the plist file.
    let standardPopulationSize = 1
    let populationRenderCurveLogBase: Double = 2.0
    
    // Standard identification data and functions:
    private static var nextHashValue = 0
    let hashValue: Int
    static func ==(f1: Factor, f2: Factor) -> Bool {return f1.hashValue == f2.hashValue}
    var description: String {return "\(name) – lvl \(level)"}
    
    // Data required by pretty much everything:
    let name: String
    var level: Double
    let delegate: FactorDelegate
    let type: FactorType
    let movement: MovementType
    
    // Helper properties:
    private var delta = 0.0
    
    // Initializer:
    init(_ name: String, type: FactorType, movement: MovementType, level: Double, delegate: FactorDelegate) {
        self.name = name
        self.type = type
        self.movement = movement
        self.level = level
        self.delegate = delegate
        hashValue = Factor.nextHashValue
        Factor.nextHashValue += 1
    }
    
    // The calculation run in the first half of the Evolve cycle:
    func calculateDelta() {
        switch type {
            case .Producer: lvProducer()
            case .Consumer: lvConsumer()
            default: break
        }
    }
    
    // Run in the second half of the cycle:
    func addDeltaToLevel() {
        level += delta / Double(delegate.getEulerIntervals())
        if level < delegate.getExtinctionThreshold() {
            level = 0
        }
    }
    
    
    
    // If this factor is a porducer, it needs to screen all of the factors affecting it for type and use the Resources in an alternate carrying capacity calculation.
    private func lvProducer() {
        delta = 0.0
        var carryingCapacityReduction = 0.0
        var naturalChangeRate = 0.0
        if let interactions = delegate.getFactorsWithInteractions()[self] {
            for (affectingFactor, effectCoefficient) in interactions {
                if affectingFactor.type == .Resource {
                    carryingCapacityReduction += 0.01 * (effectCoefficient - affectingFactor.level) * (effectCoefficient - affectingFactor.level) //effectCoefficient represents the ideal level of Resource (ranging from -10 to 10), affectingFactor.level represents the level of Resource actually available (same range)
                } else if affectingFactor == self {
                    naturalChangeRate = effectCoefficient
                } else {
                    delta += effectCoefficient * self.level * affectingFactor.level
                }
            }
            delta += naturalChangeRate * self.level * (1 - carryingCapacityReduction)
        }
    }
    
    // If this factor is a consumer, then the job is a lot simpler:
    private func lvConsumer() {
        delta = 0.0
        var carryingCapacityReduction = 0.0
        var naturalChangeRate = 0.0
        if let interactions = delegate.getFactorsWithInteractions()[self] {
            for (affectingFactor, effectCoefficient) in interactions {
                if affectingFactor.type == .Resource {
                    carryingCapacityReduction += 0.01 * (effectCoefficient - affectingFactor.level) * (effectCoefficient - affectingFactor.level) //effectCoefficient represents the ideal level of Resource (ranging from -10 to 10), affectingFactor.level represents the level of Resource actually available (same range)
                } else if affectingFactor == self {
                    naturalChangeRate = effectCoefficient
                    delta += effectCoefficient * self.level * affectingFactor.level
                } else {
                    delta += effectCoefficient * self.level * affectingFactor.level
                }
            }
            delta += naturalChangeRate * self.level * (1 - carryingCapacityReduction)
        }
        
        /*delta = 0.0
        if let interactions = delegate.getFactorsWithInteractions()[self] {
            for (affectingFactor, effectCoefficient) in interactions {
                delta += effectCoefficient * self.level * affectingFactor.level
            }
        }*/
    }
}
