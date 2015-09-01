//
//  MatrixCalculationCell.swift
//  Matrix Calculator
//
//  Created by Zichuan Huang on 13/08/2015.
//  Copyright (c) 2015 Zichuan Huang. All rights reserved.
//

import UIKit

class MatrixCalculationCell: UITableViewCell {

    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    
    @IBOutlet weak var resultMatrixView: matrixTableView!    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = UITableViewCellSelectionStyle.None
        // Configure the view for the selected state
    }

}
