//
//  BookViewController.swift
//  HackerBooks
//
//  Created by Francisco Gómez Pino on 6/7/16.
//  Copyright © 2016 Francisco Gómez Pino. All rights reserved.
//

import UIKit

let BookIsFavoriteDidChangeNotification = "Book isFavorite property did change"

class BookViewController: UIViewController {
    
    //--------------------------------------
    // MARK: - Properties
    //--------------------------------------
    
    var model : Book
    
    //--------------------------------------
    // MARK: - IBOutlets
    //--------------------------------------
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var authorsLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var readBookButton: UIButton!
    
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "Book Info"
        
        self.edgesForExtendedLayout = .None
        self.backgroundImageView.clipsToBounds = true
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        self.backgroundImageView.addSubview(blurEffectView)
        
        self.favoriteButton.layer.cornerRadius = 5
        
        self.readBookButton.layer.cornerRadius = 5
        self.readBookButton.center = CGPointMake(self.readBookButton.center.x, self.readBookButton.center.y + 50)
        self.readBookButton.alpha = 0
        
        UIView.animateWithDuration(1.5, animations: {
            () -> Void in
            self.readBookButton.center = CGPointMake(self.readBookButton.center.x, self.readBookButton.center.y - 50)
            self.readBookButton.alpha = 1
        })
        
        self.syncModelWithView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //--------------------------------------
    // MARK: - IBActions
    //--------------------------------------
    
    @IBAction func displayBook(sender: AnyObject) {
        
        let simplePDFviewController = SimplePDFViewController(model: model)
        
        self.navigationController?.pushViewController(simplePDFviewController, animated: true)
        
    }
    
    @IBAction func changeFavoriteStatus(sender: AnyObject) {
        self.model.setIsFavorite(!self.model.isFavorite)
        syncModelWithFavoriteButton()
        
        let nc = NSNotificationCenter.defaultCenter()
        let notif = NSNotification(name: BookIsFavoriteDidChangeNotification, object: self, userInfo: nil)
        nc.postNotification(notif)
        
    }
    
    //--------------------------------------
    // MARK: - Syncing
    //--------------------------------------
    
    func syncModelWithView(){
        
        if let title:String = self.model.title {
            self.titleLabel.text = title
        } else {
            self.titleLabel.text = "Book Untitled"
        }
        
        if let authorsString:String = self.model.authorsString {
            self.authorsLabel.text = "Written by \(authorsString)"
        } else {
            self.authorsLabel.text = "Authorless"
        }
        
        if let tagsString:String = self.model.tagsString {
            self.tagsLabel.text = "Tagged as: \(tagsString)"
        } else {
            self.tagsLabel.text = "No tagged"
        }
        
        self.imageActivityIndicator.startAnimating()
        self.model.getImageInBackground {
            (image) in
            
            self.imageActivityIndicator.stopAnimating()
            
            if let image:UIImage = image {
                self.imageView.image = image
            } else {
                self.imageView.image = UIImage(named: "NoImage")
            }
            
        }
        
        self.syncModelWithFavoriteButton()
        
    }
    
    func syncModelWithFavoriteButton() {
        
        if model.isFavorite {
            self.favoriteButton.backgroundColor = UIColor(red:0.81, green:0.00, blue:0.00, alpha:1.0)
            self.favoriteButton.setTitle(" Remove from your favorites ", forState: .Normal)
        } else {
            self.favoriteButton.backgroundColor = UIColor(red:0.07, green:0.81, blue:0.00, alpha:1.0)
            self.favoriteButton.setTitle(" Add to your favorites ", forState: .Normal)
        }
        
    }
    
}

//--------------------------------------
// MARK: - Extensions
//--------------------------------------

extension BookViewController: LibraryTableViewControllerDelegate{
    
    func libraryTableViewController(vc: LibraryTableViewController, didSelectBook book: Book) {
        
        self.model = book
        
        self.syncModelWithView()
        
    }
    
}
