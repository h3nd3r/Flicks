//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Sara Hender on 10/12/16.
//  Copyright © 2016 Sara Hender. All rights reserved.
//
import MBProgressHUD
import UIKit
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var movies: [NSDictionary] = []
    var endpoint: String = "now_playing"
    var totalPages: Int = 2
    var currentPage: Int = 1
    var isMoreDataLoading = false
    var loadingMoreView: InfiniteScrollActivityView?
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x:0, y:tableView.contentSize.height, width:tableView.bounds.size.width, height:InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshControlAction(refreshControl: )), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl!, at: 0)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        loadData(false, refresh: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("Checking if we should load more data")
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                print("set moreDataLoading")
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x:0, y:tableView.contentSize.height, width:tableView.bounds.size.width, height:InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // Code to load more results
                loadData(true, refresh: false)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = movies[indexPath.row]
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
        return cell
        
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl) {
        print("Refresh, calling loadData")
        loadData(false, refresh: true)
    }

    func loadData(_ more: Bool, refresh: Bool) {

        if refresh {
            currentPage = 1
        }
        print("loadData for page \(currentPage), total pages \(totalPages)")        
        if self.currentPage < self.totalPages {
        
            if !more {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
            let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)&page=\(currentPage)")
            print(url)
            let request = NSURLRequest(url: url! as URL)
            let session = URLSession(
                configuration: URLSessionConfiguration.default,
                delegate:nil,
                delegateQueue:OperationQueue.main
            )
        
        
            let task:URLSessionDataTask = session.dataTask(with: request as URLRequest,
                                                       completionHandler: { (dataOrNil, responseOrNil, errorOrNil) in
                                                        if let data = dataOrNil {
                                                            if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? [String:AnyObject] {
                                                                self.totalPages = responseDictionary["total_pages"] as! Int
                                                                if refresh {
                                                                    self.movies = responseDictionary["results"] as! [NSDictionary]
                                                                } else {
                                                                    self.movies += responseDictionary["results"] as! [NSDictionary]
                                                                }
                                                                
                                                                self.errorView.isHidden = true
                                                                self.tableView.reloadData()
                                                                if self.currentPage < self.totalPages {
                                                                    self.currentPage += 1
                                                                }
                                                                
                                                                if more {
                                                                    // Update flag
                                                                    self.isMoreDataLoading = false
                                                                    
                                                                    // Stop the loading indicator
                                                                    self.loadingMoreView!.stopAnimating()
                                                                }
                                                                else if refresh {
                                                                    self.refreshControl?.endRefreshing()
                                                                }
                                                            }
                                                        } else {
                                                            self.errorView.isHidden = false
                                                        }
                if !more {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                                                        
                                                        
        });
        task.resume()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated:true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies[(indexPath?.row)!]
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movies = movie
    }
 

}

class InfiniteScrollActivityView: UIView {
    var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    static let defaultHeight:CGFloat = 60.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupActivityIndicator()
    }
    
    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        setupActivityIndicator()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicatorView.center = CGPoint(x:self.bounds.size.width/2, y:self.bounds.size.height/2)
    }
    
    func setupActivityIndicator() {
        activityIndicatorView.activityIndicatorViewStyle = .gray
        activityIndicatorView.hidesWhenStopped = true
        self.addSubview(activityIndicatorView)
    }
    
    func stopAnimating() {
        self.activityIndicatorView.stopAnimating()
        self.isHidden = true
    }
    
    func startAnimating() {
        self.isHidden = false
        self.activityIndicatorView.startAnimating()
    }
}
