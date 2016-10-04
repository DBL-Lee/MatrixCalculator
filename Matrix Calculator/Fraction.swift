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

func < (lhs:Fraction,rhs:Fraction) -> Bool {
    return Double(lhs.n)/Double(lhs.d) < Double(rhs.n)/Double(lhs.d)
}

func == (lhs:Fraction,rhs:Fraction) -> Bool {
    return Double(lhs.n)==Double(rhs.n) && Double(lhs.d)==Double(rhs.d)
}

func abs(_ f:Fraction) -> Fraction {
    return Fraction(n: abs(f.n), d: f.d)
}

class Fraction:Comparable{
    var n:Int64
    var d:Int64
    
    // polarity indicated in numerator
    init(n:Int64,d:Int64){
        let (rn, rd) = Fraction.reduce(n , d: d)
        self.n = rn
        self.d = rd
    }
    
    init(i:Int64){
        self.n = i
        self.d = 1
    }
    
    init(n:Int,d:Int){
        let (rn, rd) = Fraction.reduce(Int64(n) , d: Int64(d))
        self.n = rn
        self.d = rd
    }
    
    init(i:Int){
        self.n = Int64(i)
        self.d = 1
    }
    
    init(i:Double){
        let newn:Int64 = Int64(round(i*100000))
        let newd:Int64 = 100000
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
    
    func add(_ f:Fraction) ->Fraction{
        let newn:Int64 = self.n &* f.d &+ f.n &* self.d
        let newd:Int64 = self.d &* f.d
        let newf = Fraction(n: newn, d: newd)
        return newf
    }
    
    func subtract(_ f:Fraction) ->Fraction{
        let newf = Fraction(n: f.n * (-1), d: f.d)
        return add(newf)
    }
    
    func mult(_ f:Fraction) ->Fraction{
        let newn:Int64 = self.n &* f.n
        let newd:Int64 = self.d &* f.d
        let newf = Fraction(n: newn, d: newd)
        return newf
    }
    
    func div(_ f:Fraction) -> Fraction{
        assert(f.n != 0, "can not divide by 0")
        let newf = Fraction(n: f.d, d: f.n)
        return mult(newf)
    }
    
    func toString() -> String{
        if (d==1){
            return "\(n)"
        } else{
            return "\(n)/\(d)"
        }
    }
	
	fileprivate func isFiniteDecimal() -> Bool {
		var denominator = d
		while (denominator%2==0){
			denominator = denominator/2
		}
		while (denominator%5==0){
			denominator = denominator/5
		}
		return denominator==1
	}
	
	func toString(_ decimal:Bool) -> String{
		if !decimal || !isFiniteDecimal(){
			return toString()
		}else{
            if d==1{
                return n.description
            }else{
                return (Double(n)/Double(d)).description
            }
		}
	}
    

    
    
    class func reduce(_ n:Int64, d:Int64) -> (Int64,Int64){
        let gcd: Int64 = Fraction.gcd(n, b: d)
        var newn:Int64
        var newd:Int64
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
    
    
    class func gcd(_ a: Int64, b: Int64) -> Int64 {
        var a = a, b = b
        a = abs(a); b = abs(b)
        if (b > a) { swap(&a, &b) }
        while (b > 0) { (a, b) = (b, a % b) }
        return a
    }

}
