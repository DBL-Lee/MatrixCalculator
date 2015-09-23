//
//  CalculatorMainScreenViewController.swift
//  Matrix Calculator
//
//  Created by Zichuan Huang on 19/07/2015.
//  Copyright (c) 2015 Zichuan Huang. All rights reserved.
//

import UIKit



class CalculatorMainScreenViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,storeMatrixViewDelegate,UITextFieldDelegate,inputFractionDelegate {
    @IBOutlet weak var tableView: UITableView!    
    
    @IBOutlet weak var fractionInputView: FractionInputView!
    @IBOutlet var orangeButtons: [UIButton]!
    @IBOutlet var lightGrayButtons: [UIButton]!
    let CellIdentifier = "MatrixCalculationCell"
    var expressions:[Any] = []
    var results:[Any] = []
	var firstOperand:Matrix?
	var secondOperand:Matrix?
	var scalarOperand:Fraction?
	var operation:MatrixOperations?
	var storedMatricesView:storedMatrixView!
    var carryForwardAnswer:Bool = false
    var tutorialView:TutorialOverlayView!
    var detectTouch = false
    var showDecimal = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.registerNib(UINib(nibName: "MatrixCell", bundle: nil), forCellReuseIdentifier: CellIdentifier)
        tableView.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
        tableView.backgroundView?.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
		
		storedMatricesView = storedMatrixView(frame: self.view.frame)
        storedMatricesView.delegate = self
		self.view.addSubview(storedMatricesView)
		storedMatricesView.hidden = true
		storedMatricesView.alpha = 0.0
        
        fractionInputView.hidden = true
        fractionInputView.alpha = 0.0
        fractionInputView.delegate = self
        
        let darkGray = UIColor(white: 0.8, alpha: 1.0)
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
        for view in self.view.subviews{
            if view is UIButton{
                (view as! UIButton).titleLabel?.adjustsFontSizeToFitWidth = true
            }
        }
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        swipeLeft.numberOfTouchesRequired = 2
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        swipeRight.numberOfTouchesRequired = 2
        self.view.addGestureRecognizer(swipeRight)
        
