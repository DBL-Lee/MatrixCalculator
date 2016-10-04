//
//  storedMatrixView.swift
//  Matrix Calculator
//
//  Created by Zichuan Huang on 16/08/2015.
//  Copyright (c) 2015 Zichuan Huang. All rights reserved.
//

import UIKit



protocol storeMatrixViewDelegate{
    func didPickMatrixWithAlias(_ alias:String,matrix:Matrix)
    func performSegue(_ identifier: String?)
}

class storedMatrixView: UIView,UITableViewDataSource,UITableViewDelegate,inputMatrixDelegate {

	let CellIdentifier = "MatrixCalculationCell"
	var storedMatrices:[String:Matrix] = [String:Matrix]()
	var sortedKeys:[String] {
		get {
			return storedMatrices.keys.sorted()
		}
	}
    
	var storedTableView:UITableView!
	var delegate:storeMatrixViewDelegate!
	
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        storedTableView = UITableView()
        
		let borderWidth:CGFloat = 2
        var smallframe = CGRect(x: frame.width*0.1-borderWidth,y: frame.height*0.1-borderWidth,width: frame.width*0.8+borderWidth*2,height: frame.height*0.8+borderWidth*2)
        let containerView = UIView()
        containerView.frame = smallframe
        containerView.backgroundColor = UIColor.black
        containerView.layer.borderWidth = borderWidth
        self.addSubview(containerView)
        
        let button   = UIButton()
        let buttonframe = CGRect(x: 0, y: 0, width: frame.width*0.3, height: frame.width*0.2)
        button.frame = buttonframe
        button.setTitle(NSLocalizedString("new", comment: ""), for: UIControlState())
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.setTitleColor(UIColor.white.darker(), for: UIControlState.highlighted)
        button.center = CGPoint(x: frame.width*0.8,y: frame.height*0.15)
        button.addTarget(self, action: #selector(storedMatrixView.addMatrix(_:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button)
        
        smallframe = CGRect(x: frame.width*0.1,y: frame.height*0.2,width: frame.width*0.8,height: frame.height*0.7)
        storedTableView.frame = smallframe
        storedTableView.backgroundColor = UIColor(white: 0.25, alpha: 1)
        storedTableView.backgroundView?.backgroundColor = UIColor(white: 0.25, alpha: 1)
        storedTableView.rowHeight = UITableViewAutomaticDimension
        storedTableView.estimatedRowHeight = 100.0
        storedTableView.showsVerticalScrollIndicator = false
        storedTableView.tableFooterView = UIView(frame: CGRect.zero)
        storedTableView.register(UINib(nibName: "MatrixCell", bundle: nil), forCellReuseIdentifier: CellIdentifier)
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
	
	func addMatrix(_ sender:UIButton!){
        delegate.performSegue("insertMatrixSegue")
	}
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storedMatrices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MatrixCalculationCell = storedTableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath) as! MatrixCalculationCell
        let text = sortedKeys[(indexPath as NSIndexPath).row]
        cell.label.text = text
		cell.label.sizeToFit()
		cell.resultMatrixView.widthLimit = tableView.frame.width*0.8
        cell.resultMatrixView.setMatrix(storedMatrices[text]!)
        cell.resultMatrixView.isHidden = false
        return cell
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let cell = tableView.cellForRow(at: indexPath) as! MatrixCalculationCell
		delegate.didPickMatrixWithAlias(cell.label.text!,matrix: storedMatrices[cell.label.text!]!)
	}
	
	func didFinishInputMatrix(_ matrix: Matrix, alias: String) {
        storedMatrices[alias] = matrix
        self.storedTableView.reloadData()
        self.storedTableView.setNeedsLayout()
        self.storedTableView.layoutIfNeeded()
        self.storedTableView.reloadData()
    }
	

}
