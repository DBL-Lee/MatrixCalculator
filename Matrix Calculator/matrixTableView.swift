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
	
	func setLabel(_ i:Int,j:Int,s:String){
		let underlineString = NSMutableAttributedString(string: s)
		underlineString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleSingle.rawValue, range: NSRange(location: 0, length: s.characters.count))
		label[i][j].attributedText = underlineString
		label[i][j].sizeToFit()
        maxWidth[j] = 0
        for k in 0..<label.count{
            maxWidth[j] = max(maxWidth[j],label[k][j].frame.width)
        }
		adjustLayout()
	}
	
	//0 Up, 1 Down, 2 Left, 3 Right
	func shiftUnderline(_ direction:Int){
		label[underline.0][underline.1].text = label[underline.0][underline.1].attributedText!.string
		maxWidth[underline.1] = max(maxWidth[underline.1],label[underline.0][underline.1].frame.width)
		switch direction{
		case 0:
			underline.0 -= 1
		case 1:
			underline.0 += 1
		case 2:
			underline.1 -= 1
		case 3:
			underline.1 += 1
		default: ()
		}
		setLabel(underline.0,j: underline.1,s: label[underline.0][underline.1].text!)		
	}
	
    func setMatrix(_ matrix:Matrix,underline:(Int,Int)! = nil){
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
        maxWidth = [CGFloat](repeating: 0,count: ncol)
        for i in 0..<nrow{
            label.append([])
            for j in 0..<ncol{
				label[i].append(UILabel())
                label[i][j].numberOfLines = 1
				if let (underlinei,underlinej) = underline{
					if i==underlinei && j==underlinej{
						let underlineString = NSMutableAttributedString(string: matrix.matrix[i][j].toString(matrix.decimal[i][j]))
						underlineString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleSingle.rawValue, range: NSRange(location: 0, length: (matrix.matrix[i][j].toString(matrix.decimal[i][j])).characters.count))
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
                label[i][0].textColor = UIColor.white
                for j in 1..<ncol{
                    x += xMARGIN + maxWidth[j-1]/2 + maxWidth[j]/2
                    label[i][j].center = CGPoint(x: x, y: y)
                    self.addSubview(label[i][j])
                    label[i][j].textColor = UIColor.white
                }
                y += yMARGIN + maxHeight
            }
        }
	}
	
	func decreaseFont(){
		currentFontSize -= 1
        maxWidth = [CGFloat](repeating: 0,count: label[0].count)
		for i in 0..<label.count{
			for j in 0..<label[0].count{
                label[i][j].font = label[i][j].font.withSize(currentFontSize)
				label[i][j].sizeToFit()
                maxWidth[j] = max(maxWidth[j],label[i][j].frame.width)
			}
		}
		adjustLayout()
	}
    
    class func preconfig()->UIView{
        let view = UIView(frame:CGRect.zero)
        view.backgroundColor = UIColor.white
        return(view)
    }
    
    required init?(coder aDecoder: NSCoder) {

        leftu = matrixTableView.preconfig()
        left = matrixTableView.preconfig()
        leftd = matrixTableView.preconfig()
        rightu = matrixTableView.preconfig()
        right = matrixTableView.preconfig()
        rightd = matrixTableView.preconfig()
        super.init(coder: aDecoder)
        widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 80)
        heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 80)
        self.addConstraints([widthConstraint,heightConstraint])
        
        self.addSubview(left)
        left.translatesAutoresizingMaskIntoConstraints = true
        left.frame = CGRect(x: 0, y: 0, width: borderWidth, height: self.frame.height)
        left.autoresizingMask = [.flexibleRightMargin , .flexibleHeight]
        
        self.addSubview(leftu)
        leftu.translatesAutoresizingMaskIntoConstraints = true
        leftu.frame = CGRect(x: 0, y: 0, width: borderLength, height: borderWidth)
        leftu.autoresizingMask = [.flexibleBottomMargin , .flexibleRightMargin]
        
        self.addSubview(leftd)
        leftd.translatesAutoresizingMaskIntoConstraints = true
        leftd.frame = CGRect(x: 0, y: self.frame.height-borderWidth, width: borderLength, height: borderWidth)
        leftd.autoresizingMask = [.flexibleTopMargin , .flexibleRightMargin]
        
        self.addSubview(right)
        right.translatesAutoresizingMaskIntoConstraints = true
        right.frame = CGRect(x: self.frame.width-borderWidth, y: 0, width: borderWidth, height: self.frame.height)
        right.autoresizingMask = [.flexibleHeight , .flexibleLeftMargin]
        
        self.addSubview(rightu)
        rightu.translatesAutoresizingMaskIntoConstraints = true
        rightu.frame = CGRect(x: self.frame.width-borderLength, y: 0, width: borderLength, height: borderWidth)
        rightu.autoresizingMask = [.flexibleBottomMargin , .flexibleLeftMargin]
        
        self.addSubview(rightd)
        rightd.translatesAutoresizingMaskIntoConstraints = true
        rightd.frame = CGRect(x: self.frame.width-borderLength, y: self.frame.height-borderWidth, width: borderLength, height: borderWidth)
        rightd.autoresizingMask = [.flexibleLeftMargin , .flexibleTopMargin]
        
    }
    
    override init(frame: CGRect) {
        leftu = matrixTableView.preconfig()
        left = matrixTableView.preconfig()
        leftd = matrixTableView.preconfig()
        rightu = matrixTableView.preconfig()
        right = matrixTableView.preconfig()
        rightd = matrixTableView.preconfig()
        super.init(frame: frame)
		widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: frame.width)
        heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: frame.height)
        self.addConstraints([widthConstraint,heightConstraint])
        
        self.addSubview(left)
        left.translatesAutoresizingMaskIntoConstraints = true
        left.frame = CGRect(x: 0, y: 0, width: borderWidth, height: self.frame.height)
        left.autoresizingMask = [.flexibleRightMargin , .flexibleHeight]
        
        self.addSubview(leftu)
        leftu.translatesAutoresizingMaskIntoConstraints = true
        leftu.frame = CGRect(x: 0, y: 0, width: borderLength, height: borderWidth)
        leftu.autoresizingMask = [.flexibleBottomMargin , .flexibleRightMargin]
        
        self.addSubview(leftd)
        leftd.translatesAutoresizingMaskIntoConstraints = true
        leftd.frame = CGRect(x: 0, y: self.frame.height-borderWidth, width: borderLength, height: borderWidth)
        leftd.autoresizingMask = [.flexibleTopMargin , .flexibleRightMargin]
        
        self.addSubview(right)
        right.translatesAutoresizingMaskIntoConstraints = true
        right.frame = CGRect(x: self.frame.width-borderWidth, y: 0, width: borderWidth, height: self.frame.height)
        right.autoresizingMask = [.flexibleHeight , .flexibleLeftMargin]
        
        self.addSubview(rightu)
        rightu.translatesAutoresizingMaskIntoConstraints = true
        rightu.frame = CGRect(x: self.frame.width-borderLength, y: 0, width: borderLength, height: borderWidth)
        rightu.autoresizingMask = [.flexibleBottomMargin , .flexibleLeftMargin]
        
        self.addSubview(rightd)
        rightd.translatesAutoresizingMaskIntoConstraints = true
        rightd.frame = CGRect(x: self.frame.width-borderLength, y: self.frame.height-borderWidth, width: borderLength, height: borderWidth)
        rightd.autoresizingMask = [.flexibleLeftMargin , .flexibleTopMargin]
    }
    
}
