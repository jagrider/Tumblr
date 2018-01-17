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
  
  var image: UIImage?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.postImageView.image = self.image
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  
  
}
