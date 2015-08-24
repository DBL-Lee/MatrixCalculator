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
	case GJe
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

class CalculatorMainScreenViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,storeMatrixViewDelegate {
    @IBOutlet weak var tableView: UITableView!    
    
    let CellIdentifier = "MatrixCalculationCell"
    var expressions:[String] = []
    var results:[Any] = []
	var firstOperand:Matrix?
	var secondOperand:Matrix?
	var operation:MatrixOperations?
	var storedMatricesView:storedMatrixView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView(frame: CGRect.zeroRect)
        tableView.registerNib(UINib(nibName: "MatrixCell", bundle: nil), forCellReuseIdentifier: CellIdentifier)
		
		storedMatricesView = storedMatrixView(frame: self.view.frame)
        storedMatricesView.delegate = self
		self.view.addSubview(storedMatricesView)
		storedMatricesView.hidden = true
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
        cell.label.text = expressions[indexPath.row]
		cell.label.sizeToFit()
		switch results[indexPath.row] {
		case let matrix as Matrix:
			cell.resultMatrixView.setMatrix(matrix)
		case let scalar as Double:
            break
		case let error as String:
            break
		default:
		break
		}
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expressions.count
    }
	
	func doCalculation(){
		switch operation!{
		//two matrices -> one matrix
		case .add:
		break
		case .subtract:
		break
		case .multiplication:
		break
		//one matrix -> one matrix
		case .GJe:
		break
		case .transpose:
		break
		case .inverse:
		break
		//one matrix -> two matrices
		case .chol:
		break
		case .QR:
		break
		case .LU:
		break
		case .diagonalize:
		break
		case .eigenpair:
		break
		//one matrix -> scalar
		case .rank:
		break
		case .trace:
		break
		case .det:
        break
        default:
            break
		}
	
		firstOperand = nil
		secondOperand = nil
		operation = nil
		tableView.reloadData()
	}
	
    func didPickMatrixWithAlias(alias:String,matrix:Matrix){
		if firstOperand != nil {
			secondOperand = matrix
			doCalculation()
		}else{
			firstOperand = matrix
			results.append(matrix)
		}
		self.tableView.reloadData()
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()
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
