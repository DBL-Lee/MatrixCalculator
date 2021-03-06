//
//  Matrix.swift
//  MCalculator
//
//  Created by Ying on 15/7/1.
//  Copyright (c) 2015年 Ying. All rights reserved.
//

import UIKit

func *(m1:Matrix,m2:Matrix) throws ->Matrix{
    do{
        return try m1.mult(m2)
    }catch {
        throw error
    }
}

func +(m1:Matrix,m2:Matrix) throws ->Matrix{
    do{
        return try m1.add(m2)
    }catch {
        throw error
    }
}

func -(m1:Matrix,m2:Matrix) throws ->Matrix{
    do{
        return try m1.subtract(m2)
    }catch {
        throw error
    }
}


// this class is immutable
class Matrix {

    //static functions
    class func identity(_ row:Int,column:Int)-> Matrix{
        var v:[Fraction]=[]
        for i in 0..<row{
            for j in 0..<column{
                if (i == j){
                    v.append(Fraction(i: 1))
                }
                else{
                    v.append(Fraction(i: 0))
                }
            }
        }
        return Matrix(r: row, c: column, value: v)
    }
    
    class func identity(_ n:Int) -> Matrix{
        return Matrix.identity(n, column: n)
    }
    
    class func houseHolder(_ w:Matrix) -> Matrix{
        let n = w.matrix.count
        return try! Matrix.identity(n) - w*w.transpose().multScalar(Fraction(i:2)/(w.transpose()*w).matrix[0][0])
    }


    //non-static functions
    let row:Int
    let column:Int
    var matrix:[[Fraction]] = []
	//decimal or fractional representation
	var decimal:[[Bool]] = []
    
    convenience init(r:Int, c:Int, value:[Fraction],decimal:[[Bool]]){
        self.init(r: r,c: c,value: value)
        for i in 0..<decimal.count{
            for j in 0..<decimal[i].count{
                if i<self.decimal.count && j<self.decimal[i].count {
                    self.decimal[i][j] = decimal[i][j]
                }
            }
        }
    }
    
    init(r:Int, c:Int, value:[Fraction]){
        var value = value
        assert(value.count==r*c, "length does not match")
        row = r
        column = c
        for i in 0..<r{
            matrix.append([])
            for _ in 0..<c {
                matrix[i].append(value.remove(at: 0))
            }
        }
		self.decimal = [[Bool]](repeating: [Bool](repeating: false, count: column),count: row)
    }
    
    init(r:Int, c:Int){
        row = r
        column = c
        self.matrix = [[Fraction]](repeating: [Fraction](repeating: Fraction(i: 0), count: column),count: row)
		self.decimal = [[Bool]](repeating: [Bool](repeating: false, count: column),count: row)
	}

    fileprivate func newEntries(_ newrow:CountableRange<Int>,newcolumn:CountableRange<Int>) -> [Fraction] {
        var v:[Fraction]=[]
        for i in newrow{
            for j in newcolumn{
                if i<row && j<column {
                    v.append(matrix[i][j])
                }else{
                    v.append(Fraction(i: 0))
                }
            }
        }
        return v
    }
    
    func matrixCopyWithDecimal(_ showDecimal:Bool)->Matrix{
        return Matrix(r: row, c: column, value: newEntries(0..<row, newcolumn: 0..<column), decimal: [[Bool]](repeating: [Bool](repeating: showDecimal, count: column), count: row))
    }

    func matrixCopy() -> Matrix{        
        return Matrix(r: row, c: column, value: newEntries(0..<row,newcolumn: 0..<column),decimal: decimal)
    }
    
    func removeTopRow() -> Matrix{
        return Matrix(r: row-1, c: column, value: newEntries(1..<row, newcolumn: 0..<column), decimal: decimal)
    }
    
    func removeFirstColumn() -> Matrix{
        return Matrix(r: row, c: column-1, value: newEntries(0..<row, newcolumn: 1..<column), decimal: decimal)
    }
    
    func removeBotRow() -> Matrix {
        return Matrix(r: row-1, c: column, value: newEntries(0..<(row-1),newcolumn: 0..<column),decimal: decimal)
    }

    func removeLastColumn() -> Matrix {
        return Matrix(r: row, c: column-1, value: newEntries(0..<row,newcolumn: 0..<(column-1)),decimal: decimal)
    }

    func addRow() -> Matrix {
        return Matrix(r: row+1, c: column, value: newEntries(0..<row+1,newcolumn: 0..<column),decimal: decimal)
    }

    func addColumn() -> Matrix {
        return Matrix(r: row, c: column+1, value: newEntries(0..<row,newcolumn: 0..<column+1),decimal: decimal)
    }
    
