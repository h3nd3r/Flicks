//
//  DetailViewController.swift
//  Flicks
//
//  Created by Sara Hender on 10/14/16.
//  Copyright © 2016 Sara Hender. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    
    var movies: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width,
                                        height: infoView.frame.origin.y + infoView.frame.size.height)
        titleLabel.text = movies["title"] as? String
        overviewLabel.text = movies["overview"] as? String
        overviewLabel.sizeToFit()
        
        if let posterPath = movies["poster_path"] as? String {
            let baseUrl = "https://image.tmdb.org/t/p/w500"
            let imageUrl = URL(string: baseUrl + posterPath)
            posterView.setImageWith(imageUrl!)
        }
        else {
            // No poster image. Can either set to nil (no image) or a default movie poster image
            // that you include as an asset
            posterView.image = nil
        }
        
        print(movies)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
    }
    */

}
