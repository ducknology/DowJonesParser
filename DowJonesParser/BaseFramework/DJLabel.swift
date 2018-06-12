//
//  DJLabel.swift
//  DowJonesParser
//
//  Created by Billy Chan on 13/6/2018.
//  Copyright © 2018 Billy Chan. All rights reserved.
//

import UIKit

@IBDesignable class DJLabel: UILabel {
	
	enum FontWeight: String {
		case Bold		= "BodoniSvtyTwoOSITCTT-Bold"
		case Regular	= "BodoniSvtyTwoOSITCTT-Book"
	}
	
	@IBInspectable var fontSize: CGFloat = UIFont.systemFontSize {
		didSet {
			self.setupFont()
		}
	}
	
	@IBInspectable var bold: Bool = true {
		didSet {
			self.fontWeight = self.bold ? FontWeight.Bold : FontWeight.Regular
		}
	}
	
	private var fontWeight = FontWeight.Bold {
		didSet {
			self.setupFont()
		}
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.setupFont()
	}
	
	private func setupFont() {
		self.font = UIFont(name: self.fontWeight.rawValue, size: self.fontSize)
	}
	
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		
		self.setupFont()
	}
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
