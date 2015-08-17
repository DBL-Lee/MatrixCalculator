//
//  CalculatorMainScreenViewController.swift
//  Matrix Calculator
//
//  Created by Zichuan Huang on 19/07/2015.
//  Copyright (c) 2015 Zichuan Huang. All rights reserved.
//

import UIKit

class CalculatorMainScreenViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,storeMatrixViewDelegate {
    @IBOutlet weak var tableView: UITableView!

    
    var storedMatrices:[String:Matrix] = [String:Matrix]()
    let CellIdentifier = "MatrixCalculationCell"
    var expressions:[String] = []
    var matrices:[Matrix] = []
	var storedMatricesView:storedMatrixView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView(frame: CGRect.zeroRect)
		
		storedMatricesView = storedMatrixView(storedMatrices,self.frame)
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
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! MatrixCalculationCell
        cell.label.text = expressions[indexPath.row]
		cell.label.sizeToFit()
        cell.resultMatrixView.setMatrix(matrices[indexPath.row])
        while (CGRectIntersectsRect(cell.label.frame,cell.resultMatrixView.frame)){
			cell.resultMatrixView.decreaseFont()
		}
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matrices.count
    }
	
	func didPickMatrixWithAlias(alias:String){
		
		tableView.reloadData()
	}
   

}
