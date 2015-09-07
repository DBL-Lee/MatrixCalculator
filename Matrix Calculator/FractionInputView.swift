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
    @IBOutlet weak var containerView :UIView!
	//MARK: inputvalue
    var numerator:String = "0"
    var denominator:String = ""
    var floatingPoint:Int = 0
    var numeratorFloatingPoint = 0 //remember floating point of numerator
	var integerPart:Int = 1
	var numeratorIntegerPart = 1
    let FLOATPOINTUPPER = 5
	let INTEGERPARTUPPER = 5

    //flags
    var negative = false
    var floatpointEntered:Bool = false
    var numberlineEntered:Bool = false
	var delegate:inputFractionDelegate!

    @IBOutlet var redButtons : [UIButton]!
    @IBOutlet var grayButtons : [UIButton]!
    @IBOutlet var orangeButtons : [UIButton]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let darkGray = UIColor(white: 0.8, alpha: 1.0)
        for button in grayButtons{
            button.setBackgroundImage(UIImage.imageWithColor(darkGray), forState: UIControlState.Normal)
            button.setBackgroundImage(UIImage.imageWithColor(darkGray.darker()), forState: UIControlState.Highlighted)
            button.layer.borderColor = UIColor.blackColor().CGColor
            button.layer.borderWidth = 1
        }
        for button in orangeButtons{
            button.setBackgroundImage(UIImage.imageWithColor(UIColor.orangeColor()), forState: UIControlState.Normal)
            button.setBackgroundImage(UIImage.imageWithColor(UIColor.orangeColor().darker()), forState: UIControlState.Highlighted)
            button.layer.borderColor = UIColor.blackColor().CGColor
            button.layer.borderWidth = 1
        }
        for button in redButtons{
            button.setBackgroundImage(UIImage.imageWithColor(UIColor.redColor()), forState: UIControlState.Normal)
            button.setBackgroundImage(UIImage.imageWithColor(UIColor.redColor().darker()), forState: UIControlState.Highlighted)
            button.layer.borderColor = UIColor.blackColor().CGColor
            button.layer.borderWidth = 1
        }
        self.containerView.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
        for view in self.subviews{
            if view is UIButton{
                (view as! UIButton).titleLabel?.adjustsFontSizeToFitWidth = true
            }
        }
    }

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
				integerPart = numeratorIntegerPart
            }else{
                if !numberlineEntered {
                    if numerator.characters.count==1 { //Deleting last digit in numerator
                        numerator = "0"
                    }else{ 
                        if numerator.removeAtIndex(numerator.endIndex.predecessor())=="."{ //Deleting floating point in numerator
                            floatpointEntered = false
                        }else{  //Deleting a digit in numerator
                            if floatpointEntered{
                                floatingPoint--
                            }else{
								integerPart--
							}
                        }
                    }
                }else{
                    if denominator.removeAtIndex(denominator.endIndex.predecessor())=="."{ //Deleting floatingPoint in denominator
                        floatpointEntered = false
                    }else{  //Deleting a digit in denominator
                        if floatpointEntered{
                            floatingPoint--
                        }else{
							integerPart--
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
						integerPart++
                    }
                    denominator+="."
                }
                floatpointEntered = true
            }
        case "/":
            if !numberlineEntered{
                if numerator[numerator.endIndex.predecessor()] != "."{ //Previous character is not floating point
                    numeratorFloatingPoint = floatingPoint
					numeratorIntegerPart = integerPart
                }else{
                    numerator.removeAtIndex(numerator.endIndex.predecessor())
                }
                floatingPoint = 0
				integerPart = 0
                numberlineEntered = true
                floatpointEntered = false
            }
        case "+/-":
            negative = !negative
        default:
            if (floatpointEntered && floatingPoint<FLOATPOINTUPPER) || (!floatpointEntered && integerPart<INTEGERPARTUPPER) {
                if !self.numberlineEntered{
                    if self.numerator == "0" { //no digit entered yet
                        self.numerator = sender.titleLabel!.text!
                    }else{
                        if self.floatpointEntered {
							self.floatingPoint++
						}else{
							integerPart++
						}
                        self.numerator += sender.titleLabel!.text!
                    }
                }else{
                    if self.floatpointEntered {
						self.floatingPoint++
					}else{
						integerPart++
					}
                    self.denominator += sender.titleLabel!.text!
                }
            }
        }
        let entry = (negative ? "-" : "") + numerator + (numberlineEntered ? ("/"+denominator) : "")
		self.label.text = entry
    }


    @IBAction func finishInput(sender:UIButton){
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

		self.delegate.didFinishInputFraction(n/d,decimal: floatpointEntered)
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
