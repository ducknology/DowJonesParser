//
//  DJContentTableViewCell.swift
//  DowJonesParser
//
//  Created by Billy Chan on 13/6/2018.
//  Copyright © 2018 Billy Chan. All rights reserved.
//

import UIKit

class DJContentTableViewCell: UITableViewCell {
	
	@IBOutlet weak var titleLabel: DJLabel!
	@IBOutlet weak var descLabel: DJLabel!
	@IBOutlet weak var feedImage: UIImageView!
	
	var targetLink: URL?
}