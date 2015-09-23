//
//  storedMatrixView.swift
//  Matrix Calculator
//
//  Created by Zichuan Huang on 16/08/2015.
//  Copyright (c) 2015 Zichuan Huang. All rights reserved.
//

import UIKit



protocol storeMatrixViewDelegate{
    func didPickMatrixWithAlias(alias:String,matrix:Matrix)
    func performSegue(identifier: String?)
}

class storedMatrixView: UIView,UITableViewDataSource,UITableViewDelegate,inputMatrixDelegate {

	let CellIdentifier = "MatrixCalculationCell"
	var storedMatrices:[String:Matrix] = [String:Matrix]()
	var sortedKeys:[String] {
		get {
			return storedMatrices.keys.sort()
		}
	}
    
	var storedTableView:UITableView!
	var delegate:storeMatrixViewDelegate!
	
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        storedTableView = UITableView()
        
		let borderWidth:CGFloat = 2
        var smallframe = CGRect(x: frame.width*0.1-borderWidth,y: frame.height*0.1-borderWidth,width: frame.width*0.8+borderWidth*2,height: frame.height*0.8+borderWidth*2)
        let containerView = UIView()
        containerView.frame = smallframe
        containerView.backgroundColor = UIColor.blackColor()
        containerView.layer.borderWidth = borderWidth
        self.addSubview(containerView)
        
        let button   = UIButton()
        let buttonframe = CGRectMake(0, 0, frame.width*0.3, frame.width*0.2)
        button.frame = buttonframe
        button.setTitle(NSLocalizedString("new", comment: ""), forState: UIControlState.Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.setTitleColor(UIColor.whiteColor().darker(), forState: UIControlState.Highlighted)
        button.center = CGPoint(x: frame.width*0.8,y: frame.height*0.15)
        button.addTarget(self, action: "addMatrix:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(button)
        
        smallframe = CGRect(x: frame.width*0.1,y: frame.height*0.2,width: frame.width*0.8,height: frame.height*0.7)
        storedTableView.frame = smallframe
        storedTableView.backgroundColor = UIColor(white: 0.25, alpha: 1)
        storedTableView.backgroundView?.backgroundColor = UIColor(white: 0.25, alpha: 1)
        storedTableView.rowHeight = UITableViewAutomaticDimension
        storedTableView.estimatedRowHeight = 100.0
        storedTableView.showsVerticalScrollIndicator = false
        storedTableView.tableFooterView = UIView(frame: CGRect.zero)
        storedTableView.registerNib(UINib(nibName: "MatrixCell", bundle: nil), forCellReuseIdentifier: CellIdentifier)
        storedTableView.delegate = self
        storedTableView.dataSource = self
        self.addSubview(storedTableView)
        for view in self.subviews{
            if view is UIButton{
                (view as! UIButton).titleLabel?.adjustsFontSizeToFitWidth = true
            }
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
	func addMatrix(sender:UIButton!){
        delegate.performSegue("insertMatrixSegue")
	}
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storedMatrices.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:MatrixCalculationCell = storedTableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as! MatrixCalculationCell
        let text = sortedKeys[indexPath.row]
        cell.label.text = text
		cell.label.sizeToFit()
		cell.resultMatrixView.widthLimit = tableView.frame.width*0.8
        cell.resultMatrixView.setMatrix(storedMatrices[text]!)
        cell.resultMatrixView.hidden = false
        return cell
    }
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! MatrixCalculationCell
		delegate.didPickMatrixWithAlias(cell.label.text!,matrix: storedMatrices[cell.label.text!]!)
	}
	
	func didFinishInputMatrix(matrix: Matrix, alias: String) {
        storedMatrices[alias] = matrix
        self.storedTableView.reloadData()
        self.storedTableView.setNeedsLayout()
        self.storedTableView.layoutIfNeeded()
        self.storedTableView.reloadData()
    }
	

}
