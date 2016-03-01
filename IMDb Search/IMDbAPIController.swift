//
//  IMDbAPIController.swift
//  IMDb Search
//
//  Created by Francisco Ernesto Teixeira on 2/27/16.
//  Copyright © 2016 Francisco Ernesto Teixeira. All rights reserved.
//

import UIKit

protocol IMDbControllerDelegate {
    
    func setAllControlsVisibility(show: Bool)
    func setFormControlsVisibility(show: Bool)
    func setActivityIndicatorVisibility(show: Bool)
    func didFinishIMDBbSearch(result: Dictionary<String, String>)
    
}

class IMDbAPIController {
    
    var delegate : IMDbControllerDelegate?
    
    init(delegate: IMDbControllerDelegate?) {
        
        self.delegate = delegate
        
    }
    
    func searchIMDb(forContent: String) {
        
        self.delegate!.setActivityIndicatorVisibility(true)
        
        let spacelessString = forContent.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLQueryAllowedCharacterSet())
        
        let urlPath = NSURL(string: "http://www.omdbapi.com/?t=\(spacelessString!)&plot=short&tomatoes=true&r=json")
        
        let session = NSURLSession.sharedSession()
        
        self.delegate!.setAllControlsVisibility(false)
        
        let task = session.dataTaskWithURL(urlPath!, completionHandler: {
            
            (data, response, error) -> Void in
            
            if ((error) != nil) {
                
                print(error!.localizedDescription)
                
            }
            
            
            if let apiDelegate = self.delegate {
                
                let jsonResult : Dictionary<String, String>
                
                do {
                    
                    jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<String, String>
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        apiDelegate.didFinishIMDBbSearch(jsonResult)
                        
                    }
                    
                } catch {
                    self.delegate!.setActivityIndicatorVisibility(false)
                    
                    print("Fetch failed: \((error as NSError).localizedDescription)")
                }
                
            }
            
        })
        
        task.resume()
    }
    
}
