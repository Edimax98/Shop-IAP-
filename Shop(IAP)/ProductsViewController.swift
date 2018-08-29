//
//  ViewController.swift
//  Shop(IAP)
//
//  Created by Даниил Смирнов on 29.08.2018.
//  Copyright © 2018 Даниил Смирнов. All rights reserved.
//

import StoreKit
import UIKit

class ProductsViewController: UITableViewController {

	var products = [SKProduct]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Shop"
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(reload), for: .valueChanged)
		
		let restoreButton = UIBarButtonItem(title: "Restore", style: .plain, target: self, action: #selector(restoreButtonPressed))
		navigationItem.rightBarButtonItem = restoreButton
	}
	
	@objc func reload() {
		products = []
		
		tableView.reloadData()
		
		Product.store.fetchProducts { [weak self] success, products in
			guard let unwrappedSelf = self else {
				print("instance is nil")
				return
			}
			
			if success {
				unwrappedSelf.products = products!
				unwrappedSelf.tableView.reloadData()
			}
			unwrappedSelf.refreshControl?.endRefreshing()
		}
	}
	
	@objc func restoreButtonPressed() {
		Product.store.restorePurchases()
	}
}

extension ProductsViewController {
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return products.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductCell.identifier, for: indexPath) as? ProductCell else {
			print("Could not deque cell with identifier - \(ProductCell.identifier)")
			return UITableViewCell()
		}
		
		let product = products[indexPath.row]
		
		cell.product = product
		cell.buyButtonHandler = { product in
			Product.store.buyProduct(product)
		}
		
		return cell
	}
}

