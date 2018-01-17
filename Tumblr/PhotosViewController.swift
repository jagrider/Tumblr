//
//  PhotosViewController.swift
//  Tumblr
//
//  Created by Jonathan Grider on 1/10/18.
//  Copyright © 2018 Jonathan Grider. All rights reserved.
//

import UIKit
import AlamofireImage

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  var posts: [[String: Any]] = []
  var alertController: UIAlertController!
  @IBOutlet weak var tableView: UITableView!
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return posts.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "PictureCell", for: indexPath) as! PictureCell
    
    let post = posts[indexPath.row]
    
    if let photos = post["photos"] as? [[String: Any]] {
      // photos is NOT nil, we can use it!
      
      // Get the photo & attributes
      let photo = photos[0]
      let originalSize = photo["original_size"] as! [String: Any]
      let urlString = originalSize["url"] as! String
      let url = URL(string: urlString)
      
      // Set the cell's image to the photo we retrieved
      cell.tumblrImageView.af_setImage(withURL: url!)
      
    }
    return cell
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    // Set up alert controller
    self.alertController = UIAlertController(title: "Cannot get Photos", message: "The Internet connection appears to be offline.", preferredStyle: .alert)
    // create an OK action
    let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
      self.getPictures()
    }
    self.alertController.addAction(OKAction)
    
    // Set up refresh pull
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector (PhotosViewController.didRefresh(_:)), for: .valueChanged)
    tableView.insertSubview(refreshControl, at: 0)
    tableView.dataSource = self
    getPictures()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func getPictures() {
    
    // Network request snippet
    let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")!
    let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
    session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
    let task = session.dataTask(with: url) { (data, response, error) in
      if let error = error {
        print(error.localizedDescription)
        
        // Show error
        self.present(self.alertController, animated: true) { }
        
      } else if let data = data,
        let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
        
        // Debug --> Prints the JSON dictionary
        // print(dataDictionary)
        
        // Get the dictionary from the response key
        let responseDictionary = dataDictionary["response"] as! [String: Any]
        
        // Store the returned array of dictionaries in our posts property
        self.posts = responseDictionary["posts"] as! [[String: Any]]
        
        // Reload the table view
        self.tableView.reloadData()
        
      }
    }
    task.resume()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let cell = sender as! PictureCell
    let destination = segue.destination as! PhotoDetailsViewController
    destination.image = cell.tumblrImageView.image
    
  }
  
  // Remove gray selection effect
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  // Actually refresh images
  @objc func didRefresh(_ refreshControl: UIRefreshControl) {
    getPictures()
    refreshControl.endRefreshing()
  }
  
}
