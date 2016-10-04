//
//  CalculatorMainScreenViewController.swift
//  Matrix Calculator
//
//  Created by Zichuan Huang on 19/07/2015.
//  Copyright (c) 2015 Zichuan Huang. All rights reserved.
//

import UIKit
import GoogleMobileAds

class CalculatorMainScreenViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,storeMatrixViewDelegate,UITextFieldDelegate,inputFractionDelegate {
    @IBOutlet weak var tableView: UITableView!    
    @IBOutlet weak var bannerView: GADBannerView!
    
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
        tableView.register(UINib(nibName: "MatrixCell", bundle: nil), forCellReuseIdentifier: CellIdentifier)
        tableView.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
        self.view.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
        tableView.backgroundView = nil
        
        
		storedMatricesView = storedMatrixView(frame: self.view.frame)
        storedMatricesView.delegate = self
		self.view.addSubview(storedMatricesView)
		storedMatricesView.isHidden = true
		storedMatricesView.alpha = 0.0
        
        fractionInputView.isHidden = true
        fractionInputView.alpha = 0.0
        fractionInputView.delegate = self
        
        let darkGray = UIColor(white: 0.8, alpha: 1.0)
        for button in lightGrayButtons{
            button.setBackgroundImage(UIImage.imageWithColor(darkGray), for: UIControlState())
            button.setBackgroundImage(UIImage.imageWithColor(darkGray.darker()), for: UIControlState.highlighted)
            button.layer.borderColor = UIColor.black.cgColor
            button.layer.borderWidth = 1
        }
        for button in orangeButtons{
            button.setBackgroundImage(UIImage.imageWithColor(UIColor.orange), for: UIControlState())
            button.setBackgroundImage(UIImage.imageWithColor(UIColor.orange.darker()), for: UIControlState.highlighted)
        }
        for view in self.view.subviews{
            if view is UIButton{
                (view as! UIButton).titleLabel?.adjustsFontSizeToFitWidth = true
            }
        }
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(CalculatorMainScreenViewController.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        swipeLeft.numberOfTouchesRequired = 2
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(CalculatorMainScreenViewController.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        swipeRight.numberOfTouchesRequired = 2
        self.view.addGestureRecognizer(swipeRight)
        
        if !UserDefaults.standard.bool(forKey: "SeenTut1"){
            showTutorialView(NSLocalizedString("FirstTimeEnter", comment: ""))
            UserDefaults.standard.set(true, forKey: "SeenTut1")
        }
        
        bannerView.adUnitID = "ca-app-pub-4444803405334579/4793171041"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "UseTimes")+1, forKey: "UseTimes")
        if UserDefaults.standard.integer(forKey: "UseTimes")%10 == 0 && !UserDefaults.standard.bool(forKey: "Rated") && !UserDefaults.standard.bool(forKey: "NeverRate"){
            presentRatingViewController()
        }
    }
    
    fileprivate func presentRatingViewController(){
        let message = NSLocalizedString("likeMessage", comment: "")
        let alert = UIAlertController(title: NSLocalizedString("likeTitle", comment: ""), message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("likeYes", comment: ""), style: .default, handler: {
            action in
            let rateAlert = UIAlertController(title: NSLocalizedString("rateTitle", comment: ""), message: NSLocalizedString("rateMessage", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            rateAlert.addAction(UIAlertAction(title: NSLocalizedString("rateYes", comment: ""), style: .default, handler: {
                action in
                UIApplication.shared.openURL(URL(string : "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1038193869&onlyLatestVersion=true&pageNumber=0&sortOrdering=1")!)
                rateAlert.removeFromParentViewController()
            }))
            rateAlert.addAction(UIAlertAction(title: NSLocalizedString("rateNo", comment: ""), style: .default, handler: {
                action in
                UserDefaults.standard.set(true, forKey: "NeverRate")
                rateAlert.removeFromParentViewController()
            }))
            rateAlert.addAction(UIAlertAction(title: NSLocalizedString("rateLater", comment: ""), style: UIAlertActionStyle.cancel, handler: {
                action in
            }))
            alert.removeFromParentViewController()
            self.present(rateAlert, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("likeNo", comment: ""), style: .default, handler: {
            action in
            let email = "lee_developer@hotmail.com"
            let url = URL(string: "mailto:\(email)")!
            UIApplication.shared.openURL(url)
            alert.removeFromParentViewController()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: {
            action in
        }))
        self.present(alert, animated: true, completion: nil)
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
        // Dispose of any resources that can be recreated.
    }
	
	fileprivate func hideViewWithAnimation(_ view:UIView){
		view.alpha = 1.0
        UIView.animate(withDuration: 0.2, animations: {
            () in
            view.alpha = 0.0
            }, completion: {
                bool in
                view.isHidden = true
        })
	}
	fileprivate func showViewWithAnimation(_ view:UIView){
		view.alpha = 0.0
		view.isHidden = false
        UIView.animate(withDuration: 0.2, animations: {
            () in
            view.alpha = 1.0
        })
	}
    
    @IBAction func showStoredMatrices(_ sender: AnyObject) {
		showViewWithAnimation(self.storedMatricesView)
    }
    
    func respondToSwipeGesture(_ gesture: UIGestureRecognizer){
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            showDecimal = !showDecimal
            switch swipeGesture.direction{
            case UISwipeGestureRecognizerDirection.left:
                self.tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.left)
            case UISwipeGestureRecognizerDirection.right:
                self.tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.right)
            default:()
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath) as! MatrixCalculationCell
        switch expressions[(indexPath as NSIndexPath).row]{
        case let string as String:
            cell.label.text = string
        case let attString as NSMutableAttributedString:
            cell.label.attributedText = attString
        default: ()
        }
		cell.label.sizeToFit()
        cell.resultMatrixView.widthLimit = cell.frame.width - cell.label.frame.width-10
        cell.resultMatrixView.isHidden = true
		cell.resultLabel.textColor = UIColor.white
        cell.resultLabel.isHidden = true
        cell.resultLabel.adjustsFontSizeToFitWidth = true
        if (indexPath as NSIndexPath).row < results.count{
            switch results[(indexPath as NSIndexPath).row] {
            case let matrix as Matrix:
                let displayMatrix = matrix.matrixCopyWithDecimal(showDecimal)
                cell.resultMatrixView.setMatrix(displayMatrix)
                cell.resultMatrixView.isHidden = false
            case let scalar as Fraction:
                cell.resultLabel.text = scalar.toString()
                cell.resultLabel.isHidden = false
                cell.resultLabel.sizeToFit()
            case let error as MatrixErrors:
				cell.resultLabel.text = error.description
				cell.resultLabel.textColor = UIColor.red
				cell.resultLabel.isHidden = false
				cell.resultLabel.sizeToFit()
            default:
            break
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expressions.count
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let regex:NSRegularExpression = try! NSRegularExpression(pattern: "[a-zA-Z]", options: NSRegularExpression.Options.caseInsensitive)
        if ((range.length + range.location > textField.text!.characters.count) || (string=="") || (regex.matches(in: string, options: [], range: NSMakeRange(0, string.characters.count)).count == 0))
        {
            return false;
        }
        textField.text = string.uppercased()
        let newLength = textField.text!.characters.count + string.characters.count - range.length
        return newLength <= 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row < self.results.count {
            if self.results[(indexPath as NSIndexPath).row] is Matrix {
                let usedCharacter = NSSet(array: Array(storedMatricesView.storedMatrices.keys))
                var inputTextField: UITextField?
                var message = NSLocalizedString("usedCharacter", comment: "")
                if usedCharacter.count == 0{
                    message += NSLocalizedString("none", comment: "")
                }else{
                    for c in "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters{
                        if usedCharacter.contains(String(c)){
                            message += String(c) + ","
                        }
                    }
                    message.remove(at: message.characters.index(before: message.endIndex))
                }
                message += NSLocalizedString("alertMsg", comment: "")
                let alert = UIAlertController(title: NSLocalizedString("saveTitle", comment: ""), message: message, preferredStyle: UIAlertControllerStyle.alert)
                alert.addTextField(configurationHandler: {(textField: UITextField!) in
                    for c in "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters{
                        if !usedCharacter.contains(String(c)){
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
                    self.storedMatricesView.didFinishInputMatrix((self.results[(indexPath as NSIndexPath).row] as! Matrix),alias: inputTextField!.text!)
                    self.dismiss(animated: true,completion:nil)
                })))
                
                DispatchQueue.main.async(execute: {
                    self.present(alert, animated: true, completion: nil)
                })
            }
        }
    }
    
    fileprivate func appendToLastExpression(_ str:String){
        expressions[expressions.count-1] = (expressions.last! as! String)+str
        
    }
    
    fileprivate func surroundLastExpression(_ str:String){
        expressions[expressions.count-1] = str+"("+(expressions.last! as! String)+") ="
    }
    
    fileprivate func appendSuperscript(_ str:String){
        let string = expressions[expressions.count-1] as! String
        let att = NSMutableAttributedString(string: string)
        let fontsize:CGFloat = 17
        att.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: fontsize), range: NSRange(location: 0, length: string.characters.count))
        let addition = NSMutableAttributedString(string: str)
        addition.addAttributes([NSFontAttributeName : UIFont.systemFont(ofSize: fontsize/2), NSBaselineOffsetAttributeName : fontsize/2], range: NSRange(location: 0, length: str.characters.count))
        att.append(addition)
        expressions[expressions.count-1] = att
    }
	
    @IBAction func twoMatrixOperation(_ sender: AnyObject) {
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
    
    @IBAction func oneMatrixToMultipleMatrix(_ sender: AnyObject) {
        if firstOperand != nil {
            if carryForwardAnswer {
                self.expressions.append("Ans")
            }
            let button:UIButton = sender as! UIButton
            switch button.tag{
            case 0:
                self.operation = .lu
            case 1:()
            case 2:()
            default:()
            }
            doCalculation()
            tableView.reloadData()
        }
    }
    
    @IBAction func oneMatrixToOneMatrix(_ sender: AnyObject) {
        if firstOperand != nil {
            if carryForwardAnswer {
                self.expressions.append("Ans")
            }
            let button:UIButton = sender as! UIButton
            switch button.tag{
            case 0:
                self.operation = .rref
                surroundLastExpression("rref")
            case 1:
                self.operation = .transpose
                appendSuperscript("T")
            case 2:
                self.operation = .inverse
                appendSuperscript("-1")
            case 3:
                self.operation = .ref
                surroundLastExpression("ref")
            default:()
            }
            doCalculation()
            tableView.reloadData()
        }
    }
    
    @IBAction func oneMatrixToScalar(_ sender: AnyObject) {
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
    
    fileprivate func scrollToBottom(_ table:UITableView){
        let n = self.expressions.count
        if n > 0 {
            let indexPath: IndexPath = IndexPath(row: n - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            let delay = 0.01 * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
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
        case .ref:
            res = firstOperand!.REF()
		case .rref:
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
		case .qr:
		break
		case .lu:
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
			
			if !UserDefaults.standard.bool(forKey: "SeenAnsTut"){
				showTutorialView(NSLocalizedString("FirstTimeMatrixAns", comment: ""))            
				UserDefaults.standard.set(true, forKey: "SeenAnsTut")
            }else if !UserDefaults.standard.bool(forKey: "SeenDecimalTut"){
                showTutorialView(NSLocalizedString("DecimalTut", comment: ""))
                UserDefaults.standard.set(true, forKey: "SeenDecimalTut")
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
	
	func didFinishInputFraction(_ fraction:Fraction,decimal:Bool){
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
	
    func didPickMatrixWithAlias(_ alias:String,matrix:Matrix){
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
    

    func performSegue(_ identifier: String?) {
        self.performSegue(withIdentifier: identifier!, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier!{
        case "insertMatrixSegue" :
            let vc = segue.destination as! ViewController
            vc.delegate = storedMatricesView
            vc.usedCharacter = NSSet(array: Array(storedMatricesView.storedMatrices.keys))
        default:
            break
        }
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