    func rowVector(_ i:Int)->Matrix{
        return Matrix(r: 1, c: column, value: matrix[i], decimal: [decimal[i]])
    }
    
    func columnVector(_ j:Int) -> Matrix{
        var value:[Fraction] = []
        var newdec:[[Bool]] = []
        for i in 0..<row{
            value.append(matrix[i][j])
            newdec.append([decimal[i][j]])
        }
        return Matrix(r: row, c: 1, value: value, decimal: newdec)
    }

    func lower() -> Matrix{
        var v:[Fraction] = []
        for i in 0..<row{
            for j in 0..<column{
                if i>j {
                    v.append(self.matrix[i][j])
                }else{
                    v.append(Fraction(i: 0))
                }
            }
        }
        return Matrix(r: row, c: column, value: v)
    }

    
    func mult(_ m:Matrix) throws -> Matrix {
		guard m.row == column else{
			throw MatrixErrors.dimensionMismatch((row,column),(m.row,m.column))
		}
        var value:[Fraction]=[]
        for i in 0..<row{
            for j in 0..<m.column{
                var v:Fraction = Fraction(i: 0)
                for k in 0..<column{
                    v = v+matrix[i][k]*m.matrix[k][j]
                }
                value.append(v)
            }
        }
        return Matrix(r: row, c: m.column, value: value)
    }
    
    func multScalar(_ s:Fraction) -> Matrix{
        var value:[Fraction]=[]
        for i in 0..<row{
            for j in 0..<column{
                value.append(self.matrix[i][j]*s)
            }
        }
        return Matrix(r: row, c: column, value: value, decimal: decimal)
    }
   
    func add(_ m:Matrix) throws -> Matrix{
        guard m.row == row && m.column == column else{
			throw MatrixErrors.dimensionMismatch((row,column),(m.row,m.column))
		}
        var value:[Fraction]=[]
        for i in 0..<row{
            for j in 0..<column{
                value.append(matrix[i][j]+m.matrix[i][j])
            }
        }
        return Matrix(r: row, c: column, value: value)
    }
    
    func subtract(_ m:Matrix) throws -> Matrix{
        guard m.row == row && m.column == column else{
			throw MatrixErrors.dimensionMismatch((row,column),(m.row,m.column))
		}
        var value:[Fraction]=[]
        for i in 0..<row{
            for j in 0..<column{
                value.append(matrix[i][j]-m.matrix[i][j])
            }
        }
        return Matrix(r: row, c: column, value: value)
    }
    
    
    func determinant() throws -> Fraction{
        guard row == column else{
			throw MatrixErrors.notSquareMatrix
		}
        return deter(self)
    }
    
    fileprivate func deter(_ m:Matrix) -> Fraction{
        if m.column == 1 {
            return m.matrix[0][0]
        }
            
        else if m.column == 2 {
            return ((m.matrix[0][0] * m.matrix[1][1]) - (m.matrix[0][1] * m.matrix[1][0]))
        }
            
        else{
            var d:Fraction = Fraction(i: 0)
            for i in 0..<m.column{
                var v:[Fraction] = []
                for j in 1..<m.row{
                    for k in 0..<m.column{
                        if k != i{
                            v.append(m.matrix[j][k])
                        }
                    }
                }
                let subm = Matrix(r: m.row-1, c: m.column-1, value: v)
                var subv = deter(subm)*m.matrix[0][i]
                if i%2 == 1 {
                    subv = subv * Fraction(i: -1)
                }
                d = d+subv
            }
            return d
        }
       
    }
 
    
    //divide row r by d, normally d equals to the first element of row r
    fileprivate func dividerow(_ r:Int,d:Fraction)-> Matrix{
        var v:[Fraction]=[]
        for i in 0..<row{
            for j in 0..<column{
                if i==r{
                    v.append(matrix[i][j]/d)
                }
                else{
                    v.append(matrix[i][j])
                }
            }
        }
        return Matrix(r: row, c: column, value: v)
    }
    
    //subtract row r1 by multiple m of row r2
    fileprivate func subtractrow(_ r1:Int, r2:Int, m:Fraction) -> Matrix{
        var v:[Fraction]=[]
        for i in 0..<row{
            for j in 0..<column{
                if i==r1{
                    v.append(matrix[i][j]-matrix[r2][j]*m)
                }
                else{
                    v.append(matrix[i][j])
                }
            }
        }
        return Matrix(r: row, c: column, value: v)
    }
    
    func transpose() -> Matrix {
        var v:[Fraction] = []
        for j in 0..<column{
            for i in 0..<row{
                v.append(matrix[i][j])
            }
        }
        return Matrix(r: column, c: row, value: v)
    }
    
