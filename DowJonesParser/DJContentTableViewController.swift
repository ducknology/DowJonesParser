//
//  DJContentTableViewController.swift
//  DowJonesParser
//
//  Created by Billy Chan on 12/6/2018.
//  Copyright © 2018 Billy Chan. All rights reserved.
//

import UIKit
import SafariServices

class DJContentTableViewController: UITableViewController {
	
	var feedRepository: FeedRepository? {
		didSet {
			guard self.isViewLoaded else {
				return
			}
			
			self.tableView.reloadData()
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.tableView.reloadData()
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
		}
		
		cell.targetLink = item.imgUrl

        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let item = self.feedRepository?.feedItems[indexPath.row] else {
			return
		}

		let safariViewController = SFSafariViewController(url: item.linkUrl, configuration: { () -> SFSafariViewController.Configuration in
			let configuration = SFSafariViewController.Configuration()
			configuration.entersReaderIfAvailable = true
			return configuration
		}())
		
		self.navigationController?.pushViewController(safariViewController, animated: true)
	}
}

