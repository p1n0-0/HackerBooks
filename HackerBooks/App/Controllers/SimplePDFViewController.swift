//
//  SimplePDFViewController.swift
//  HackerBooks
//
//  Created by Francisco Gómez Pino on 6/7/16.
//  Copyright © 2016 Francisco Gómez Pino. All rights reserved.
//

import UIKit

class SimplePDFViewController: UIViewController, UIWebViewDelegate {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    var model : Book
    
    //--------------------------------------
    // MARK: - IBOutlets
    //--------------------------------------
    
    @IBOutlet weak var browser: UIWebView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    //--------------------------------------
    // MARK: - Initialization
    //--------------------------------------
    
    init(model: Book){
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //--------------------------------------
    // MARK: - UIViewController
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(bookDidChange), name: BookDidChangeNotification, object: nil)
        syncModelWithView()
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //--------------------------------------
    // MARK: - UIWebViewDelegate
    //--------------------------------------
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activityView.stopAnimating()
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if navigationType == .LinkClicked || navigationType == .FormSubmitted {
            return false
        } else {
            return true
        }
        
    }
    
    //--------------------------------------
    // MARK: - Syncing
    //--------------------------------------
    
    func syncModelWithView(){
        
        browser.delegate = self
        
        if let title:String = self.model.title {
            self.navigationItem.title = title
        } else {
            self.navigationItem.title = "Book Untitled"
        }
        
        activityView.startAnimating()
        
        getResourceWithCacheInBackground(fromURL: self.model.pdfURL) {
            (resource:NSData?) in
            
            if let resource:NSData = resource {
                self.browser.loadData(resource, MIMEType: "application/pdf", textEncodingName: "UTF-8", baseURL: self.model.pdfURL)
            } else {
                self.activityView.stopAnimating()
                self.displayAlert("Downloading Error", message: "A problem occurred downloading PDF document.")
            }
            
        }
        
    }
    
    func bookDidChange(notification: NSNotification)  {
        
        model = notification.userInfo![BookKey] as! Book
        syncModelWithView()
        
    }
    
    //--------------------------------------
    // MARK: - Utils
    //--------------------------------------
    
    func displayAlert(title:String, message:String){
        
        // Show alert with UIAlertController
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {
            (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
}
