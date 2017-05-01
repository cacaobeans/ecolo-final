//
//  Ecosystem.swift
//  Ecolo Model Testing
//
//  Created by Jonathan J. Lee on 4/26/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import Foundation

protocol FactorDelegate {
    func getEulerIntervals() -> Int
    func getExtinctionThreshold() -> Double
    func getFactorsWithInteractions() -> [Factor: [Factor: Double]]
}

class Ecosystem: CustomStringConvertible, FactorDelegate {
    
    let name: String
    let factorData: [String: [String: [String: String]]]
    let eulerIntervals = 100
    // Because the differential equations governing population are not integrable, population changes must be approximated using Euler's method.
    // These are the number of intervals (i.e., the number of times the calculation repeats) per cycle.
    // The higher the number, the more accurate the changes, but the slower the program.
    let extinctionThreshold = 10e-3
    // When the normalized population size drops below the extinction threshold, the population crashes and goes extinct due to lack of genetic diversity.
    private var factors = [Factor: [Factor: Double]]()
    // The first factor is the one being affected. The second factor is the one affecting it.
    // The double is the interaction coefficient.
    // If a factor is affecting itself, then that represents natural growth or death rates.
    
    init?(name: String) {
        guard let path = Bundle.main.path(forResource: "FactorData", ofType: "plist"),
            let data = NSDictionary(contentsOfFile: path) as? [String: [String: [String: String]]] else {
            print("Failed to read in data at path FactorData.plist")
            return nil
        }
        self.name = name
        self.factorData = data
    }
    
    @discardableResult func add(_ newFactorName: String, ofType type: FactorType, withLevel level: Double) -> Bool {
        
        // Step 1: Retrieve the [String: String] dictionary of the new factor's Possible Interactions with all possible organisms, even those that aren't in this ecosystem.
        // If we couldn't retrieve the PI, then that means that we don't have any data for the new factor and there's an error.
        guard let nfPI = factorData[type.rawValue]?[newFactorName] else {
            print("Failed to add \(newFactorName); couldn't find it in FactorData.plist")
            return false
        }
        
        // Step 2: Add the new factor to the main storage array with an empty interaction coefficient dictionary (ICD).
        // We'll fill the ICD in Step 3.
        let newFactor = Factor(newFactorName, type: type, level: level, delegate: self)
        factors[newFactor] = [Factor: Double]() // This dictionary is the ICD.
        
        
        // Step 3: Iterate through the main 'factors' dictionary.
        // First, we look to see which of the existing factors will be interacting with this new one – namely, which of the existing factors has a corresponding coefficient in the NFPI.
        // If we found a corresponding coefficient in the new factor's PI, then we add it to the ICD under the name of the existing factor.
        for (existingFactor, _) in factors {
            if let stringCoeffForNew = nfPI[existingFactor.name], let coeffForNewFactor = Double(stringCoeffForNew) {
                factors[newFactor]![existingFactor] = coeffForNewFactor
            }
            
            // Next, we see if any of the existing factors' PIs has a coefficient linking it to the new factor.
            // If so, we add that coefficient to the appropriate existing factor's ICD under the name of the new factor.
            if let stringCoeffForExisting = factorData[existingFactor.type.rawValue]?[existingFactor.name]?[newFactor.name],
                let coeffForExistingFactor = Double(stringCoeffForExisting) {
                factors[existingFactor]![newFactor] = coeffForExistingFactor
            }
        }
        return true
    }
    
    func nextCycle() {
        for _ in 0 ..< eulerIntervals {
            // In the first round, we calculate the minute changes (deltas) for all of the factors.
            for (factor, _) in factors {
                factor.calculateDelta()
            }
            // In the second round, we apply those deltas to each factor's level.
            // The reason we can't do them both in one step is that in order to calculate the deltas, we need to access the levels of the factors before they're updated.  Only after we've safely computed all of the changes can we update this level.
            for (factor, _) in factors {
                factor.addDeltaToLevel()
            }
        }
    }
    
    
    // The methods demanded by the delegate:
    func getFactorsWithInteractions() -> [Factor : [Factor : Double]] {
        return factors
    }
    
    func getExtinctionThreshold() -> Double {
        return extinctionThreshold
    }
    
    func getEulerIntervals() -> Int {
        return eulerIntervals
    }
    
    // Diagnostic and informational functions:
    var description: String {
        return self.name
    }
    
    var currentState: String {
        return factors.reduce("", {$0 + "\t \($1.0.name): \($1.0.level)"})
    }
    
    var diagnostics: String {
        var result = ""
        for (factor, interactions) in factors {
            result += "\(factor.name) – lvl \(factor.level):"
            for (affectingFactor, coefficient) in interactions {
                result += "\n\t\(coefficient) from \(affectingFactor.name)"
            }
            result += "\n"
        }
        return result
    }
}
