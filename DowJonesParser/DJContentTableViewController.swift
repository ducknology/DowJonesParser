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
	
	var url: URL? {
		didSet {
			guard self.isViewLoaded else {
				return
			}
			
			self.loadFeeds()
		}
	}

	private var feedRepository: FeedRepository? {
		didSet {
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}
	
	private var dataTask: URLSessionDataTask?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.loadFeeds()
    }
	
	deinit {
		self.dataTask?.cancel()
	}
	
	private func loadFeeds() {
		guard let validUrl = self.url else {
			return
		}
		
		let navController = self.djNavContorller
		
		let urlSession = URLSession(configuration: .default)
		
		navController?.showLoading()
		self.dataTask = urlSession.dataTask(with: validUrl, completionHandler: {[weak self] (data, _, error) in
			defer {
				navController?.hideLoading()
			}
			
			guard let strongSelf = self else {
				return
			}
			
			defer {
				strongSelf.dataTask = nil
			}
			
			guard error == nil,
				let validData = data else
			{
				return
			}
			
			strongSelf.feedRepository = FeedRepository(data: validData)
		})
		
		self.dataTask?.resume()
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

