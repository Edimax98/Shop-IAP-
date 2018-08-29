//
//  IAPManager.swift
//  Shop(IAP)
//
//  Created by Даниил Смирнов on 29.08.2018.
//  Copyright © 2018 Даниил Смирнов. All rights reserved.
//

import StoreKit

typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void

class IAPManager: NSObject {
	
	private let productIdentifiers: Set<String>
	private var purchasedProductIdentifiers: Set<String> = []
	private var productsRequest: SKProductsRequest?
	private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?

	init(productIdentifiers: Set<String>) {
		self.productIdentifiers = productIdentifiers
		for productIdentifier in productIdentifiers {
			let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
			if purchased {
				purchasedProductIdentifiers.insert(productIdentifier)
			}
		}
		super.init()
	}
	
	func isProductPurchased(_ productIdentifier: String) -> Bool {
		return purchasedProductIdentifiers.contains(productIdentifier)
	}
	
	static func canMakePayments() -> Bool {
		return SKPaymentQueue.canMakePayments()
	}
	
	func restorePurchases() {
		SKPaymentQueue.default().restoreCompletedTransactions()
	}
}

extension IAPManager {
	
	func fetchProducts(completionHandler: @escaping ProductsRequestCompletionHandler) {
		
		guard let request = productsRequest else {
			print("Product request is nil")
			return
		}
		request.cancel()
		productsRequestCompletionHandler = completionHandler
		request.delegate = self
		request.start()
	}
	
	func buyProduct(_ product: SKProduct) {
		
		let payment = SKPayment(product: product)
		SKPaymentQueue.default().add(payment)
	}
}

// MARK: - SKProductsRequestDelegate
extension IAPManager: SKProductsRequestDelegate {
	
	func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {

		let products = response.products
		productsRequestCompletionHandler?(true, products)
		clearRequestAndHandler()
	}
	
	func request(_ request: SKRequest, didFailWithError error: Error) {
		
		print("Failed to load list of products.")
		print("Error: \(error.localizedDescription)")
		productsRequestCompletionHandler?(false, nil)
		clearRequestAndHandler()
	}
	
	private func clearRequestAndHandler() {
		
		productsRequest = nil
		productsRequestCompletionHandler = nil
	}
}

extension IAPManager: SKPaymentTransactionObserver {
	
	func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		
		for transaction in transactions {
			switch transaction.transactionState {
			case .purchased:
				complete(transaction: transaction)
				break
			case .failed:
				fail(transaction: transaction)
				break
			case .restored:
				restore(transaction: transaction)
				break
			case .deferred:
				break
			case .purchasing:
				break
			}
		}
	}
	
	private func complete(transaction: SKPaymentTransaction) {
		
		deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
		SKPaymentQueue.default().finishTransaction(transaction)
	}
	
	private func restore(transaction: SKPaymentTransaction) {
		
		guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
		
		deliverPurchaseNotificationFor(identifier: productIdentifier)
		SKPaymentQueue.default().finishTransaction(transaction)
	}
	
	private func fail(transaction: SKPaymentTransaction) {

		if let transactionError = transaction.error as NSError?,
			let localizedDescription = transaction.error?.localizedDescription,
			transactionError.code != SKError.paymentCancelled.rawValue {
			print("Transaction Error: \(localizedDescription)")
		}
		SKPaymentQueue.default().finishTransaction(transaction)
	}
	
	private func deliverPurchaseNotificationFor(identifier: String?) {
		
		guard let identifier = identifier else { return }
		
		purchasedProductIdentifiers.insert(identifier)
		UserDefaults.standard.set(true, forKey: identifier)
	}
}









