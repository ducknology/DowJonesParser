//
//  DJViewController.swift
//  DowJonesParser
//
//  Created by Billy Chan on 12/6/2018.
//  Copyright © 2018 Billy Chan. All rights reserved.
//

import UIKit

extension UIViewController {
	var djNavContorller: DJNavigationController? {
		return self.navigationController as? DJNavigationController
	}
	
	func showSimpleAlert(_ desc: String) {
		let alertController = UIAlertController(title: "", message: desc, preferredStyle: .alert)
		let action = UIAlertAction(title: "OK", style: .default) { _ in
			alertController.dismiss(animated: true, completion: nil)
		}
		alertController.addAction(action)
		self.present(alertController, animated: true, completion: nil)
	}
}
