//
//  PhotosViewController.swift
//  Tumblr
//
//  Created by Jonathan Grider on 1/10/18.
//  Copyright © 2018 Jonathan Grider. All rights reserved.
//

import UIKit
import AlamofireImage

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

  @IBOutlet weak var tableView: UITableView!
  
  var posts: [[String: Any]] = []
  var alertController: UIAlertController!
  var isMoreDataLoading = false
  var refreshControl: UIRefreshControl!
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "PictureCell", for: indexPath) as! PictureCell
    
    let post = posts[indexPath.section]
    
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
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return posts.count
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
    headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
    
    let profileView = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
    profileView.clipsToBounds = true
    profileView.layer.cornerRadius = 15;
    profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
    profileView.layer.borderWidth = 1;
    
    // Set the avatar
    profileView.af_setImage(withURL: URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/avatar")!)
    headerView.addSubview(profileView)
    
    // Set up the date label
    let photo = posts[section]
    if let timestamp = photo["timestamp"] {
      
      // Set up the date text
      let dateUnformatted = NSDate(timeIntervalSince1970: timestamp as! TimeInterval)
      let formatter = DateFormatter()
      formatter.dateFormat = "MMM dd, YYYY, hh:mm a"
      let dateFormatted = formatter.string(from: dateUnformatted as Date)
      
      // Set the label
      let label = UILabel(frame: CGRect(x: 50, y: 10, width: 200, height: 30))
      label.clipsToBounds = true
      label.layer.cornerRadius = 15;
      label.text = "\(dateFormatted)"
      
      headerView.addSubview(label)
    }
    
    return headerView
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 50
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    // Set up alert controller
    self.alertController = UIAlertController(title: "Cannot get Photos", message: "The Internet connection appears to be offline.", preferredStyle: .alert)
    // create an OK action & add it
    let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
      self.getPictures()
    }
    self.alertController.addAction(OKAction)
    
    // Set up refresh pull
    self.refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector (PhotosViewController.didRefresh(_:)), for: .valueChanged)
    tableView.insertSubview(refreshControl, at: 0)
    tableView.dataSource = self
    tableView.delegate = self
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
          // Stop the refresh controller
          self.refreshControl.endRefreshing()
        }
        
      }
    }
    task.resume()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destination = segue.destination as! PhotoDetailsViewController
    let cell = sender as! PictureCell
    let indexPath = tableView.indexPath(for: cell)!
    let post = posts[indexPath.section]
    
    // Get raw post caption
    let rawCaption = post["caption"] as! String
    
    // Remove HTML tags
    let removeTags = rawCaption.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    
    // Replace Tumblr's left double quote tags
    let leftDoubleQuotes = removeTags.replacingOccurrences(of: "&ldquo;", with: "\"", options: .regularExpression, range: nil)
    
    // Replace Tumblr's left double quote tags
    let rightDoubleQuotes = leftDoubleQuotes.replacingOccurrences(of: "&rdquo;", with: "\"", options: .regularExpression, range: nil)
    
    // Replace Tumblr's single quote tags
    let singleQuotes = rightDoubleQuotes.replacingOccurrences(of: "&rsquo;", with: "\'", options: .regularExpression, range: nil)
    
    // Send post data to destination view
    destination.postDescription = singleQuotes
    destination.image = cell.tumblrImageView.image
  }
  
  // Remove gray selection effect
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  // Actually refresh images
  @objc func didRefresh(_ refreshControl: UIRefreshControl) {
    getPictures()
  }
  

  
  
  
}
