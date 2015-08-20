//
//  CalculatorMainScreenViewController.swift
//  Matrix Calculator
//
//  Created by Zichuan Huang on 19/07/2015.
//  Copyright (c) 2015 Zichuan Huang. All rights reserved.
//

import UIKit

enum matrixOperations{
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
			while (CGRectIntersectsRect(cell.label.frame,cell.resultMatrixView.frame)){
				cell.resultMatrixView.decreaseFont()
			}
		case let scalar as Double:
		case let error as String:
		default:
		break
		}
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expressions.count
    }
	
	func doCalculation(){
		switch operation{
		//two matrices -> one matrix
		case .add:
		
		case .subtract:
		
		case .multiplication:
		
		//one matrix -> one matrix
		case .GJe:
		
		case .transpose:
		
		case .inverse:
		
		//one matrix -> two matrices
		case .chol:
		
		case .QR:
		
		case .LU:
		
		case .diagonalize:
		
		case .eigenpair:
		
		//one matrix -> scalar
		case .rank:
		
		case .trace:
		
		case .det:
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
		tableView.reloadData()
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
