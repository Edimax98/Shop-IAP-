//
//  Products.swift
//  Shop(IAP)
//
//  Created by Даниил Смирнов on 29.08.2018.
//  Copyright © 2018 Даниил Смирнов. All rights reserved.
//

import Foundation

struct Product {
	
	static let productId = "com.shop.myproduct"
	private static let productIds: Set<String> = [Product.productId]
	static let store = IAPManager(productIdentifiers: Product.productIds)

	static func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
		return productIdentifier.components(separatedBy: ".").last
	}
}

