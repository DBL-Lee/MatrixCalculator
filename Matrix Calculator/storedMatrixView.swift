//
//  storedMatrixView.swift
//  Matrix Calculator
//
//  Created by Zichuan Huang on 16/08/2015.
//  Copyright (c) 2015 Zichuan Huang. All rights reserved.
//

import UIKit

protocol storeMatrixViewDelegate{
    var storedMatrices:[String:Matrix] {get set}
	func didPickMatrixWithAlias(alias:String)
    func performSegueWithIdentifier(identifier: String?, sender: AnyObject?)
}

class storedMatrixView: UIView,UITableViewDataSource,UITableViewDelegate,inputMatrixDelegate {

	let CellIdentifier = "MatrixCalculationCell"
	var storedAlias:[String] = []
	var storedMatrices:[Matrix] = []
	var storedTableView:UITableView!
	var delegate:storeMatrixViewDelegate!
	
	init(storedMatrices:[String:Matrix],frame:CGRect){
		for (n,m) in storedMatrices {
			self.storedAlias.append(n)
			self.storedMatrices.append(m)
		}
		super.init(frame: frame)
		self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
		storedTableView = UITableView()
		
		var smallframe = CGRect(x: frame.width*0.1,y: frame.height*0.1,width: frame.width*0.8,height: frame.height*0.8)
		var containerView = UIView()
		containerView.frame = smallframe
        containerView.backgroundColor = UIColor.whiteColor()
		containerView.layer.borderWidth = 2
		self.addSubview(containerView)
		
		let button   = UIButton.buttonWithType(UIButtonType.ContactAdd) as! UIButton
		let buttonframe = CGRectMake(0, 0, frame.width*0.1, frame.width*0.1)
        button.frame = buttonframe
		button.center = CGPoint(x: frame.width*0.85,y: frame.height*0.15)
		button.addTarget(self, action: "addMatrix:", forControlEvents: UIControlEvents.TouchUpInside)
		self.addSubview(button)
		
		smallframe = CGRect(x: frame.width*0.1,y: frame.height*0.2,width: frame.width*0.8,height: frame.height*0.7)
        storedTableView.frame = smallframe
        
		storedTableView.rowHeight = UITableViewAutomaticDimension
        storedTableView.estimatedRowHeight = 100.0
        storedTableView.showsVerticalScrollIndicator = false
        storedTableView.tableFooterView = UIView(frame: CGRect.zeroRect)
		storedTableView.registerNib(UINib(nibName: "MatrixCell", bundle: nil), forCellReuseIdentifier: CellIdentifier)
		storedTableView.delegate = self
		storedTableView.dataSource = self
		self.addSubview(storedTableView)
	}
	
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
	func addMatrix(sender:UIButton!){
		delegate.performSegueWithIdentifier("insertMatrixSegue", sender: sender)
	}
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate.storedMatrices.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:MatrixCalculationCell = storedTableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as! MatrixCalculationCell
        let text = delegate.storedMatrices.keys.array[indexPath.row]
        cell.label.text = text
		cell.label.sizeToFit()
        cell.resultMatrixView.setMatrix(delegate.storedMatrices[text]!)
		while (CGRectIntersectsRect(cell.label.frame,cell.resultMatrixView.frame)){
			cell.resultMatrixView.decreaseFont()
		}
        return cell
    }
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! MatrixCalculationCell
		delegate.didPickMatrixWithAlias(cell.label.text!)
		self.hidden = true
	}
	
	func didFinishInputMatrix(matrix: Matrix, alias: String) {
        delegate.storedMatrices[alias] = matrix
        self.storedTableView.reloadData()
    }
	

}
