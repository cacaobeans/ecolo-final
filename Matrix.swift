//
//  Matrix.swift
//  Ecolo Model Testing
//
//  Created by Jonathan J. Lee on 3/28/17.
//  Copyright © 2017 Jonathan J. Lee. All rights reserved.
//

import Foundation

func * (first: Matrix, second: Matrix) -> Matrix? {
    
    guard first.columnsX == second.rowsY else {
        return nil
    }
    
    let productMatrix = Matrix(rowsY: first.rowsY, columnsX: second.columnsX)!
    for columnIndex in 0..<productMatrix.columnsX {
        for rowIndex in 0..<productMatrix.rowsY {
            
            var newValue = 0.0
            let firstRow = first.getRow(rowIndex)
            let secondColumn = second.getColumn(columnIndex)
            
            guard firstRow != nil && secondColumn != nil else {
                return nil
            }
            
            for index in 0..<firstRow!.count {
                newValue += firstRow![index] * secondColumn![index]
            }
            
            productMatrix.setElement(rowY: rowIndex, columnX: columnIndex, newElement: newValue)
        }
    }
    return productMatrix
}

class Matrix: CustomStringConvertible {
    
    fileprivate var elements: [[Double]]
    var rowsY: Int
    var columnsX: Int
    
    init?(rowsY: Int, columnsX: Int) {
        guard rowsY > 0 && columnsX > 0 else {
            return nil
        }
        self.rowsY = rowsY
        self.columnsX = columnsX
        elements = [[Double]](repeating: ([Double](repeating: 0.0, count: columnsX)), count: rowsY)
    }
    
    @discardableResult func setElement(rowY: Int, columnX: Int, newElement: Double) -> Bool {
        if rowY < 0 || rowY >= rowsY || columnX < 0 || columnX >= columnsX {
            return false
        } else {
            elements[rowY][columnX] = newElement
            return true
        }
    }
    
    func getElement(rowY: Int, columnX: Int) -> Double? {
        if rowY < 0 || rowY >= rowsY || columnX < 0 || columnX >= columnsX {
            return nil
        } else {
            return elements[rowY][columnX]
        }
    }
    
    func getRow(_ rowIndex: Int) -> [Double]? {
        if rowIndex < 0 || rowIndex >= rowsY {
            return nil
        } else {
            return elements[rowIndex]
        }
    }
    
    func getColumn(_ columnIndex: Int) -> [Double]? {
        if columnIndex < 0 || columnIndex >= columnsX {
            return nil
        } else {
            var column = [Double]()
            for row in elements {
                column.append(row[columnIndex])
            }
            return column
        }
    }
    
    func map(_ function: (Double) -> Double) {
        for rowIndex in 0..<rowsY {
            elements[rowIndex] = elements[rowIndex].map(function)
        }
    }
    
    func increaseRows() {
        elements.append([Double](repeating: 0.0, count: columnsX))
        rowsY += 1
    }
    
    func increaseColumns() {
        columnsX += 1
        for rowIndex in 0..<rowsY {
            elements[rowIndex].append(0.0)
        }
    }
    
    func increaseSize() {
        increaseRows()
        increaseColumns()
    }
    
    //Method to find identity matrix
    //Method to return the adjoint matrix
    //Method to find determinant
    //Method to return transpose
    
    var description: String {
        var maximumLength = 0
        for row in elements {
            for element in row {
                let elementStringCount = String(describing: element).characters.count
                if elementStringCount > maximumLength {maximumLength = elementStringCount}
            }
        }
        var result = "┌" + String(repeating: " ", count: 1 + (maximumLength + 1) * columnsX) + "┐"
        for rowIndex in 0..<rowsY {
            guard let row = getRow(rowIndex) else {
                return "Could not print Matrix; encountered problem with Row \(rowIndex)"
            }
            result += "\n│ "
            for element in row {
                var elementString = String(describing: element)
                let spacesToAdd = maximumLength - elementString.characters.count
                if spacesToAdd > 0 {
                    elementString += String(repeating: " ", count: spacesToAdd)
                }
                result += elementString + " "
            }
            result += "│"
        }
        result += "\n└" + String(repeating: " ", count: 1 + (maximumLength + 1) * columnsX) + "┘"
        return result
    }
}

class InteractionMatrix: Matrix {
    
    var size: Int {
        get {return rowsY}
        set {
            rowsY = newValue
            columnsX = newValue
        }
    }
    
    init?(size: Int) {
        super.init(rowsY: size, columnsX: size)
    }
}