        if !NSUserDefaults.standardUserDefaults().boolForKey("SeenTut1"){
            showTutorialView(NSLocalizedString("FirstTimeEnter", comment: ""))
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "SeenTut1")
        }
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        NSUserDefaults.standardUserDefaults().setInteger(NSUserDefaults.standardUserDefaults().integerForKey("UseTimes")+1, forKey: "UseTimes")
        if NSUserDefaults.standardUserDefaults().integerForKey("UseTimes")%10 == 0 && !NSUserDefaults.standardUserDefaults().boolForKey("Rated") && !NSUserDefaults.standardUserDefaults().boolForKey("NeverRate"){
            presentRatingViewController()
        }
    }
    
    private func presentRatingViewController(){
        let message = NSLocalizedString("likeMessage", comment: "")
        let alert = UIAlertController(title: NSLocalizedString("likeTitle", comment: ""), message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("likeYes", comment: ""), style: .Default, handler: {
            action in
            let rateAlert = UIAlertController(title: NSLocalizedString("rateTitle", comment: ""), message: NSLocalizedString("rateMessage", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
            rateAlert.addAction(UIAlertAction(title: NSLocalizedString("rateYes", comment: ""), style: .Default, handler: {
                action in
                UIApplication.sharedApplication().openURL(NSURL(string : "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1038193869&onlyLatestVersion=true&pageNumber=0&sortOrdering=1")!)
                rateAlert.removeFromParentViewController()
            }))
            rateAlert.addAction(UIAlertAction(title: NSLocalizedString("rateNo", comment: ""), style: .Default, handler: {
                action in
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "NeverRate")
                rateAlert.removeFromParentViewController()
            }))
            rateAlert.addAction(UIAlertAction(title: NSLocalizedString("rateLater", comment: ""), style: UIAlertActionStyle.Cancel, handler: {
                action in
            }))
            alert.removeFromParentViewController()
            self.presentViewController(rateAlert, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("likeNo", comment: ""), style: .Default, handler: {
            action in
            let email = "lee_developer@hotmail.com"
            let url = NSURL(string: "mailto:\(email)")!
            UIApplication.sharedApplication().openURL(url)
            alert.removeFromParentViewController()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: {
            action in
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
	
	private func showTutorialView(text:String){
		self.tutorialView = TutorialOverlayView(frame: self.view.frame, text: text)
		tutorialView.translatesAutoresizingMaskIntoConstraints = false
        let viewsDict = ["tutorialView": tutorialView]
        self.view.addSubview(tutorialView)
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[tutorialView]-0-|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: viewsDict))
		self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[tutorialView]-0-|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: viewsDict))
        tutorialView.alpha = 0.0
		UIView.animateWithDuration(0.5, animations: {
            () in
            self.tutorialView.alpha = 1.0
        })
		self.detectTouch = true
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	private func hideViewWithAnimation(view:UIView){
		view.alpha = 1.0
        UIView.animateWithDuration(0.2, animations: {
            () in
            view.alpha = 0.0
            }, completion: {
                bool in
                view.hidden = true
        })
	}
	private func showViewWithAnimation(view:UIView){
		view.alpha = 0.0
		view.hidden = false
        UIView.animateWithDuration(0.2, animations: {
            () in
            view.alpha = 1.0
        })
	}
    
    @IBAction func showStoredMatrices(sender: AnyObject) {
		showViewWithAnimation(self.storedMatricesView)
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer){
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            showDecimal = !showDecimal
            switch swipeGesture.direction{
            case UISwipeGestureRecognizerDirection.Left:
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Left)
            case UISwipeGestureRecognizerDirection.Right:
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Right)
            default:()
            }
            
        }
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
        cell.resultMatrixView.widthLimit = cell.frame.width - cell.label.frame.width-10
        cell.resultMatrixView.hidden = true
		cell.resultLabel.textColor = UIColor.whiteColor()
        cell.resultLabel.hidden = true
        cell.resultLabel.adjustsFontSizeToFitWidth = true
        if indexPath.row < results.count{
            switch results[indexPath.row] {
            case let matrix as Matrix:
                let displayMatrix = matrix.matrixCopyWithDecimal(showDecimal)
                cell.resultMatrixView.setMatrix(displayMatrix)
                cell.resultMatrixView.hidden = false
            case let scalar as Fraction:
                cell.resultLabel.text = scalar.toString()
                cell.resultLabel.hidden = false
                cell.resultLabel.sizeToFit()
            case let error as MatrixErrors:
				cell.resultLabel.text = error.description
				cell.resultLabel.textColor = UIColor.redColor()
				cell.resultLabel.hidden = false
				cell.resultLabel.sizeToFit()
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
        let regex:NSRegularExpression = try! NSRegularExpression(pattern: "[a-zA-Z]", options: NSRegularExpressionOptions.CaseInsensitive)
        if ((range.length + range.location > textField.text!.characters.count) || (string=="") || (regex.matchesInString(string, options: [], range: NSMakeRange(0, string.characters.count)).count == 0))
        {
            return false;
        }
        textField.text = string.uppercaseString
        let newLength = textField.text!.characters.count + string.characters.count - range.length
        return newLength <= 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < self.results.count {
            if self.results[indexPath.row] is Matrix {
                let usedCharacter = NSSet(array: Array(storedMatricesView.storedMatrices.keys))
                var inputTextField: UITextField?
                var message = NSLocalizedString("usedCharacter", comment: "")
                if usedCharacter.count == 0{
                    message += NSLocalizedString("none", comment: "")
                }else{
                    for c in "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters{
                        if usedCharacter.containsObject(String(c)){
                            message += String(c) + ","
                        }
                    }
                    message.removeAtIndex(message.endIndex.predecessor())
                }
                message += NSLocalizedString("alertMsg", comment: "")
                let alert = UIAlertController(title: NSLocalizedString("saveTitle", comment: ""), message: message, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
                    for c in "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters{
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
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: {
                    action in
                }))
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("save", comment: ""), style: UIAlertActionStyle.Default, handler: ({
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
        att.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(fontsize), range: NSRange(location: 0, length: string.characters.count))
        let addition = NSMutableAttributedString(string: str)
        addition.addAttributes([NSFontAttributeName : UIFont.systemFontOfSize(fontsize/2), NSBaselineOffsetAttributeName : fontsize/2], range: NSRange(location: 0, length: str.characters.count))
        att.appendAttributedString(addition)
        expressions[expressions.count-1] = att
    }
	
    @IBAction func twoMatrixOperation(sender: AnyObject) {
        if firstOperand != nil{
            if carryForwardAnswer {
                self.expressions.append("Ans")
            }
            let button:UIButton = sender as! UIButton
            print(button.tag)
            switch button.tag{
            case 0:
                self.operation = .add
                appendToLastExpression(" + ")
				self.showViewWithAnimation(self.storedMatricesView)
            case 1:
                self.operation = .subtract
                appendToLastExpression(" - ")
				self.showViewWithAnimation(self.storedMatricesView)
            case 2:
                self.operation = .multiplication
                appendToLastExpression(" × ")
				self.showViewWithAnimation(self.storedMatricesView)
			case 3:
				self.operation = .scalarmult
				appendToLastExpression(" × ")
				self.showViewWithAnimation(self.fractionInputView)
            default: ()
            }
            tableView.reloadData()
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
			do{
				res = try firstOperand! + secondOperand!
			}catch{
				res = error
			}
		case .subtract:
            do{
				res = try firstOperand! - secondOperand!
			}catch{
				res = error
			}
        case .multiplication:
            do{
				res = try firstOperand! * secondOperand!
			}catch{
				res = error
			}
		case .scalarmult:
			res = firstOperand!.multScalar(scalarOperand!)
        //one matrix -> one matrix
        case .REF:
            res = firstOperand!.REF()
		case .RREF:
            res = firstOperand!.RREF()
		case .transpose:
            res = firstOperand!.transpose()
		case .inverse:
			do{
				res = try firstOperand!.inverse()
			}catch{
				res = error
			}
		//one matrix -> two matrices
		case .chol:
		break
		case .QR:
		break
		case .LU:
			let (P,L,U) = firstOperand!.LU()
			self.expressions[self.expressions.count-1] = "P"
			self.expressions.append("L")
			self.expressions.append("U")
			self.results.append(P)
			self.results.append(L)
			res = U
		case .diagonalize:
		break
		case .eigenpair:
		break
		//one matrix -> scalar
		case .rank:
            res = firstOperand!.rank()
		case .trace:
			do{
				res = try firstOperand!.trace()
			}catch {
				res = error
			}
		case .det:
			do{
				res = try firstOperand!.determinant()
			}catch {
				res = error
			}
		}
        self.results.append(res)
		firstOperand = nil
        if res is Matrix{
            firstOperand = res as? Matrix
            carryForwardAnswer = true
			
			if !NSUserDefaults.standardUserDefaults().boolForKey("SeenAnsTut"){
				showTutorialView(NSLocalizedString("FirstTimeMatrixAns", comment: ""))            
				NSUserDefaults.standardUserDefaults().setBool(true, forKey: "SeenAnsTut")
            }else if !NSUserDefaults.standardUserDefaults().boolForKey("SeenDecimalTut"){
                showTutorialView(NSLocalizedString("DecimalTut", comment: ""))
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "SeenDecimalTut")
            }

            
        }else{
            carryForwardAnswer = false
        }
		scalarOperand = nil
		secondOperand = nil
		operation = nil
		tableView.reloadData()
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()
        scrollToBottom(tableView)
    }
	
	func didFinishInputFraction(fraction:Fraction,decimal:Bool){
		scalarOperand = fraction
		appendToLastExpression(fraction.toString(decimal))
		doCalculation()
		hideViewWithAnimation(self.fractionInputView)
        self.tableView.reloadData()
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
		hideViewWithAnimation(self.storedMatricesView)
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
            vc.usedCharacter = NSSet(array: Array(storedMatricesView.storedMatrices.keys))
        default:
            break
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if detectTouch {
			UIView.animateWithDuration(0.5, animations: {
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
