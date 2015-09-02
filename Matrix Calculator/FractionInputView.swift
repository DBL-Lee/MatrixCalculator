//
//  FractionInputView.swift
//  Matrix Calculator
//
//  Created by Zichuan Huang on 16/08/2015.
//  Copyright (c) 2015 Zichuan Huang. All rights reserved.
//

import UIKit

protocol inputFractionDelegate{
	func didFinishInputFraction(fraction:Fraction,decimal:Bool)
}

class FractionInputView: UIView {
	
	@IBOutlet weak var label : UILabel! 
	//MARK: inputvalue
    var numerator:String = "0"
    var denominator:String = ""
    var floatingPoint:Int = 0
    var numeratorFloatingPoint = 0 //remember floating point of numerator
    let FLOATPOINTUPPER = 5

    //flags
    var negative = false
    var floatpointEntered:Bool = false
    var numberlineEntered:Bool = false
	var delegate:inputFractionDelegate!

    //user started entering
    @IBAction func digitPressed(sender: UIButton) {
        switch sender.titleLabel!.text! {
        case "DEL":
            if numberlineEntered && denominator=="" { //Deleting numberline
                numberlineEntered = false
                if numeratorFloatingPoint > 0 { //Numerator is float
                    floatpointEntered = true
                }
                floatingPoint = numeratorFloatingPoint
            }else{
                if !numberlineEntered {
                    if count(numerator)==1 { //Deleting last digit in numerator
                        numerator = "0"
                    }else{ 
                        if numerator.removeAtIndex(numerator.endIndex.predecessor())=="."{ //Deleting floating point in numerator
                            floatpointEntered = false
                        }else{  //Deleting a digit in numerator
                            if floatpointEntered{
                                floatingPoint--
                            }
                        }
                    }
                }else{
                    if denominator.removeAtIndex(denominator.endIndex.predecessor())=="."{ //Deleting floatingPoint in denominator
                        floatpointEntered = false
                    }else{  //Deleting a digit in denominator
                        if floatpointEntered{
                            floatingPoint--
                        }
                    }
                }
            }
        case ".":
            if !floatpointEntered{
                if !numberlineEntered{
                    numerator+="."
                }else{
                    if denominator==""{ //Case whereby denominator is empty
                        denominator = "0"
                    }
                    denominator+="."
                }
                floatpointEntered = true
            }
        case "/":
            if !numberlineEntered{
                if numerator[numerator.endIndex.predecessor()] != "."{ //Previous character is not floating point
                    numeratorFloatingPoint = floatingPoint
                }else{
                    numerator.removeAtIndex(numerator.endIndex.predecessor())
                }
                floatingPoint = 0
                numberlineEntered = true
                floatpointEntered = false
            }
        case "+/-":
            negative = !negative
        default:
            if floatingPoint<FLOATPOINTUPPER {
                if !numberlineEntered{
                    if numerator == "0" { //no digit entered yet
                        numerator = sender.titleLabel!.text!
                    }else{
                        if floatpointEntered {floatingPoint++}
                        numerator += sender.titleLabel!.text!
                    }
                }else{
                    if floatpointEntered {floatingPoint++}
                    denominator += sender.titleLabel!.text!
                }
            }
        }
        entering = true
        let entry = (negative ? "-" : "") + numerator + (numberlineEntered ? ("/"+denominator) : "")
		self.label.text = entry
    }

    //This function is called when user finish editing a cell and move to another cell
    private func finishInput(){
        entering = false
        if negative {
            numerator = "-"+numerator
        }
        let n = Fraction(i:(numerator as NSString).doubleValue)
        var d:Fraction!
        if numberlineEntered && denominator != "" {
            d = Fraction(i: NSString(string:denominator).doubleValue)
        }else {
            d = Fraction(i: 1)
        }

        //When user inputs 0 at denominator
        if d.n == 0 { d = Fraction(i: 1)}

		self.delegate.didFinishInputFraction(n/d,!numberlineEntered)
        numerator = "0"
        denominator = ""
        floatingPoint = 0
        numeratorFloatingPoint = 0
        negative = false
        floatpointEntered = false
        numberlineEntered = false
		self.label.text = "0"
    }
	

}
