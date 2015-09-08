//
//  TutorialOverlayView.swift
//  Matrix Calculator
//
//  Created by Zichuan Huang on 07/09/2015.
//  Copyright © 2015 Zichuan Huang. All rights reserved.
//

import UIKit

class TutorialOverlayView: UIView {
    var label:UILabel!
    init(frame: CGRect,text:String) {

        self.label = UILabel(frame: CGRect(x: 50, y: 0, width: frame.width-2*50, height: frame.height))
        super.init(frame: frame)
        self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.label.text = text
        self.label.font = UIFont.systemFontOfSize(25.0)
        self.label.textAlignment = .Center
        self.label.numberOfLines = 0
        self.label.lineBreakMode = .ByWordWrapping
        self.label.textColor = UIColor.whiteColor()
		self.label.translatesAutoresizingMaskIntoConstraints = false
		let viewsDict = ["label": label]
		addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-50-[label]-50-|", options: .allZeros, metrics: nil, views: viewsDict))
		addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[label]-0-|", options: .allZeros, metrics: nil, views: viewsDict))
		addSubview(self.label)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
