//
//  DJMainTableViewController.swift
//  DowJonesParser
//
//  Created by Billy Chan on 12/6/2018.
//  Copyright © 2018 Billy Chan. All rights reserved.
//

import UIKit

class DJMainTableViewController: UITableViewController {

	private typealias NameLinkPair = (name: String, link: String)
	private var nameLinkPairs: [NameLinkPair]? {
		didSet {
			self.tableView.reloadData()
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.title = "WSJ RSS"
		
		self.djNavContorller?.showLoading()
		
		let urlString = "http://www.wsj.com/public/page/rss_news_and_feeds.html"
		let url = URL(string: urlString)!
		let urlSession = URLSession(configuration: .default)
		let dataTask = urlSession.dataTask(with: url) {[weak self] (data, _, error) in
			defer {
				self?.djNavContorller?.hideLoading()
			}
			
			guard error == nil,
				let validData = data,
				let allHtml = String(data: validData, encoding: .utf8) else
			{
				return
			}
			
			//	Grab the target rss div from html
			let pattern = "(?<=<div class=\"rssSectionList\">)((.|\n)*?)(?=</div>)"
			let divResult = (try! NSRegularExpression(pattern: pattern))
				.matches(in: allHtml, options: [], range: NSRange(allHtml.startIndex..., in: allHtml)).first!
			
			//	Grab the name and links within the DIV chunk
			let rssSectionList = String(allHtml[Range(divResult.range, in: allHtml)!])
			
			//	Group 3 (.+?.xml): get content of href
			//	Group 4 (.*?): get innertext of <a> tag
			let namePattern = "(?<=<a)(.+?href=\"(.+?.xml)\".+?>)(.*?)(?=<\\/a>)"
			let nameResult = (try! NSRegularExpression(pattern: namePattern))
				.matches(in: rssSectionList, options: [], range: NSRange(rssSectionList.startIndex..., in: rssSectionList))
			
			//	Map the data into more readable tuple
			let allNames = nameResult.map{result in
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
			}
		}
		
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
		cell.categoryName.text = nameLinkPair.name
		cell.link = nameLinkPair.link

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
				let link = cell.link else
			{
				super.prepare(for: segue, sender: sender)
				return
			}
			
			viewController.url = URL(string: link)!
		default:
			super.prepare(for: segue, sender: sender)
		}
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
