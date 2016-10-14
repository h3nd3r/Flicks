//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Sara Hender on 10/12/16.
//  Copyright © 2016 Sara Hender. All rights reserved.
//

import UIKit
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var movies: [NSDictionary]?
    var endpoint: String = "now_playing"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(url: url! as URL)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task:URLSessionDataTask = session.dataTask(with: request as URLRequest,
                    completionHandler: { (dataOrNil, responseOrNil, errorOrNil) in
                                if let data = dataOrNil {
                                    if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                                            NSLog("response: \(responseDictionary)")
                                        
                                            self.movies = responseDictionary["results"] as! [NSDictionary]
                                            self.tableView.reloadData()
                                    }
                                }
                        
        });
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        if let posterPath = movie["poster_path"] as? String {
            let baseUrl = "https://image.tmdb.org/t/p/w500"
            let imageUrl = URL(string: baseUrl + posterPath)
            cell.posterView.setImageWith(imageUrl!)
        }
        else {
            // No poster image. Can either set to nil (no image) or a default movie poster image
            // that you include as an asset
            cell.posterView.image = nil
        }
        
        print("row \(indexPath.row)")
        return cell
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies?[(indexPath?.row)!]
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movies = movie
    }
 

}
