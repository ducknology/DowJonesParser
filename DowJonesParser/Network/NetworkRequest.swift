//
//  NetworkRequest.swift
//  DowJonesParser
//
//  Created by Billy Chan on 14/6/2018.
//  Copyright © 2018 Billy Chan. All rights reserved.
//

import UIKit

struct NetworkRequest {
	private let urlSession = URLSession(configuration: .default)
	private var dataTask: URLSessionDataTask? = nil
	let url: URL
	
	init(linkString: String) {
		self.init(url: URL(string: linkString)!)
	}
	
	init(url: URL) {
		self.url = url
	}
	
	mutating func run(completion: @escaping (_: Data?, _: Error?) -> Void) {
		self.dataTask = self.urlSession.dataTask(with: self.url, completionHandler: { (data, _, error) in
			guard let validData = data,
				error == nil else
			{
				DispatchQueue.main.async {
					completion(nil, error)
				}
				return
			}
			
			DispatchQueue.main.async {
				completion(validData, nil)
			}
		})
		
		self.dataTask?.resume()
	}
	
	mutating func cancel() {
		self.dataTask?.cancel()
	}
}
