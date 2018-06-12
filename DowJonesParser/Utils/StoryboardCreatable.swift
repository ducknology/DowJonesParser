//
//  StoryboardCreatable.swift
//  DowJonesParser
//
//  Created by Billy Chan on 12/6/2018.
//  Copyright © 2018 Billy Chan. All rights reserved.
//

import UIKit

protocol StoryboardCreatable: class {
	static var storyboardId: String {get}
	static var viewControllerId: String {get}
	
	static func createFromStoryboard() -> Self
}

extension StoryboardCreatable where Self: UIViewController{
	static func createFromStoryboard() -> Self {
		let storyboard = UIStoryboard(name: Self.storyboardId, bundle: nil)
		let viewController = storyboard.instantiateViewController(withIdentifier: Self.viewControllerId)
		
		return viewController as! Self
	}
}
