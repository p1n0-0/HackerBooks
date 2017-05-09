//
//  utils.swift
//  HackerBooks
//
//  Created by Francisco Solano Gómez Pino on 08/05/2017.
//  Copyright © 2017 Francisco Solano Gómez Pino. All rights reserved.
//

import Foundation
import UIKit

// Show alert with UIAlertController
func displayAlert(target:UIViewController?, title:String, message:String?, completionHandler: (()->())?){
	
	let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
	
	alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
		(action) -> Void in
		alert.dismiss(animated: true, completion: nil)
		completionHandler?()
	}))
	
	target?.present(alert, animated: true, completion: nil)
	
}

// Split string by , caracter
func stringToArray(string: String) -> [String] {
	var array:[String] = []
	for each in string.components(separatedBy: ", ") {
		array.append(each.trimmingCharacters(in: .whitespacesAndNewlines))
	}
	return array
}
