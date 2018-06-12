//
//  DJNavigationController.swift
//  DowJonesParser
//
//  Created by Billy Chan on 12/6/2018.
//  Copyright © 2018 Billy Chan. All rights reserved.
//

import UIKit

class DJNavigationController: UINavigationController {
	
	private let loadingSegue = "showLoading"
	private var loading = 0 {
		willSet {
			if self.loading == 0 && newValue == 1 {
				self.present(self.loadingViewController, animated: false, completion: nil)
			}
			else if self.loading == 1 && newValue == 0 {
				self.loadingViewController.dismiss(animated: false, completion: nil)
			}
		}
	}
	
	private let loadingViewController = { () -> DJLoadingViewController in
		let viewController = DJLoadingViewController.createFromStoryboard()
		viewController.modalPresentationStyle = .overCurrentContext
		return viewController
	}()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	func showLoading() {
		DispatchQueue.main.async { [weak self] in
			self?.loading += 1
		}
	}
	
	func hideLoading() {
		DispatchQueue.main.async { [weak self] in
			if self?.loading ?? 0 > 0 {
				self?.loading -= 1
			}
		}
	}
}
