//
//  ProductCell.swift
//  Shop(IAP)
//
//  Created by Даниил Смирнов on 29.08.2018.
//  Copyright © 2018 Даниил Смирнов. All rights reserved.
//

import UIKit
import StoreKit

class ProductCell: UITableViewCell {
	
	static var identifier: String {
		return "ProductCell"
	}
	
	let priceFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.formatterBehavior = .behavior10_4
		formatter.numberStyle = .currency
		return formatter
	}()
	
	let buyButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitleColor(UIColor.blue, for: .normal)
		button.setTitle("Buy", for: .normal)
		button.sizeToFit()
		return button
	}()
	
	var buyButtonHandler: ((_ product: SKProduct) -> Void)?
	
	var product: SKProduct? {
		didSet {
			guard let product = product else { return }
			
			textLabel?.text = product.localizedTitle
			
			if Product.store.isProductPurchased(product.productIdentifier) {
				accessoryType = .checkmark
				accessoryView = nil
				detailTextLabel?.text = ""
			} else if IAPManager.canMakePayments() {
				priceFormatter.locale = product.priceLocale
				detailTextLabel?.text = priceFormatter.string(from: product.price)
				buyButton.addTarget(self, action: #selector(buyButtonPressed), for: .touchUpInside)
				accessoryView = buyButton
				accessoryType = .none
			} else {
				detailTextLabel?.text = "Not available"
			}
		}
	}
	
	@objc func buyButtonPressed() {
		
		guard let productToBuy = product else {
			print("product is nil")
			return
		}
		buyButtonHandler?(productToBuy)
	}
}
