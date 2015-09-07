//
//  TutorialOverlayView.swift
//  Matrix Calculator
//
//  Created by Zichuan Huang on 07/09/2015.
//  Copyright © 2015 Zichuan Huang. All rights reserved.
//

import UIKit

class TutorialOverlayView: UIView {
    let OFFSET:CGFloat = 30
    var label:UILabel!
    init(frame: CGRect,text:String) {

        self.label = UILabel(frame: CGRect(x: 0, y: OFFSET, width: frame.width-2*OFFSET, height: frame.height))
        super.init(frame: frame)
        self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        self.label.text = text
        self.label.font = UIFont.systemFontOfSize(25.0)
        self.label.textAlignment = .Center
        self.label.numberOfLines = 0
        self.label.lineBreakMode = .ByWordWrapping
        self.label.textColor = UIColor.whiteColor()
        self.addSubview(self.label)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
