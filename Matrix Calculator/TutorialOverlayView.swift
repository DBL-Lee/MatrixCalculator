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
        self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.label.text = text
        self.label.font = UIFont.systemFont(ofSize: 25.0)
        self.label.textAlignment = .center
        self.label.numberOfLines = 0
        self.label.lineBreakMode = .byWordWrapping
        self.label.textColor = UIColor.white
		self.label.translatesAutoresizingMaskIntoConstraints = false
		
        
    }
    
    override func didMoveToSuperview() {
        addSubview(self.label)
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[label]-0-|", options: .alignAllCenterX, metrics: nil, views: ["label": self.label]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-50-[label]-50-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: ["label": self.label]))

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
