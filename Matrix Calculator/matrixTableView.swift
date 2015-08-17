//
//  matrixTableView.swift
//  Matrix Calculator
//
//  Created by Zichuan Huang on 13/08/2015.
//  Copyright (c) 2015 Zichuan Huang. All rights reserved.
//

import UIKit

class matrixTableView: UIView {

    var matrix:Matrix!
    var label:[[UILabel]] = []
    var widthConstraint:NSLayoutConstraint!
    var heightConstraint:NSLayoutConstraint!
	var currentFontSize = 0
    
    
    let xMARGIN:CGFloat = 10.0
    let yMARGIN:CGFloat = 5.0

    func setMatrix(matrix:Matrix){
        self.matrix = matrix
        let nrow = matrix.matrix.count
        let ncol = matrix.matrix[0].count
        var strings:[[String]] = []
        var maxWidth:[CGFloat] = [CGFloat](count:ncol,repeatedValue:0)
        for i in 0..<nrow{
            label.append([])
            for j in 0..<ncol{
                let toAppend = matrix.matrix[i][j].toString()
                label[i].append(UILabel())
                label[i][j].text = toAppend
                label[i][j].numberOfLines = 1
                label[i][j].sizeToFit()
                maxWidth[j] = max(maxWidth[j],label[i][j].frame.size.width)
            }
        }
		currentFontSize = label[0][0].font.pointSize
        adjustLayout()
    }
	
	func adjustLayout(){
		var totalWidth:CGFloat = 0
        for i in 0..<ncol {
            totalWidth += xMARGIN + maxWidth[i]
        }
        totalWidth += xMARGIN        
		
        let maxHeight = label[0][0].frame.size.height
        let totalHeight:CGFloat = maxHeight * CGFloat(nrow) + yMARGIN * CGFloat(nrow+1)
        widthConstraint.constant = totalWidth
        heightConstraint.constant = totalHeight
        self.setNeedsLayout()
        
        var y:CGFloat = yMARGIN + maxHeight/2
        for i in 0..<nrow{
            var x:CGFloat = xMARGIN + maxWidth[0]/2
            label[i][0].center = CGPoint(x: x, y: y)
            self.addSubview(label[i][0])
            for j in 1..<ncol{
                x += xMARGIN + maxWidth[j-1]/2 + maxWidth[j]/2
                label[i][j].center = CGPoint(x: x, y: y)
                self.addSubview(label[i][j])
            }
            y += yMARGIN + maxHeight
        }
	}
	
	func decreaseFont(){
		currentFontSize--
		for i in 0..<label.count{
			for j in 0..<label[0].count{
				label[i][j].font.pointSize = currentFontSize
				label[i][j].sizeToFit()
                maxWidth[j] = max(maxWidth[j],label[i][j].frame.size.width)
			}
		}
		adjustLayout()
	}

    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 80)
        heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 80)
        self.addConstraints([widthConstraint,heightConstraint])
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
}
