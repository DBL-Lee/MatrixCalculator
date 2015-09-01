//
//  CalculatorMainScreenViewController.swift
//  Matrix Calculator
//
//  Created by Zichuan Huang on 19/07/2015.
//  Copyright (c) 2015 Zichuan Huang. All rights reserved.
//

import UIKit

enum MatrixOperations{
	case add
	case subtract
	case multiplication
    case REF
	case RREF
	case transpose
	case inverse
	case chol
	case QR
	case LU
	case diagonalize
	case eigenpair
	case rank
	case trace
	case det
}

extension UIColor {
    
    func lighter(amount : CGFloat = 0.25) -> UIColor {
        return hueColorWithBrightnessAmount(1 + amount)
    }
    
    func darker(amount : CGFloat = 0.25) -> UIColor {
        return hueColorWithBrightnessAmount(1 - amount)
    }
    
    private func hueColorWithBrightnessAmount(amount: CGFloat) -> UIColor {
        var hue         : CGFloat = 0
        var saturation  : CGFloat = 0
        var brightness  : CGFloat = 0
        var alpha       : CGFloat = 0
            
            if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
                return UIColor( hue: hue,
                    saturation: saturation,
                    brightness: brightness * amount,
                    alpha: alpha )
            } else {
                return self
            }
        
    }
    
}

extension UIImage {
    class func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

class CalculatorMainScreenViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,storeMatrixViewDelegate,UITextFieldDelegate {
    @IBOutlet weak var tableView: UITableView!    
    
    @IBOutlet var orangeButtons: [UIButton]!
    @IBOutlet var lightGrayButtons: [UIButton]!
    let CellIdentifier = "MatrixCalculationCell"
    var expressions:[Any] = []
    var results:[Any] = []
	var firstOperand:Matrix?
	var secondOperand:Matrix?
	var operation:MatrixOperations?
	var storedMatricesView:storedMatrixView!
    var carryForwardAnswer:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView(frame: CGRect.zeroRect)
        tableView.registerNib(UINib(nibName: "MatrixCell", bundle: nil), forCellReuseIdentifier: CellIdentifier)
        tableView.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
        tableView.backgroundView?.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
		
		storedMatricesView = storedMatrixView(frame: self.view.frame)
        storedMatricesView.delegate = self
		self.view.addSubview(storedMatricesView)
		storedMatricesView.hidden = true
        
