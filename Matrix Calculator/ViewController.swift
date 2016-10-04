//
//  ViewController.swift
//  Matrix Calculator
//
//  Created by Zichuan Huang on 12/02/2015.
//  Copyright (c) 2015 Zichuan Huang. All rights reserved.
//
import MobileCoreServices
import UIKit
import GoogleMobileAds

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol inputMatrixDelegate{
    func didFinishInputMatrix(_ matrix:Matrix,alias:String)
}


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate{
    
    @IBOutlet weak var bannerView: GADBannerView!

    @IBOutlet weak var containerView: UIView!
    
    var delegate:inputMatrixDelegate!
    
    @IBOutlet weak var CameraButton: UIButton!
    
    @IBOutlet weak var matrixView: matrixTableView!
    
    var newMedia:Bool?
    var image:UIImage!
    var imagePicker:UIImagePickerController!
	
	var tutorialView:TutorialOverlayView!
	var detectTouch = false
    

    @IBOutlet var grayButtons: [UIButton]!
    
    @IBOutlet var orangeButtons: [UIButton]!

    @IBOutlet var redButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(white: 0.25, alpha: 1)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.respondToSwipeGesture(_:)))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeDown)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.respondToSwipeGesture(_:)))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(swipeUp)
        
        
		matrixView.setMatrix(matrix,underline:currentCursor)
        matrixView.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
        matrixView.heightLimit = containerView.frame.height
        matrixView.widthLimit = containerView.frame.width
        
        
        let darkGray = UIColor(white: 0.8, alpha: 1.0)
        for button in grayButtons{
            button.setBackgroundImage(UIImage.imageWithColor(darkGray), for: UIControlState())
            button.setBackgroundImage(UIImage.imageWithColor(darkGray.darker()), for: UIControlState.highlighted)
            button.layer.borderColor = UIColor.black.cgColor
            button.layer.borderWidth = 1
        }
        for button in orangeButtons{
            button.setBackgroundImage(UIImage.imageWithColor(UIColor.orange), for: UIControlState())
            button.setBackgroundImage(UIImage.imageWithColor(UIColor.orange.darker()), for: UIControlState.highlighted)
            button.layer.borderColor = UIColor.black.cgColor
            button.layer.borderWidth = 1
        }
        for button in redButtons{
            button.setBackgroundImage(UIImage.imageWithColor(UIColor.red), for: UIControlState())
            button.setBackgroundImage(UIImage.imageWithColor(UIColor.red.darker()), for: UIControlState.highlighted)
            button.layer.borderColor = UIColor.black.cgColor
            button.layer.borderWidth = 1
        }
        for view in self.view.subviews{
            if view is UIButton{
                (view as! UIButton).titleLabel?.adjustsFontSizeToFitWidth = true
            }
        }
		
		if !UserDefaults.standard.bool(forKey: "SeenTutSwipe"){
            showTutorialView(NSLocalizedString("FirstTimeSwipe", comment: ""))            
            UserDefaults.standard.set(true, forKey: "SeenTutSwipe")
        }
        
        bannerView.adUnitID = "ca-app-pub-4444803405334579/4793171041"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
	
 	fileprivate func showTutorialView(_ text:String){
		self.tutorialView = TutorialOverlayView(frame: self.view.frame, text: text)
        tutorialView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tutorialView)
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tutorialView]-0-|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: ["tutorialView": self.tutorialView]))
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tutorialView]-0-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: ["tutorialView": self.tutorialView]))
        tutorialView.alpha = 0.0
		UIView.animate(withDuration: 0.5, animations: {
            () in
            self.tutorialView.alpha = 1.0
        })
		self.detectTouch = true
	}   
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: printing matrix
    let MAXROW = 10
    let MAXCOLUMN = 10

    var matrix:Matrix = Matrix(r: 2, c: 2)
    var currentCursor = (0,0)
    var fraction = true
    
    var entering = false //flag to indicate whether user is entering

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

    //user started entering
    @IBAction func digitPressed(_ sender: UIButton) {
        switch sender.titleLabel!.text! {
        case "DEL","退格":
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
                        if numerator.remove(at: numerator.characters.index(before: numerator.endIndex))=="."{ //Deleting floating point in numerator
                            floatpointEntered = false
                        }else{  //Deleting a digit in numerator
                            if floatpointEntered{
                                floatingPoint -= 1
                            }else{
								integerPart -= 1
							}
                        }
                    }
                }else{
                    if denominator.remove(at: denominator.characters.index(before: denominator.endIndex))=="."{ //Deleting floatingPoint in denominator
                        floatpointEntered = false
                    }else{  //Deleting a digit in denominator
                        if floatpointEntered{
                            floatingPoint -= 1
                        }else{
							integerPart -= 1
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
						integerPart += 1
                    }
                    denominator+="."
                }
                floatpointEntered = true
            }
        case "/":
            if !numberlineEntered{
                if numerator[numerator.characters.index(before: numerator.endIndex)] != "."{ //Previous character is not floating point
                    numeratorFloatingPoint = floatingPoint
					numeratorIntegerPart = integerPart
                }else{
                    numerator.remove(at: numerator.characters.index(before: numerator.endIndex))
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
							self.floatingPoint += 1
						}else{
							integerPart += 1
						}
                        self.numerator += sender.titleLabel!.text!
                    }
                }else{
                    if self.floatpointEntered {
						self.floatingPoint += 1
					}else{
						integerPart += 1
					}
                    self.denominator += sender.titleLabel!.text!
                }
            }
        }
        entering = true
        let entry = (negative ? "-" : "") + numerator + (numberlineEntered ? ("/"+denominator) : "")
		matrixView.setLabel(currentCursor.0,j: currentCursor.1,s: entry)
    }

    //This function is called when user finish editing a cell and move to another cell
    fileprivate func calculateCurrentCell(){
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

        matrix.matrix[currentCursor.0][currentCursor.1] = n/d
		matrix.decimal[currentCursor.0][currentCursor.1] = floatpointEntered

        matrixView.setMatrix(matrix,underline:currentCursor)

        //reset to default
        numerator = "0"
        denominator = ""
        floatingPoint = 0
        numeratorFloatingPoint = 0
		integerPart = 1
		numeratorIntegerPart = 1
        negative = false
        floatpointEntered = false
        numberlineEntered = false
    }

    //User moving through cells
     func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            if entering { // calculate the current value and insert to matrix
                calculateCurrentCell()
            }
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.left:
                if currentCursor.1-1>=0 {
                    currentCursor.1 -= 1
                    matrixView.shiftUnderline(2)
                }
            case UISwipeGestureRecognizerDirection.right:
                if (currentCursor.1+1) < matrix.column {
                    currentCursor.1 += 1
                    matrixView.shiftUnderline(3)
                }
            case UISwipeGestureRecognizerDirection.up:
                if currentCursor.0-1>=0 {
                    currentCursor.0 -= 1
                    matrixView.shiftUnderline(0)
                }
            case UISwipeGestureRecognizerDirection.down:
                if currentCursor.0+1 < matrix.row {
                    currentCursor.0 += 1
                    matrixView.shiftUnderline(1)
                }
            default:
                break
            }
        }
    }

    //User is changing size of matrix
    @IBAction func sizeChange(_ sender: UIButton) {
        if entering { // calculate the current value and insert to matrix
            calculateCurrentCell()
        }
        switch sender.tag {
            case 0 : //addrow
                if matrix.row+1<=MAXROW {
                    matrix = matrix.addRow()
                    matrixView.setMatrix(matrix,underline:currentCursor)
                }
            case 1 : //removerow
                if matrix.row-1>0 {
                    matrix = matrix.removeBotRow()
                    if currentCursor.0 >= matrix.row {
                         currentCursor.0 -= 1
                    }
                    matrixView.setMatrix(matrix,underline:currentCursor)
                }
            case 2 : //addcolumn
                if matrix.column+1<=MAXCOLUMN {
                    matrix = matrix.addColumn()
                    matrixView.setMatrix(matrix,underline:currentCursor)
                }
            case 3 : //removecolumn
                if matrix.column-1>0 {
                    matrix = matrix.removeLastColumn()
                    if currentCursor.1 >= matrix.column {
                         currentCursor.1 -= 1
                    }
                    matrixView.setMatrix(matrix,underline:currentCursor)
                }
            default: ()
        }
    }  
    



    // MARK: Camera   
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func useCamera(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.camera) {
                
                imagePicker = UIImagePickerController()
                
                imagePicker.delegate = self
                imagePicker.sourceType =
                    UIImagePickerControllerSourceType.camera
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
                
                newMedia = true
        }
		self.entering = false
        self.present(self.imagePicker, animated: true,
            completion: nil)
    }
    
    var usedCharacter:NSSet!

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let regex:NSRegularExpression = try! NSRegularExpression(pattern: "[a-zA-Z]", options: NSRegularExpression.Options.caseInsensitive)
        if (range.length + range.location > textField.text?.characters.count || (string=="") || (regex.matches(in: string, options: [], range: NSMakeRange(0, string.characters.count)).count == 0))
        {
            return false
        }
        textField.text = string.uppercased()
        let newLength = textField.text!.characters.count + string.characters.count - range.length
        return newLength <= 1
    }

    
    //MARK: DONE
    @IBAction func done(_ sender: UIButton) {
		if entering {
			calculateCurrentCell()
		}
        var inputTextField: UITextField?
        var message = NSLocalizedString("usedCharacter", comment: "")
        if usedCharacter.count == 0{
            message += NSLocalizedString("none", comment: "")
        }else{
            for c in "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters{
                if self.usedCharacter.contains(String(c)){
                    message += String(c) + ","
                }
            }
            message.remove(at: message.characters.index(before: message.endIndex))
        }
        message += NSLocalizedString("alertMsg", comment: "")
        let alert = UIAlertController(title: NSLocalizedString("saveTitle", comment: ""), message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            for c in "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters{
                if !self.usedCharacter.contains(String(c)){
                    textField.text = String(c)
                    break
                }else{
                    textField.text = "A"
                }
            }
            inputTextField = textField
            inputTextField?.delegate = self
        })

        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: {
            action in
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("save", comment: ""), style: UIAlertActionStyle.default, handler: ({
            action in
            self.delegate.didFinishInputMatrix(self.matrix,alias: inputTextField!.text!)
            self.dismiss(animated: true,completion:nil)
        })))
        

        self.present(alert, animated: true, completion: nil)

        
    }    
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if detectTouch {
            UIView.animate(withDuration: 0.5, animations: {
				() in
				self.tutorialView.alpha = 0.0
				}, completion: {
					bool in
					self.tutorialView.removeFromSuperview()
			})
            self.detectTouch = false
        }
    }
}

