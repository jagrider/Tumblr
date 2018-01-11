//
//  PictureCell.swift
//  Tumblr
//
//  Created by Jonathan Grider on 1/10/18.
//  Copyright © 2018 Jonathan Grider. All rights reserved.
//

import UIKit

class PictureCell: UITableViewCell {

  @IBOutlet weak var tumblrImageView: UIImageView!
  
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
