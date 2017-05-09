//
//  AppDelegate.swift
//  HackerBooks
//
//  Created by Francisco Solano Gómez Pino on 08/05/2017.
//  Copyright © 2017 Francisco Solano Gómez Pino. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		// Initialize window
		window = UIWindow(frame: UIScreen.main.bounds)
		
		// Define library View Controller & Navigation Controller
		let libraryVC = LibraryTableViewController(model: nil)
		let libraryNC = UINavigationController(rootViewController: libraryVC)
		
		if let helveticaNeueThin:UIFont = UIFont(name: "HelveticaNeue-Thin", size: 20) {
			libraryNC.navigationBar.titleTextAttributes = [ NSFontAttributeName: helveticaNeueThin]
		}
		
		if (UIDevice.current.userInterfaceIdiom == .pad) {
		
			// Define Navigation Controllers
			let BookVC = BookViewController(model: Book(id:"", title: "", authors: [], tags: [], imageURL: nil, pdfURL: nil, image: nil))
			let BookNC = UINavigationController(rootViewController: BookVC)
			
			// Navigation bar customization to Navigation Controllers
			if let helveticaNeueThin:UIFont = UIFont(name: "HelveticaNeue-Thin", size: 20) {
				BookNC.navigationBar.titleTextAttributes = [ NSFontAttributeName: helveticaNeueThin]
			}
			
			// SplitController
			let splitController = UISplitViewController()
			
			// Set views in SplitController
			splitController.viewControllers = [libraryNC, BookNC]
		
			// Show back button to library in portrait ipad view
			BookNC.navigationItem.leftItemsSupplementBackButton = true
			BookVC.navigationItem.leftBarButtonItem = splitController.displayModeButtonItem
			
			// Set delegates
			splitController.delegate = libraryVC
			libraryVC.delegate = BookVC
			
			// Set Root View Controller
			window?.rootViewController = splitController
			
		} else {
			
			// Set Root View Controller
			window?.rootViewController = libraryNC
			
		}
		
		// Show window
		window?.makeKeyAndVisible()
		
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}