        let lightGray = UIColor(white: 0.9, alpha: 1.0)
        let darkGray = UIColor(white: 0.8, alpha: 1.0)
        let darkestGray = UIColor(white: 0.7, alpha: 1.0)
        for button in lightGrayButtons{
            button.setBackgroundImage(UIImage.imageWithColor(darkGray), forState: UIControlState.Normal)
            button.setBackgroundImage(UIImage.imageWithColor(darkGray.darker()), forState: UIControlState.Highlighted)
            button.layer.borderColor = UIColor.blackColor().CGColor
            button.layer.borderWidth = 1
        }
        for button in orangeButtons{
            button.setBackgroundImage(UIImage.imageWithColor(UIColor.orangeColor()), forState: UIControlState.Normal)
            button.setBackgroundImage(UIImage.imageWithColor(UIColor.orangeColor().darker()), forState: UIControlState.Highlighted)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showStoredMatrices(sender: AnyObject) {
		storedMatricesView.hidden = false
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as! MatrixCalculationCell
        switch expressions[indexPath.row]{
        case let string as String:
            cell.label.text = string
        case let attString as NSMutableAttributedString:
            cell.label.attributedText = attString
        default: ()
        }
		cell.label.sizeToFit()
        cell.resultMatrixView.widthLimit = cell.frame.width - cell.label.frame.width
        cell.resultMatrixView.hidden = true
        cell.resultLabel.hidden = true
        if indexPath.row < results.count{
            switch results[indexPath.row] {
            case let matrix as Matrix:
                cell.resultMatrixView.setMatrix(matrix)
                cell.resultMatrixView.hidden = false
            case let scalar as Fraction:
                cell.resultLabel.text = scalar.toString()
                cell.resultLabel.hidden = false
                cell.resultLabel.sizeToFit()
            case let error as String:
                break
            default:
            break
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expressions.count
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var error:NSError?
        var regex:NSRegularExpression = NSRegularExpression(pattern: "[a-zA-Z]", options: .CaseInsensitive, error: &error)!
        if ((range.length + range.location > count(textField.text)) || (string=="") || (regex.matchesInString(string, options: nil, range: NSMakeRange(0, count(string))).count == 0))
        {
            return false;
        }
        textField.text = string.uppercaseString
        let newLength = count(textField.text) + count(string) - range.length
        return newLength <= 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < self.results.count {
            if self.results[indexPath.row] is Matrix {
                let usedCharacter = NSSet(array: storedMatricesView.storedMatrices.keys.array)
                var inputTextField: UITextField?
                var message = "Used Characters: "
                if usedCharacter.count == 0{
                    message += "None"
                }else{
                    for c in "ABCDEFGHIJKLMNOPQRSTUVWXYZ"{
                        if usedCharacter.containsObject(String(c)){
                            message += String(c) + ","
                        }
                    }
                    message.removeAtIndex(message.endIndex.predecessor())
                }
                message += "\nUsing same character will overwrite existing matrix."
                var alert = UIAlertController(title: "Save Matrix As", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
                    for c in "ABCDEFGHIJKLMNOPQRSTUVWXYZ"{
                        if !usedCharacter.containsObject(String(c)){
                            textField.text = String(c)
                            break
                        }else{
                            textField.text = "A"
                        }
                    }
                    inputTextField = textField
                    inputTextField?.delegate = self
                })
                
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
                    action in
                }))
                
                alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: ({
                    action in
                    self.storedMatricesView.didFinishInputMatrix((self.results[indexPath.row] as! Matrix),alias: inputTextField!.text!)
                    self.dismissViewControllerAnimated(true,completion:nil)
                })))
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }
        }
    }
    
    private func appendToLastExpression(str:String){
        expressions[expressions.count-1] = (expressions.last! as! String)+str
        
    }
    
    private func surroundLastExpression(str:String){
        expressions[expressions.count-1] = str+"("+(expressions.last! as! String)+") ="
    }
    
    private func appendSuperscript(str:String){
        let string = expressions[expressions.count-1] as! String
        let att = NSMutableAttributedString(string: string)
        let fontsize:CGFloat = 17
        att.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(fontsize), range: NSRange(location: 0, length: count(string)))
        let addition = NSMutableAttributedString(string: str)
        addition.addAttributes([NSFontAttributeName : UIFont.systemFontOfSize(fontsize/2), NSBaselineOffsetAttributeName : fontsize/2], range: NSRange(location: 0, length: count(str)))
        att.appendAttributedString(addition)
        expressions[expressions.count-1] = att
    }
	
    @IBAction func twoMatrixOperation(sender: AnyObject) {
        if firstOperand != nil{
            if carryForwardAnswer {
                self.expressions.append("Ans")
            }
            let button:UIButton = sender as! UIButton
            switch button.tag{
            case 0:
                self.operation = .add
                appendToLastExpression(" + ")
            case 1:
                self.operation = .subtract
                appendToLastExpression(" - ")
            case 2:
                self.operation = .multiplication
                appendToLastExpression(" × ")
            default: ()
            }
            tableView.reloadData()
            self.storedMatricesView.hidden = false
        }
    }
    
    @IBAction func oneMatrixToMultipleMatrix(sender: AnyObject) {
        if firstOperand != nil {
            if carryForwardAnswer {
                self.expressions.append("Ans")
            }
            let button:UIButton = sender as! UIButton
            switch button.tag{
            case 0:
                self.operation = .LU
            case 1:()
            case 2:()
            default:()
            }
            doCalculation()
            tableView.reloadData()
        }
    }
    
    @IBAction func oneMatrixToOneMatrix(sender: AnyObject) {
        if firstOperand != nil {
            if carryForwardAnswer {
                self.expressions.append("Ans")
            }
            let button:UIButton = sender as! UIButton
            switch button.tag{
            case 0:
                self.operation = .RREF
                surroundLastExpression("rref")
            case 1:
                self.operation = .transpose
                appendSuperscript("T")
            case 2:
                self.operation = .inverse
                appendSuperscript("-1")
            case 3:
                self.operation = .REF
                surroundLastExpression("ref")
            default:()
            }
            doCalculation()
            tableView.reloadData()
        }
    }
    
    @IBAction func oneMatrixToScalar(sender: AnyObject) {
        if firstOperand != nil{
            if carryForwardAnswer {
                self.expressions.append("Ans")
            }
            let button:UIButton = sender as! UIButton
            switch button.tag{
            case 0:
                self.operation = .rank
                surroundLastExpression("rank")
            case 1:
                self.operation = .det
                surroundLastExpression("det")
            case 2:
                self.operation = .trace
                surroundLastExpression("tr")
            default: ()
            }
            doCalculation()
            tableView.reloadData()
        }
}
    
    private func scrollToBottom(table:UITableView){
        let n = self.expressions.count
        if n > 0 {
            let indexPath: NSIndexPath = NSIndexPath(forRow: n - 1, inSection: 0)
            self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: false)
            let delay = 0.01 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            
            dispatch_after(time, dispatch_get_main_queue(), {
                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
            })
        }
    }
    
	func doCalculation(){
        var res:Any!
		switch operation!{
		//two matrices -> one matrix
		case .add:
            res = firstOperand! + secondOperand!
        case .subtract:
            res = firstOperand! - secondOperand!
        case .multiplication:
            res = firstOperand! * secondOperand!
        //one matrix -> one matrix
        case .REF:
            res = firstOperand!.REF()
            results.append(res)
		case .RREF:
            res = firstOperand!.RREF()
		case .transpose:
            res = firstOperand!.transpose()
		case .inverse:
            res = firstOperand!.inverse()
		//one matrix -> two matrices
		case .chol:
		break
		case .QR:
		break
		case .LU:
		 let (P,L,U) = firstOperand!.LU()
		case .diagonalize:
		break
		case .eigenpair:
		break
		//one matrix -> scalar
		case .rank:
            res = firstOperand!.rank()
		case .trace:
            res = firstOperand!.trace()
		case .det:
            res = firstOperand!.determinant()
        default:
            break
		}
        self.results.append(res)
		firstOperand = nil
        if res is Matrix{
            firstOperand = res as? Matrix
            carryForwardAnswer = true
        }else{
            carryForwardAnswer = false
        }
		secondOperand = nil
		operation = nil
		tableView.reloadData()
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()
        scrollToBottom(tableView)
    }
	
    func didPickMatrixWithAlias(alias:String,matrix:Matrix){
		if firstOperand != nil && operation != nil{
			secondOperand = matrix
            appendToLastExpression(alias+" = ")
			doCalculation()
		}else{
            if carryForwardAnswer || firstOperand == nil{
                expressions.append(alias)
                carryForwardAnswer = false
            }else if firstOperand != nil{
                expressions[expressions.count-1] = alias
                carryForwardAnswer = false
                
            }
			firstOperand = matrix
		}
        self.tableView.reloadData()
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()
        scrollToBottom(tableView)
    }
    

    func performSegue(identifier: String?) {
        self.performSegueWithIdentifier(identifier!, sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier!{
        case "insertMatrixSegue" :
            let vc = segue.destinationViewController as! ViewController
            vc.delegate = storedMatricesView
            vc.usedCharacter = NSSet(array: storedMatricesView.storedMatrices.keys.array)
        default:
            break
        }
    }
   

}
