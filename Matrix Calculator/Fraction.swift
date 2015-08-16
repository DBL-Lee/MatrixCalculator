//
//  Fraction.swift
//  Calculator
//
//  Created by Ying on 15/6/30.
//
//

import UIKit

func +(left: Fraction, right: Fraction) -> Fraction{
    return left.add(right)
}

func *(left: Fraction, right: Fraction) -> Fraction{
    return left.mult(right)
}

func /(left: Fraction, right: Fraction) -> Fraction{
    return left.div(right)
}

func -(left:Fraction, right:Fraction) -> Fraction{
    return left.subtract(right)
}


class Fraction{
    var n:Int
    var d:Int
    
    // polarity indicated in numerator
    init(n:Int,d:Int){
        assert(d != 0, "denominator can not be zero")
        let (rn, rd) = Fraction.reduce(n , d: d)
        self.n = rn
        self.d = rd
    }
    
    init(i:Int){
        self.n = i
        self.d = 1
    }
    
    init(i:Double){
        var newn:Int = Int(round(i*100000))
        var newd:Int = 100000
        let (rn, rd) = Fraction.reduce(newn , d: newd)
        self.n = rn
        self.d = rd
    }

    
    func isInt() -> Bool{
        return d==1
    }
    
    func convert() -> Double{
        return Double(n)/Double(d)
    }
    
    func add(f:Fraction) ->Fraction{
        let newn:Int = self.n * f.d + f.n * self.d
        let newd:Int = self.d * f.d
        var newf = Fraction(n: newn, d: newd)
        return newf
    }
    
    func subtract(f:Fraction) ->Fraction{
        var newf = Fraction(n: f.n * (-1), d: f.d)
        return add(newf)
    }
    
    func mult(f:Fraction) ->Fraction{
        let newn:Int = self.n * f.n
        let newd:Int = self.d * f.d
        var newf = Fraction(n: newn, d: newd)
        return newf
    }
    
    func div(f:Fraction) -> Fraction{
        assert(f.n != 0, "can not divide by 0")
        var newf = Fraction(n: f.d, d: f.n)
        return mult(newf)
    }
    
    func toString() -> String{
        if (d==1){
            return "\(n)"
        } else{
            return "\(n)/\(d)"
        }
    }
    
    
    class func reduce(var n:Int, var d:Int) -> (Int,Int){
        let gcd: Int = Fraction.gcd(n, b: d)
        var newn:Int
        var newd:Int
        if (n<0 && d<0){
            newn = n/gcd*(-1)
            newd = d/gcd*(-1)
        } else if(n<0 || d<0){
            newn = abs(n/gcd)*(-1)
            newd = abs(d/gcd)
        } else{
            newn = n/gcd
            newd = d/gcd
        }
        return (newn, newd)
    }
    
    
    class func gcd(var a: Int, var b: Int) -> Int {
        a = abs(a); b = abs(b)
        if (b > a) { swap(&a, &b) }
        while (b > 0) { (a, b) = (b, a % b) }
        return a
    }

}
