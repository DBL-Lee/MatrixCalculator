//
//  Matrix.swift
//  MCalculator
//
//  Created by Ying on 15/7/1.
//  Copyright (c) 2015年 Ying. All rights reserved.
//

import UIKit

func *(m1:Matrix,m2:Matrix)->Matrix{
    return m1.mult(m2)
}

func +(m1:Matrix,m2:Matrix)->Matrix{
    return m1.add(m2)
}

func -(m1:Matrix,m2:Matrix)->Matrix{
    return m1.subtract(m2)
}

class Matrix: NSObject {
    let row:Int
    let column:Int
    var matrix:[[Fraction]] = []
    
    init(r:Int, c:Int, var value:[Fraction]){
        assert(value.count==r*c, "length does not match")
        row = r
        column = c
        for i in 0..<r{
            matrix.append([])
            for j in 0..<c {
                matrix[i].append(value.removeAtIndex(0))
            }
        }
    
    }
    
    
    func mult(m:Matrix) -> Matrix {
        assert(m.row == column, "can not multiply")
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
   
    func add(m:Matrix) -> Matrix{
        assert(m.row==row && m.column == column, "can not add")
        var value:[Fraction]=[]
        for i in 0..<row{
            for j in 0..<column{
                value.append(matrix[i][j]+m.matrix[i][j])
            }
        }
        return Matrix(r: row, c: column, value: value)
    }
    
    func subtract(m:Matrix) -> Matrix{
        assert(m.row==row && m.column == column, "can not subtract")
        var value:[Fraction]=[]
        for i in 0..<row{
            for j in 0..<column{
                value.append(matrix[i][j]-m.matrix[i][j])
            }
        }
        return Matrix(r: row, c: column, value: value)
    }
    
    
    func determinant() -> Fraction{
        assert(row==column, "not square matrix, determinant does not exist")
        return deter(self)
    }
    
    func deter(m:Matrix) -> Fraction{
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
                var subm = Matrix(r: m.row-1, c: m.column-1, value: v)
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
    func dividerow(r:Int,d:Fraction)-> Matrix{
        assert(r >= 0 && r < row && d != 0, "can not divide row")
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
    func subtractrow(r1:Int, r2:Int, m:Fraction) -> Matrix{
        assert(r1 >= 0 && r1 < row && r2 >= 0 && r2 < row, "matrix does not contain row")
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
    
    func exchangerow(r1:Int, r2:Int) -> Matrix{
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
    
    func ref() -> Matrix{
        var copy = matrixCopy()
        for i in 0..<row{
            var allzero = false
            if copy.matrix[i][i].n == 0 {
                var c = i+1
                while  c<copy.row && copy.matrix[c][i].n == 0 {
                    c++
                }
                if c != copy.row{
                    copy = copy.exchangerow(i, r2: c)
                } else{
                    allzero = true
                }
            }
            if !allzero {
                let d = copy.matrix[i][i]
                copy = copy.dividerow(i, d: d)
                //  println(copy.toString())
                for j in i+1..<row{
                    let m = copy.matrix[j][i]
                    copy = copy.subtractrow(j, r2: i, m: m)
                    //      println(copy.toString())
                }
            }
        }
        return copy
    }
    
    func rank() -> Int{
        let r = ref()
        var rank: Int = 0
        for i in 0..<r.row{
            if !r.zeroRow(i) {
                rank++
            }
        }
        return rank
    }
    
    func zeroRow(r:Int) ->Bool{
        assert(r>=0 && r<row, "row not in range")
        var flag = true
        for j in 0..<column{
            flag = flag && matrix[r][j].n != 0
        }
        return flag
    }
    
    func GJe() -> Matrix{
        assert(determinant().n != 0, "matrix does not have inverse")
        var inverse = Matrix.identity(row)
        var copy = matrixCopy()
        for i in 0..<row{
            if copy.matrix[i][i].n == 0 {
                var c = i+1
                while copy.matrix[c][i] == 0{
                    c++
                }
                copy = copy.exchangerow(i, r2: c)
                inverse = inverse.exchangerow(i, r2: c)
            }
            let d = copy.matrix[i][i]
            copy = copy.dividerow(i, d: d)
          //  println(copy.toString())
            inverse = inverse.dividerow(i, d: d)
            for j in i+1..<row{
                let m = copy.matrix[j][i]
                copy = copy.subtractrow(j, r2: i, m: m)
          //      println(copy.toString())
                inverse = inverse.subtractrow(j, r2: i, m: m)
            }
        }
        for var i = row-1; i >= 0; --i {
            for var j = i-1; j >= 0; --j {
                let m = copy.matrix[j][i]
                copy = copy.subtractrow(j, r2: i, m: m)
           //     println(copy.toString())
                inverse = inverse.subtractrow(j, r2: i, m: m)
            }
        }
        
        return inverse
    }
    
    
    class func identity(n:Int) -> Matrix{
        var v:[Fraction]=[]
        for i in 0..<n{
            for j in 0..<n{
                if (i == j){
                    v.append(Fraction(i: 1))
                }
                else{
                    v.append(Fraction(i: 0))
                }
            }
        }
        return Matrix(r: n, c: n, value: v)
    }

    func matrixCopy() -> Matrix{
        var v:[Fraction]=[]
        for i in 0..<row{
            for j in 0..<column{
                v.append(matrix[i][j])
            }
        }
        return Matrix(r: row, c: column, value: v)
    }
    
    func toString() -> String{
        var s:String = "(  "
        for i in 0..<row{
            for j in 0..<column{
                s = s+matrix[i][j].toString()
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
