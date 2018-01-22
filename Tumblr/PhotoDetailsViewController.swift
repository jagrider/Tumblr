//
//  PhotoDetailsViewController.swift
//  Tumblr
//
//  Created by Jonathan Grider on 1/17/18.
//  Copyright © 2018 Jonathan Grider. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {
  
  @IBOutlet weak var postImageView: UIImageView!
  @IBOutlet weak var postText: UITextView!
  
  var image: UIImage?
  var postDescription: String = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.postImageView.image = self.image
    self.postText.text = self.postDescription
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  
  
}
