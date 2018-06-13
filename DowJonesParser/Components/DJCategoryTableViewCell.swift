//
//  DJCategoryTableViewCell.swift
//  DowJonesParser
//
//  Created by Billy Chan on 12/6/2018.
//  Copyright © 2018 Billy Chan. All rights reserved.
//

import UIKit

protocol DJCategoryCellDelegate: class {
	func cellDidTap(cell: DJCategoryTableViewCell)
}

class DJCategoryTableViewCell: UITableViewCell {
	@IBOutlet weak var titleLabel: DJLabel!
	@IBOutlet weak var feedDesc: DJLabel!
	@IBOutlet weak var feedImage: UIImageView!
	@IBOutlet weak var categoryName: DJLabel!
	
	private var tapGesture: UITapGestureRecognizer?
	
	weak var repository: FeedRepository? {
		didSet {
			self.relatedItem = self.repository?.feedItems.first
		}
	}
	weak var relatedItem: DJRssItem? {
		didSet {
			guard let validItem = self.relatedItem else {
				return
			}
			
			self.titleLabel.text	= validItem.title
			self.feedDesc.text		= validItem.feedDesc
			validItem.requestImage {[weak self] (image, itemId) in
				guard let strongSelf = self,
					strongSelf.relatedItem?.id == itemId else
				{
					return
				}
				
				strongSelf.feedImage.image = image
			}
		}
	}
	weak var delegate: DJCategoryCellDelegate?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapFeed(tapGesture:)))
		self.feedImage.addGestureRecognizer(tapGesture)
		self.tapGesture = tapGesture
	}
	
	@objc func tapFeed(tapGesture: UITapGestureRecognizer!) {
		self.delegate?.cellDidTap(cell: self)
	}
}
