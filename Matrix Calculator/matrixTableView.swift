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
    var currentFontSize:CGFloat = 0
    var maxWidth:[CGFloat]!
    
    
    let xMARGIN:CGFloat = 10.0
    let yMARGIN:CGFloat = 5.0
	var widthLimit:CGFloat = 100000 //No limit
	var heightLimit:CGFloat = 100000 //No limit
	
	//Matrix borders
	let borderWidth:CGFloat = 1
	let borderLength:CGFloat = 3
	let leftu:UIView!
	let left:UIView!
	let leftd:UIView!
	let rightu:UIView!
	let right:UIView!
	let rightd:UIView!
	var underline:(Int,Int)!
	
	func setLabel(i:Int,j:Int,s:String){
		let underlineString = NSMutableAttributedString(string: s)
		underlineString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: NSRange(location: 0, length: count(s)))
		label[i][j].attributedText = underlineString
		label[i][j].sizeToFit()
        maxWidth[j] = 0
        for k in 0..<label.count{
            maxWidth[j] = max(maxWidth[j],label[k][j].frame.width)
        }
		adjustLayout()
	}
	
	//0 Up, 1 Down, 2 Left, 3 Right
	func shiftUnderline(direction:Int){
		label[underline.0][underline.1].text = label[underline.0][underline.1].attributedText.string
		maxWidth[underline.1] = max(maxWidth[underline.1],label[underline.0][underline.1].frame.width)
		switch direction{
		case 0:
			underline.0--
		case 1:
			underline.0++
		case 2:
			underline.1--
		case 3:
			underline.1++
		default: ()
		}
		setLabel(underline.0,j: underline.1,s: label[underline.0][underline.1].text!)		
	}
	
    func setMatrix(matrix:Matrix,underline:(Int,Int)! = nil){
		self.underline = underline
        self.matrix = matrix
        for v in self.subviews {
            if v is UILabel {
                v.removeFromSuperview()
            }
        }
        self.label = []
        let nrow = matrix.matrix.count
        let ncol = matrix.matrix[0].count
        var strings:[[String]] = []
        maxWidth = [CGFloat](count:ncol,repeatedValue:0)
        for i in 0..<nrow{
            label.append([])
            for j in 0..<ncol{
				label[i].append(UILabel())
                label[i][j].numberOfLines = 1
				if let (underlinei,underlinej) = underline{
					if i==underlinei && j==underlinej{
						let underlineString = NSMutableAttributedString(string: matrix.matrix[i][j].toString(matrix.decimal[i][j]))
						underlineString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: NSRange(location: 0, length: count(matrix.matrix[i][j].toString(matrix.decimal[i][j]))))
						label[i][j].attributedText = underlineString
					}else{
						let toAppend = matrix.matrix[i][j].toString(matrix.decimal[i][j])
						label[i][j].text = toAppend
					}
				}else{
					let toAppend = matrix.matrix[i][j].toString(matrix.decimal[i][j])
					label[i][j].text = toAppend
				}
                label[i][j].sizeToFit()
                maxWidth[j] = max(maxWidth[j],label[i][j].frame.width)
            }
        }
		currentFontSize = label[0][0].font.pointSize
        adjustLayout()		
    }
	
	func adjustLayout(){
        let ncol = label[0].count
        let nrow = label.count
		var totalWidth:CGFloat = 0
        for i in 0..<ncol {
            totalWidth += xMARGIN + maxWidth[i]
        }
        totalWidth += xMARGIN        
		
        let maxHeight = label[0][0].frame.size.height
        let totalHeight:CGFloat = maxHeight * CGFloat(label.count) + yMARGIN * CGFloat(nrow+1)
        widthConstraint.constant = totalWidth
        heightConstraint.constant = totalHeight
        if totalWidth > widthLimit || totalHeight > heightLimit{
            decreaseFont()
        }else{
            self.setNeedsLayout()
            
            var y:CGFloat = yMARGIN + maxHeight/2
            for i in 0..<nrow{
                var x:CGFloat = xMARGIN + maxWidth[0]/2
                label[i][0].center = CGPoint(x: x, y: y)
                self.addSubview(label[i][0])
                label[i][0].textColor = UIColor.whiteColor()
                for j in 1..<ncol{
                    x += xMARGIN + maxWidth[j-1]/2 + maxWidth[j]/2
                    label[i][j].center = CGPoint(x: x, y: y)
                    self.addSubview(label[i][j])
                    label[i][j].textColor = UIColor.whiteColor()
                }
                y += yMARGIN + maxHeight
            }
        }
	}
	
	func decreaseFont(){
		currentFontSize--
        maxWidth = [CGFloat](count:label[0].count,repeatedValue:0)
		for i in 0..<label.count{
			for j in 0..<label[0].count{
                label[i][j].font = label[i][j].font.fontWithSize(currentFontSize)
				label[i][j].sizeToFit()
                maxWidth[j] = max(maxWidth[j],label[i][j].frame.width)
			}
		}
		adjustLayout()
	}
    
    class func preconfig()->UIView{
        let view = UIView(frame:CGRect.zeroRect)
        view.backgroundColor = UIColor.whiteColor()
        return(view)
    }
    
    required init(coder aDecoder: NSCoder) {

        leftu = matrixTableView.preconfig()
        left = matrixTableView.preconfig()
        leftd = matrixTableView.preconfig()
        rightu = matrixTableView.preconfig()
        right = matrixTableView.preconfig()
        rightd = matrixTableView.preconfig()
        super.init(coder: aDecoder)
        widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 80)
        heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 80)
        self.addConstraints([widthConstraint,heightConstraint])
        
        self.addSubview(left)
        left.setTranslatesAutoresizingMaskIntoConstraints(true)
        left.frame = CGRect(x: 0, y: 0, width: borderWidth, height: self.frame.height)
        left.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleHeight
        
        self.addSubview(leftu)
        leftu.setTranslatesAutoresizingMaskIntoConstraints(true)
        leftu.frame = CGRect(x: 0, y: 0, width: borderLength, height: borderWidth)
        leftu.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin | UIViewAutoresizing.FlexibleRightMargin
        
        self.addSubview(leftd)
        leftd.setTranslatesAutoresizingMaskIntoConstraints(true)
        leftd.frame = CGRect(x: 0, y: self.frame.height-borderWidth, width: borderLength, height: borderWidth)
        leftd.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleRightMargin
        
        self.addSubview(right)
        right.setTranslatesAutoresizingMaskIntoConstraints(true)
        right.frame = CGRect(x: self.frame.width-borderWidth, y: 0, width: borderWidth, height: self.frame.height)
        right.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleLeftMargin
        
        self.addSubview(rightu)
        rightu.setTranslatesAutoresizingMaskIntoConstraints(true)
        rightu.frame = CGRect(x: self.frame.width-borderLength, y: 0, width: borderLength, height: borderWidth)
        rightu.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin | UIViewAutoresizing.FlexibleLeftMargin
        
        self.addSubview(rightd)
        rightd.frame = CGRect(x: self.frame.width-borderLength, y: self.frame.height-borderWidth, width: borderLength, height: borderWidth)
        rightd.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleTopMargin
        
    }
    
    override init(frame: CGRect) {
        leftu = matrixTableView.preconfig()
        left = matrixTableView.preconfig()
        leftd = matrixTableView.preconfig()
        rightu = matrixTableView.preconfig()
        right = matrixTableView.preconfig()
        rightd = matrixTableView.preconfig()
        super.init(frame: frame)
		widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: frame.width)
        heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: frame.height)
        self.addConstraints([widthConstraint,heightConstraint])
        
        self.addSubview(left)
        left.setTranslatesAutoresizingMaskIntoConstraints(true)
        left.frame = CGRect(x: 0, y: 0, width: borderWidth, height: self.frame.height)
        left.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleHeight
        
        self.addSubview(leftu)
        leftu.setTranslatesAutoresizingMaskIntoConstraints(true)
        leftu.frame = CGRect(x: 0, y: 0, width: borderLength, height: borderWidth)
        leftu.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin | UIViewAutoresizing.FlexibleRightMargin
        
        self.addSubview(leftd)
        leftd.setTranslatesAutoresizingMaskIntoConstraints(true)
        leftd.frame = CGRect(x: 0, y: self.frame.height-borderWidth, width: borderLength, height: borderWidth)
        leftd.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleRightMargin
        
        self.addSubview(right)
        right.setTranslatesAutoresizingMaskIntoConstraints(true)
        right.frame = CGRect(x: self.frame.width-borderWidth, y: 0, width: borderWidth, height: self.frame.height)
        right.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleLeftMargin
        
        self.addSubview(rightu)
        rightu.setTranslatesAutoresizingMaskIntoConstraints(true)
        rightu.frame = CGRect(x: self.frame.width-borderLength, y: 0, width: borderLength, height: borderWidth)
        rightu.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin | UIViewAutoresizing.FlexibleLeftMargin
        
        self.addSubview(rightd)
        rightd.frame = CGRect(x: self.frame.width-borderLength, y: self.frame.height-borderWidth, width: borderLength, height: borderWidth)
        rightd.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleTopMargin
    }
    
}
