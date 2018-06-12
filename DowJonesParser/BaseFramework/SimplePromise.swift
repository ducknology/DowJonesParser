//
//  SimplePromis.swift
//  DowJonesParser
//
//  Created by Billy Chan on 12/6/2018.
//  Copyright © 2018 Billy Chan. All rights reserved.
//

import UIKit

struct SimplePromise<T> {
	typealias Body = () -> T?
	typealias Success = (_:T) -> Void
	typealias Failure = (_: Error?) -> Void
	typealias Finally = () -> Void
	
	let body: Body
	let success: Success?
	let failure: Failure?
	let finally: Finally?
	
	func run() {
		let body	= self.body
		let success = self.success
		let failure = self.failure
		let finally	= self.finally
		
		DispatchQueue.global().async {
			defer {
				DispatchQueue.main.async {
					finally?()
				}
			}
			
			if let validResult = body() {
				DispatchQueue.main.async {
					success?(validResult)
				}
			}
			else {
				DispatchQueue.main.async {
					failure?(nil)	//	Support of better handling in future
				}
			}
		}
	}
}