    fileprivate func exchangerow(_ r1:Int, r2:Int) -> Matrix{
        var v: [Fraction] = []
        for i in 0..<row{
            for j in 0..<column{
                if (i == r1){
                    v.append(matrix[r2][j])
                } else if (i == r2){
                    v.append(matrix[r1][j])
                } else{
                    v.append(matrix[i][j])
                }
            }
        }
        return Matrix(r: row, c: column, value: v)
    }
    
    func REF() -> Matrix{
        return self.GJe(false).1
    }
    
    func RREF() -> Matrix{
        return self.GJe(true).1
    }
    
    //0 for swap rows, 1 for dividerow, 2 for subtract row
    func GJe(_ reduced:Bool,LU:Bool = false) -> ([(Int,Matrix)],Matrix){
        var copy = matrixCopy()
        var sequence:[(Int,Matrix)] = []
        let max = min(row,column)
        for i in 0..<max{
            if copy.matrix[i][i] == Fraction(i: 0) {
                var largest = copy.matrix[i][i]
                var largestIndex = i
                for j in (i+1)..<row{
                    if abs(copy.matrix[j][i])>largest{
                        largest = copy.matrix[j][i]
                        largestIndex = j
                    }
                    }
                if largestIndex != i {
                    copy = copy.exchangerow(i, r2: largestIndex)
                    sequence.append((0,Matrix.identity(row, column: row).exchangerow(i, r2: largestIndex)))
                }
            }
            if copy.matrix[i][i] != Fraction(i: 0){
                if !LU {
                    let d = copy.matrix[i][i]
                    copy = copy.dividerow(i, d: d)
                    sequence.append((1,Matrix.identity(row, column: row).dividerow(i, d: d)))
                }
                var range:CountableRange<Int>!
                if reduced {
                    range = 0..<row
                }else{
                    range = (i+1)..<row
                }
                for j in range{
                    if j != i {
                        let m = copy.matrix[j][i]/copy.matrix[i][i]
                        copy = copy.subtractrow(j, r2: i, m: m)
                        sequence.append((2,Matrix.identity(row, column: row).subtractrow(j, r2: i, m: m)))
                    }
                }
            }
        }
        return (sequence,copy)
    }
    
    func rank() -> Fraction{
        let r = GJe(false).1
        var rank: Int = 0
        for i in 0..<r.row{
            if !r.zeroRow(i) {
                rank += 1
            }
        }
        return Fraction(i: rank)
    }
    
    func zeroRow(_ r:Int) ->Bool{
        for j in 0..<column{
            if matrix[r][j].n != 0 {
                return false
            }
        }
        return true
    }
    
    func inverse() throws -> Matrix{
		do{
			let d = try determinant()
            guard d != Fraction(i:0) else{
			throw MatrixErrors.notInvertible
			}
		}catch MatrixErrors.notSquareMatrix{
			throw MatrixErrors.notSquareMatrix
		}
		
        let GJ = self.GJe(true)
        let sequence = GJ.0
        var res = Matrix.identity(row)
        for (_,m) in sequence{
            res = try! m*res
        }
        return res
    }

    func trace() throws -> Fraction{
		guard row == column else{
			throw MatrixErrors.notSquareMatrix
		} 
        var res = Fraction(i: 0)
        for i in 0..<matrix.count{
            res = res + matrix[i][i]
        }
        return res
    }
    
    func LU() -> (Matrix,Matrix,Matrix){
        let GJ = GJe(false, LU: true)
        let U = GJ.1
        var L = Matrix.identity(row, column: U.row)
        var P = Matrix.identity(row, column: row)
        let sequence = GJ.0
        for (type,m) in sequence{
            if type == 0 {
                P = try! m*P
                L = try! m*L.lower() + Matrix.identity(row, column: L.column)
            }else if type == 2{
                L = try! L + m.lower()
            }
        }
        for i in 0..<L.row{
            for j in 0..<i{
                L.matrix[i][j].n = -L.matrix[i][j].n
            }
        }
        return (P,L,U)
    }
    
//    func QR()->(Matrix,Matrix){
//        
//    }
//    
//    private func QRauxillary()->([Matrix]){
//        for j in 0..<column-1{
//            let u = self.columnVector(j)
//            let alpha = sqrt((u.transpose()*u).matrix[0][0])
//        }
//    }
    
    func toString() -> String{
        var s:String = "(  "
        for i in 0..<row{
            for j in 0..<column{
                s = s+matrix[i][j].toString(decimal[i][j])
                s = s+"  "
            }
            if i == row-1{
                s = s+")"
            }else{
                s = s+"\n"
            }
        }
        return s
    }
    
    
}
