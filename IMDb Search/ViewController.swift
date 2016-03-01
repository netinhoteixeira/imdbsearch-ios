//
//  ViewController.swift
//  IMDb Search
//
//  Created by Francisco Ernesto Teixeira on 2/26/16.
//  Copyright © 2016 Francisco Ernesto Teixeira. All rights reserved.
//

import UIKit

class ViewController: UIViewController, IMDbControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet var titleLabel        : UILabel!
    @IBOutlet var subtitleLabel     : UILabel!
    @IBOutlet var tomatoLabel       : UILabel!
    @IBOutlet var releasedLabel     : UILabel!
    @IBOutlet var ratingLabel       : UILabel!
    @IBOutlet var plotLabel         : UILabel!
    @IBOutlet var posterImageView   : UIImageView!
    @IBOutlet var activityIndicator : UIActivityIndicatorView!
    @IBOutlet var imbdSearchBar     : UISearchBar!
    @IBOutlet var headerView        : UIView!
    
    lazy var apiController          : IMDbAPIController = IMDbAPIController(delegate: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "userTappedInView:")
        self.view.addGestureRecognizer(tapGesture)
        
        self.setAllControlsVisibility(false)
        self.formatLabels(true)
        
        self.headerView.backgroundColor = UIColor(red: 0.988, green: 0.725, blue: 0.200, alpha: 1)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setAllControlsVisibility(show: Bool) {
        
        activityIndicator.hidden    = !show
        titleLabel.hidden           = !show
        subtitleLabel.hidden        = !show
        tomatoLabel.hidden          = !show
        releasedLabel.hidden        = !show
        ratingLabel.hidden          = !show
        plotLabel.hidden            = !show
        posterImageView.hidden      = !show
        
    }
    
    func setFormControlsVisibility(show: Bool) {
        
        titleLabel.hidden       = !show
        subtitleLabel.hidden    = !show
        tomatoLabel.hidden      = !show
        releasedLabel.hidden    = !show
        ratingLabel.hidden      = !show
        plotLabel.hidden        = !show
        posterImageView.hidden  = !show
        
    }
    
    func setActivityIndicatorVisibility(show: Bool) {
        
        activityIndicator.hidden = !show
        
        if (show) {
            
            activityIndicator.startAnimating()
            
        } else {
            
            activityIndicator.stopAnimating()
            
        }
        
    }
    
    func didFinishIMDBbSearch(result: Dictionary<String, String>) {
        
        self.formatLabels(false)
        
        if let foundTitle = result["Title"] {
            
            parseTitleFromSubtitle(foundTitle)
            
        }
        
        if let foundTomato = result["tomatoMeter"] {
            
            self.tomatoLabel.text       = (foundTomato != "N/A") ?
                foundTomato + "%" : ""
            
        }
        
        if let foundReleased = result["Released"] {
            
            self.releasedLabel.text     = (foundReleased != "N/A") ?
                "Released: " + foundReleased : ""
            
        }
        
        if let foundRated = result["Rated"] {
            
            self.ratingLabel.text     = (foundRated != "N/A") ?
                "Rated: " + foundRated : ""
            
        }
        
        if let foundPlot = result["Plot"] {
            
            self.plotLabel.text     = (foundPlot != "N/A") ?
                foundPlot : ""
            
        }
        
        if let foundPosterUrl = result["Poster"] {
            
            self.formatImageFromPath(foundPosterUrl)
            
        }
        
        self.setAllControlsVisibility(true)
        self.setActivityIndicatorVisibility(false)
        
    }
    
    func formatLabels(firstLaunch: Bool) {
        
        let labelsArray : [UILabel] = [self.titleLabel, self.subtitleLabel, self.tomatoLabel, self.releasedLabel, self.ratingLabel, self.plotLabel]
        
        if (firstLaunch) {
            
            for label in labelsArray {
                
                label.text = ""
                
            }
            
        }
        
        for label in labelsArray {
            
            label.textAlignment = .Center
            
            switch (label) {
                
            case self.titleLabel:
                label.font = UIFont(name: "Avenir Next", size: 24)
                
            case self.subtitleLabel:
                label.font = UIFont(name: "Avenir Next", size: 14)
                
            case self.tomatoLabel:
                label.font = UIFont(name: "AvenirNext-UltraLight", size: 48)
                label.textColor = UIColor(red: 0.984, green: 0.256, blue: 0.184, alpha: 1)
                
            case self.releasedLabel, self.ratingLabel:
                label.font = UIFont(name: "Avenir Next", size: 12)
                
            case self.plotLabel:
                label.font = UIFont(name: "Avenir Next", size: 18)
                
            default:
                label.font = UIFont(name: "Avenir Next", size: 14)
                
            }
            
        }
        
    }
    
    func parseTitleFromSubtitle(title: String) {
        
        let index = title.findIndexOf(":")
        
        if let foundIndex = index {
            
            let newTitle            = title[0..<foundIndex]
            let subtitle            = title[(foundIndex + 2)..<title.characters.count]
            
            self.titleLabel.text    = newTitle;
            self.subtitleLabel.text = subtitle
            
        } else {
            
            self.titleLabel.text    = title;
            self.subtitleLabel.text = ""
            
        }
        
    }
    
    func formatImageFromPath(path: String) {
        
        if (path != "N/A") {
            
            let posterUrl                                   = NSURL(string: path)
            
            if let posterImageData = NSData(contentsOfURL: posterUrl!) {
                
                self.posterImageView.layer.cornerRadius     = self.posterImageView.frame.size.width / 2
                self.posterImageView.clipsToBounds          = true
                self.posterImageView.image                  = UIImage(data: posterImageData)
                
                self.blurBackgroundUsingImage(self.posterImageView.image!)
                
            }
            
        }
        
    }
    
    /// Create blur background from image found.
    ///
    /// - Parameters:
    ///     - image: The *poster image* found.
    func blurBackgroundUsingImage(image: UIImage) {
        
        let frame                       = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        
        let imageView                   = UIImageView(frame: frame)
        imageView.image                 = image;
        imageView.contentMode           = .ScaleAspectFill
        
        let blurEffect                  = UIBlurEffect(style: .Light)
        let blurEffectView              = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame            = frame
        
        let transparentView             = UIView(frame: frame)
        transparentView.backgroundColor = UIColor(white: 1.0, alpha: 0.30)
        
        let viewsArray = [imageView, blurEffectView, transparentView]
        
        for index in 0..<viewsArray.count {
            
            if let oldView = self.view.viewWithTag(index + 1) {
                
                oldView.removeFromSuperview()
                
            }
            
            let viewToInsert            = viewsArray[index]
            self.view.insertSubview(viewToInsert, atIndex: index + 1)
            viewToInsert.tag            = index + 1
            
        }
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        if let searchByTitle = searchBar.text {
            
            apiController.searchIMDb(searchByTitle)
            searchBar.resignFirstResponder()
            
        }
        
    }
    
    func userTappedInView(recognizer: UITapGestureRecognizer) {
        
        self.imbdSearchBar.resignFirstResponder()
        
    }
    
}

