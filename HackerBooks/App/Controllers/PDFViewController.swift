//
//  PDFViewController.swift
//  HackerBooks
//
//  Created by Francisco Solano Gómez Pino on 08/05/2017.
//  Copyright © 2017 Francisco Solano Gómez Pino. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD

class PDFViewController: UIViewController, UIWebViewDelegate {

	// MARK: - Properties
	
	var model : Book
	private var request:DataRequest?
	private var canceled:Bool = false
	private var progressHUD : MBProgressHUD?
	
	// MARK: - IBOutlets
	
	@IBOutlet weak var PDFWebView: UIWebView!
	
	// MARK: - Initialization
	
	init(model: Book){
		self.model = model
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - UIViewController
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
        // Do any additional setup after loading the view.
		
		// Set delegate to WebView
		self.PDFWebView.delegate = self
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Add observer
		NotificationCenter.default.addObserver(self, selector: #selector(PDFViewController.bookDidChange(notification:)), name: BookDidChangeNotification, object: nil)
		
		self.syncModelWithView()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		// Remove observer
		NotificationCenter.default.removeObserver(self)
		
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	// MARK: - UIWebViewDelegate
	
	func webViewDidStartLoad(_ webView: UIWebView) {
		self.progressHUD?.mode = .indeterminate
		self.progressHUD?.detailsLabel.text = "Loading..."
	}
	
	func webViewDidFinishLoad(_ webView: UIWebView) {
		self.progressHUD?.hide(animated: true)
	}
	
	func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
		if navigationType == .linkClicked || navigationType == .formSubmitted {
			return false
		}
		return true
	}
	
	// MARK: - Syncing
	
	func bookDidChange(notification: Notification)  {
		if let newModel:Book = notification.userInfo?[BookKeyNotification] as? Book {
			if self.model != newModel {
				self.model = newModel
				self.syncModelWithView()
			}
		}
	}
	
	func syncModelWithView(){
		
		// Cancel previus request if exist
		self.request?.cancel()
		self.progressHUD?.hide(animated: true)
		
		// Set title book in navigation item
		if self.model.title.isEmpty {
			self.title = "Book Untitled"
		} else {
			self.title = self.model.title
		}
		
		// Check if PDF url is avaliable
		if let PDFURL = self.model.pdfURL {
			
			// Create & Personalize Progress HUD
			self.progressHUD = MBProgressHUD.showAdded(to: self.PDFWebView, animated: true)
			self.progressHUD?.backgroundView.style = .solidColor
			self.progressHUD?.backgroundView.color = UIColor(white: 0, alpha: 0.25)
			self.progressHUD?.mode = .determinate
			self.progressHUD?.detailsLabel.text = "Downloading book..."
			self.progressHUD?.progress = 0.0

			// Download saving request & with progress
			self.request = Alamofire.request(PDFURL).downloadProgress(closure: {
				(progress:Progress) in
				self.progressHUD?.progress = Float(progress.fractionCompleted)
			}).responseData(completionHandler: {
				(response:DataResponse<Data>) in
				
				switch response.result {
				case .success:
				
					if let data = response.result.value {
						self.PDFWebView.load(data, mimeType: "application/pdf", textEncodingName: "UFT-8", baseURL: PDFURL)
					} else {
						self.navigationController?.popViewController(animated: true)
					}
					
				case .failure(let error):
					if (error as NSError).code != NSURLErrorCancelled {
						displayAlert(target: self, title: "Downloading error", message: error.localizedDescription, completionHandler: {
							self.navigationController?.popViewController(animated: true)
						})
					}
				}

			})
			
		} else {
			
			self.navigationController?.popViewController(animated: true)
			
		}
		
	}
	
}
