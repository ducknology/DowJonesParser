//
//  DJRssItem.swift
//  DowJonesParser
//
//  Created by Billy Chan on 12/6/2018.
//  Copyright © 2018 Billy Chan. All rights reserved.
//

import UIKit

class DJRssItem {
	typealias ImageReceiver = (_: UIImage?, _: String) -> Void
	
	var id					= ""
	var title				= ""
	var feedDesc			= ""
	var link				= ""
	var pubDate				= ""
	var imgLink: String?	= nil
	
	private var mediaReady = [ImageReceiver]()
	private var image: UIImage?
	private var imageError = false
	
	var imgUrl: URL? {
		guard let validImgLink = self.imgLink else {
			return nil
		}
		return URL(string: validImgLink)!
	}

	var linkUrl: URL {
		return URL(string: self.link)!
	}
	
	func requestImage(receiver: @escaping ImageReceiver) {
		guard !self.imageError else {
			receiver(nil, self.id)
			return
		}
		
		if self.image != nil {
			receiver(self.image, self.id)
			return
		}
		
		self.mediaReady.append(receiver)
		self.retrieveImage { image, _ in
			DispatchQueue.main.async {[unowned self] in
				defer {
					self.mediaReady.forEach{$0(self.image, self.id)}
					self.mediaReady.removeAll()
				}
				
				guard let validImage = image else {
					self.imageError = true
					return
				}
				
				self.image = validImage
			}
		}
	}
	
	private func retrieveImage(receiver: @escaping ImageReceiver) {
		guard let validImageUrl = self.imgUrl else {
			receiver(nil, self.id)
			return
		}
		
		let urlSession = URLSession(configuration: .default)
		let dataTask = urlSession.dataTask(with: validImageUrl) {[unowned self](data, _, _) in
			guard let validData = data else {
				receiver(nil, self.id)
				return
			}
			
			guard let image = UIImage(data: validData) else {
				receiver(nil, self.id)
				return
			}
			
			receiver(image, self.id)
		}
		dataTask.resume()
	}
}
