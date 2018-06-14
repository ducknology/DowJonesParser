//
//  DJMainTableViewController.swift
//  DowJonesParser
//
//  Created by Billy Chan on 12/6/2018.
//  Copyright © 2018 Billy Chan. All rights reserved.
//

import UIKit
import SafariServices

class DJMainTableViewController: UITableViewController {

	private typealias NameLinkPair = (name: String, link: String)
	private var nameLinkPairs: [NameLinkPair]? {
		didSet {
			guard self.isViewLoaded,
				let validPairs = self.nameLinkPairs else
			{
				return
			}
			
			self.djNavContorller?.showLoading()
			
			validPairs.forEach{nameValuePair in
				self.loadFeeds(linkString: nameValuePair.link, completed: {[unowned self] repository in
					self.categoryRepositoryMap[nameValuePair.name] = repository
					
					if self.categoryRepositoryMap.count == self.nameLinkPairs?.count ?? 0 {
						self.djNavContorller?.hideLoading()
						self.tableView.reloadData()
					}
				})
			}
		}
	}
	
	private var categoryRepositoryMap = [String: FeedRepository]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.title = ""
		
		/*
[NSLayoutConstraint constraintWithItem:contentView
attribute:NSLayoutAttributeCenterX
relatedBy:NSLayoutRelationEqual
toItem:self.view
attribute:NSLayoutAttributeCenterX
multiplier:1.f constant:0.f]];*/
		
		let navTitleImageView = UIImageView(image: UIImage(named: "NavLogo"))
		navTitleImageView.contentMode = .scaleAspectFit
		navTitleImageView.frame = CGRect(x: 0, y: 4, width: 98, height: 24)
		
		let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 98, height: 32))
		containerView.addSubview(navTitleImageView)
		
		self.navigationItem.titleView = containerView

		self.extractLinksFromWeb()
    }
	
	private func extractLinksFromWeb() {
		self.djNavContorller?.showLoading()
		
		let urlString = "http://www.wsj.com/public/page/rss_news_and_feeds.html"
		let url = URL(string: urlString)!
		let urlSession = URLSession(configuration: .default)
		let dataTask = urlSession.dataTask(with: url) {[weak self] (data, _, error) in
			guard error == nil,
				let validData = data,
				let allHtml = String(data: validData, encoding: .utf8) else
			{
				self?.djNavContorller?.hideLoading()
				return
			}
			
			//	Grab the target rss div from html
			let pattern = "(?<=<div class=\"rssSectionList\">)((.|\n)*?)(?=</div>)"
			let divResult = (try! NSRegularExpression(pattern: pattern))
				.matches(in: allHtml, options: [], range: NSRange(allHtml.startIndex..., in: allHtml)).first!
			let rssSectionList = String(allHtml[Range(divResult.range, in: allHtml)!])
			
			//	Grab the name and links within the DIV chunk
			//	Group 3 (.+?.xml): get content of href
			//	Group 4 (.*?): get innertext of <a> tag
			let namePattern = "(?<=<a)(.+?href=\"(.+?.xml)\".+?>)(.*?)(?=<\\/a>)"
			let nameResult = (try! NSRegularExpression(pattern: namePattern))
				.matches(in: rssSectionList, options: [], range: NSRange(rssSectionList.startIndex..., in: rssSectionList))
			
			//	Map the data into more readable tuple
			let allNames = nameResult.compactMap{(result) -> NameLinkPair? in
				guard result.numberOfRanges == 4 else {
					return nil
				}
				
				return NameLinkPair(name: String(rssSectionList[Range(result.range(at: 3), in: rssSectionList)!]),
									link: { () -> String in
										var link = String(rssSectionList[Range(result.range(at: 2), in: rssSectionList)!])
										let urlComponents = URLComponents(string: link)
										if urlComponents?.scheme == nil {
											link = "https://www.wsj.com\(link)"
										}
										return link
				}())
			}
			
			DispatchQueue.main.async {
				self?.nameLinkPairs = allNames
				self?.djNavContorller?.hideLoading()
			}
		}
		
		dataTask.resume()
	}

	private func loadFeeds(linkString: String, completed: @escaping (FeedRepository) -> Void) {
		guard let validUrl = URL(string: linkString) else {
			return
		}
		
		let urlSession = URLSession(configuration: .default)
		let dataTask = urlSession.dataTask(with: validUrl, completionHandler: {(data, _, error) in
			guard error == nil,
				let validData = data else
			{
				return
			}
			
			DispatchQueue.main.async {
				completed(FeedRepository(data: validData))
			}
		})
		
		dataTask.resume()
	}
	
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.nameLinkPairs?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as? DJCategoryTableViewCell,
			let nameLinkPairs = self.nameLinkPairs else {
			return tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
		}
		
		let nameLinkPair = nameLinkPairs[indexPath.row]
		
		cell.delegate			= self
		cell.categoryName.text	= nameLinkPair.name
		cell.titleLabel.text	= ""
		cell.feedDesc.text		= ""
		cell.feedImage.image	= nil
		
		switch indexPath.row {
		case 0:
			cell.topConstraint.constant = 0
		default:
			cell.topConstraint.constant = 8
		}
		
		guard let repository = self.categoryRepositoryMap[nameLinkPair.name],
			let feedItem = repository.feedItems.first else
		{
			return cell
		}
		
		cell.repository			= repository
		cell.titleLabel.text	= feedItem.title
		cell.feedDesc.text		= feedItem.feedDesc
		feedItem.requestImage(receiver: { (image, guid) in
			guard cell.titleLabel.text == feedItem.title else {
				return
			}
			
			cell.feedImage.image = image
		})
		
        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? DJCategoryTableViewCell else {
			return
		}
		
		self.performSegue(withIdentifier: "showDetailContent", sender: cell)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case "showDetailContent":
			guard let viewController = segue.destination as? DJContentTableViewController,
				let cell = sender as? DJCategoryTableViewCell,
				let repository = cell.repository else
			{
				super.prepare(for: segue, sender: sender)
				return
			}
			
			viewController.feedRepository = repository
		default:
			super.prepare(for: segue, sender: sender)
		}
	}
}

extension DJMainTableViewController: DJCategoryCellDelegate {
	func cellDidTap(cell: DJCategoryTableViewCell) {
		guard let item = cell.relatedItem else {
			return
		}
		
		let configuration = SFSafariViewController.Configuration()
		let safariViewController = SFSafariViewController(url: item.linkUrl, configuration: configuration)
		safariViewController.preferredControlTintColor	= UIColor.black
		self.present(safariViewController, animated: true, completion: nil)
	}
}

