//
//  DJContentTableViewController.swift
//  DowJonesParser
//
//  Created by Billy Chan on 12/6/2018.
//  Copyright © 2018 Billy Chan. All rights reserved.
//

import UIKit
import SafariServices

protocol DJContentTableViewControllerRefreshDelegate: class {
	func requestRefresh(categoryName: String, completed: @escaping (_: FeedRepository?) -> Void)
}

class DJContentTableViewController: UITableViewController {
	
	var feedRepository: FeedRepository? {
		didSet {
			guard self.isViewLoaded else {
				return
			}
			
			self.tableView.reloadData()
		}
	}
	
	weak var delegate: DJContentTableViewControllerRefreshDelegate?
	var categoryName: String! {
		didSet {
			guard let label = self.navigationItem.titleView as? DJLabel else {
				return
			}
			
			label.text = self.categoryName
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
		refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
		self.refreshControl = refreshControl
		
		let titleLabel = DJLabel()
		titleLabel.fontSize = 18
		titleLabel.awakeFromNib()
		titleLabel.text = self.categoryName
		
		self.navigationItem.titleView = titleLabel

		self.tableView.reloadData()
     }
	
	@objc func refresh(_ sender: Any) {
		guard let delegate = self.delegate else {
			return
		}
		
		delegate.requestRefresh(categoryName: self.categoryName, completed: {[weak self] updatedRepository in
			defer {
				self?.refreshControl?.endRefreshing()
			}
			
			guard let validRepository = updatedRepository else {
				return
			}
			
			self?.feedRepository = validRepository
			
		})
	}
	
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feedRepository?.feedItems.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "shortContentCell", for: indexPath) as? DJContentTableViewCell,
			let item = self.feedRepository?.feedItems[indexPath.row] else
		{
			return tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
		}
		
		cell.titleLabel.text	= item.title
		cell.publishDate.text	= item.pubDate
		cell.feedImage.image	= nil
		
		item.requestImage { image, senderFeedId in
			guard senderFeedId == item.id else {
				return
			}
			
			cell.feedImage.image = image
			if cell.feedImage.image == nil {
				cell.imageWidthConstraint.constant = 0
			}
			else {
				cell.imageWidthConstraint.constant = 80
			}
		}
		
		cell.targetLink = item.imgUrl

        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let item = self.feedRepository?.feedItems[indexPath.row] else {
			return
		}
		
		let safariViewController = SFSafariViewController(url: item.linkUrl, configuration: SFSafariViewController.Configuration())
		safariViewController.preferredControlTintColor	= UIColor.black
		self.present(safariViewController, animated: true, completion: nil)
	}
}

