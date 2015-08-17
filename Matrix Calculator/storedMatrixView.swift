//
//  storedMatrixView.swift
//  Matrix Calculator
//
//  Created by Zichuan Huang on 16/08/2015.
//  Copyright (c) 2015 Zichuan Huang. All rights reserved.
//

import UIKit

protocol storeMatrixViewDelegate{
	var storedMatrices:[String:Matrix]
	func didPickMatrixWithAlias(alias:String)
}

class storedMatrixView: UIView,UITableViewDataSource,UITableViewDelegate,inputMatrixDelegate {

	let CellIdentifier = "MatrixCalculationCell"
	var storedAlias:[String] = []
	var storedMatrices:[Matrix] = []
	var tableView:UITableView!
	var delegate:storeMatrixViewDelegate
	
	init(storedMatrices:[String:Matrix],frame:CGRect){
		for (n,m) in storedMatrices {
			storedAlias.append(n)
			storedMatrices.append(m)
		}
		super.init(frame)
		self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
		tableView = UITableView()
		
		var smallframe = CGRect(0,0,frame.width*0.8,frame.height*0.8)
		var containerView = UIView()
		containerView.frame = smallframe
		containerView.layer.borderWidth = 2
		self.addSubview(containerView)
		
		let button   = UIButton.buttonWithType(UIButtonType.ContactAdd) as UIButton
		let buttonframe = CGRectMake(0, 0, frame.width*0.1, frame.width*0.1)
		buttonframe.center = CGPoint(frame.width*0.75,frame.height*0.15)
		button.frame = buttonframe
		button.addTarget(self, action: "addMatrix:", forControlEvents: UIControlEvents.TouchUpInside)
		self.view.addSubview(button)
		
		smallframe = CGRect(0,0,frame.width*0.8,frame.height*0.7)
		smallframe.center = frame.center
		tableView.frame = smallframe
		tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView(frame: CGRect.zeroRect)
		tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier)
		tableView.delegate = self
		tableView.dataSource = self
		self.addSubview(tableView)
	}
	
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
	func addMatrix(sender:UIButton!){
		performSegueWithIdentifier("insertMatrixSegue", sender: sender)
	}
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storedAlias.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! MatrixCalculationCell
        cell.label.text = storedAlias[indexPath.row]
		cell.label.sizeToFit()
        cell.resultMatrixView.setMatrix(storedMatrices[indexPath.row])
		while (CGRectIntersectsRect(cell.label.frame,cell.resultMatrixView.frame)){
			cell.resultMatrixView.decreaseFont()
		}
        return cell
    }
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
		delegate?.didPickMatrixWithAlias(storedAlias[indexPath.row])
		self.hidden = true
	}
	
	func didFinishInputMatrix(matrix: Matrix, alias: String) {
        storedAlias.append(alias)
        storedMatrices.append(matrix)
        delegate.storedMatrices[alias] = matrix
        self.tableView.reloadData()
    }
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier!{
        case "insertMatrixSegue" :
            let vc = segue.destinationViewController as! ViewController
            vc.delegate = self
            vc.usedCharacter = NSSet(array: storedAlias)
        default:
            break
        }
    }
}
