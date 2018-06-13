//
//  FeedRepository.swift
//  DowJonesParser
//
//  Created by Billy Chan on 12/6/2018.
//  Copyright © 2018 Billy Chan. All rights reserved.
//

import UIKit

class FeedRepository: NSObject {
	private let xmlParser: XMLParser!
	private(set) var feedItems = [DJRssItem]()
	
	private var processingItem: DJRssItem? = nil
	private var processingInnerText = ""
	
	init(data: Data) {
		self.xmlParser = XMLParser(data: data)
		
		super.init()
		
		self.xmlParser.delegate = self
		self.xmlParser.parse()
	}
}

extension FeedRepository: XMLParserDelegate {
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		if elementName.lowercased() == "item" && self.processingItem == nil {
			self.processingItem = DJRssItem()
			return
		}
		
		guard let currentItem = self.processingItem else {
			return
		}
		
		switch elementName {
		case "media:content":
			guard attributeDict["medium"]?.lowercased() == "image" else {
				break
			}
			
			currentItem.imgLink = attributeDict["url"]
		default:
			break
		}
	}
	
	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		
		let popedString = NSString(string: self.processingInnerText
			.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)) as String
		
		self.processingInnerText = ""

		if elementName.lowercased() == "item" && self.processingItem != nil {
			guard let validItem = self.processingItem else {
				return
			}
			
			self.feedItems.append(validItem)
			self.processingItem	= nil
			return
		}
		
		guard let currentItem = self.processingItem else {
			return
		}
		
		switch elementName.lowercased() {
		case "title":
			currentItem.title		= popedString
		case "link":
			currentItem.link		= popedString
		case "description":
			currentItem.feedDesc	= popedString
		case "guid":
			currentItem.id			= popedString
		case "pubdate":
			currentItem.pubDate		= popedString
		default:
			break
		}
	}
	
	func parser(_ parser: XMLParser, foundCharacters string: String) {
		guard let _ = self.processingItem else {
			return
		}
		
		self.processingInnerText.append(string)
	}
}
