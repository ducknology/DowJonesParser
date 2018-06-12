//
//  DJRssItem.swift
//  DowJonesParser
//
//  Created by Billy Chan on 12/6/2018.
//  Copyright © 2018 Billy Chan. All rights reserved.
//

import UIKit

class DJRssItem {
	typealias ImageReceiver = (_: UIImage?) -> Void
	
	var title				= ""
	var feedDesc			= ""
	var link				= ""
	var imgLink: String?	= ""
	
	private var mediaReady = [ImageReceiver]()
	private var imgUrl: URL? {
		guard let validImgLink = self.imgLink else {
			return nil
		}
		return URL(string: validImgLink)!
	}
	
	private var image: UIImage?
	private var imageError = false
	
	func requestImage(receiver: @escaping ImageReceiver) {
		guard !self.imageError else {
			receiver(nil)
			return
		}
		
		if self.image != nil {
			receiver(self.image)
			return
		}
		
		self.retrieveImage { image in
			DispatchQueue.main.async {[unowned self] in
				defer {
					self.mediaReady.forEach{$0(self.image)}
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
			receiver(nil)
			return
		}
		
		let urlSession = URLSession(configuration: .default)
		let dataTask = urlSession.dataTask(with: validImageUrl) {(data, _, _) in
			guard let validData = data else {
				receiver(nil)
				return
			}
			
			guard let image = UIImage(data: validData) else {
				receiver(nil)
				return
			}
			
			receiver(image)
		}
		dataTask.resume()
	}
}
