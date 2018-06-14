//
//  DJContentTableViewCell.swift
//  DowJonesParser
//
//  Created by Billy Chan on 13/6/2018.
//  Copyright © 2018 Billy Chan. All rights reserved.
//

import UIKit

class DJContentTableViewCell: UITableViewCell {
	static let cellName = "shortContentCell"
	
	@IBOutlet weak var titleLabel: DJLabel!
	@IBOutlet weak var publishDate: DJLabel!
	@IBOutlet weak var feedImage: UIImageView!
	@IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
	
	var targetLink: URL?
}
