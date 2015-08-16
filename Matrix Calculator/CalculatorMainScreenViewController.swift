//
//  CalculatorMainScreenViewController.swift
//  Matrix Calculator
//
//  Created by Zichuan Huang on 19/07/2015.
//  Copyright (c) 2015 Zichuan Huang. All rights reserved.
//

import UIKit

class CalculatorMainScreenViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,inputMatrixDelegate {
    @IBOutlet weak var tableView: UITableView!

    
    var storedMatrices:[String:Matrix] = [String:Matrix]()
    let CellIdentifier = "MatrixCalculationCell"
    var expressions:[String] = []
    var matrices:[Matrix] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView(frame: CGRect.zeroRect)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showStoredMatrices(sender: AnyObject) {
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! MatrixCalculationCell
        cell.label.text = expressions[indexPath.row]
        cell.resultMatrixView.setMatrix(matrices[indexPath.row])
        //println(cell.resultMatrixView.frame)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matrices.count
    }
    
    func didFinishInputMatrix(matrix: Matrix, alias: String) {
        expressions.append(alias)
        matrices.append(matrix)
        storedMatrices[alias] = matrix
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier!{
        case "insertMatrixSegue" :
            let vc = segue.destinationViewController as! ViewController
            vc.delegate = self
            vc.usedCharacter = NSSet(array: storedMatrices.keys.array)
        default:
            break
        }
    }

}
