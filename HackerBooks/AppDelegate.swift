//
//  AppDelegate.swift
//  HackerBooks
//
//  Created by Francisco Gómez Pino on 6/7/16.
//  Copyright © 2016 Francisco Gómez Pino. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        do {
            
            let json = try load(fromData: getResourceWithCache(fromURL: NSURL(string: "https://t.co/K9ziV0z3SJ")!)!)
            
            var books : [Book] = []
            
            for dict in json {
                do {
                    let book = try decode(book: dict)
                    books.append(book)
                } catch {
                    print("Error al procesar \(dict)")
                }
            }
            
            let library = Library(books: books)
            
            // ViewControllers
            let libraryController = LibraryTableViewController(model: library)
            let bookController:BookViewController = BookViewController(model: library.firstBook!)
            
            // NavigationControllers
            let libraryNav = UINavigationController(rootViewController: libraryController)
            let bookNav:UINavigationController = UINavigationController(rootViewController: bookController)
            
            // SplitController
            let splitController = UISplitViewController()
            
            // Set views in SplitController
            splitController.viewControllers = [libraryNav, bookNav]
            
            // Show back button to library in portrait ipad view
            bookNav.navigationItem.leftItemsSupplementBackButton = true
            bookController.navigationItem.leftBarButtonItem = splitController.displayModeButtonItem()
            
            // Set delegates
            splitController.delegate = libraryController
            libraryController.delegate = bookController
            
            // Window
            window = UIWindow(frame:UIScreen.mainScreen().bounds)
            
            // Set rootViewController And show view
            window?.rootViewController = splitController
            window?.makeKeyAndVisible()
            
            return true
        } catch {
            fatalError("Error while loading JSON")
        }
        
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}
