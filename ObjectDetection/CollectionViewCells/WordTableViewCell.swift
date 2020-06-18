//
//  WordTableViewCell.swift
//  ObjectDetection
//
//  Created by Andrés Aguilar on 6/16/20.
//  Copyright © 2020 Y Media Labs. All rights reserved.
//

import UIKit

class WordTableViewCell: UITableViewCell {

    @IBOutlet weak var wordLabel: UILabel!
    var word = Word()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
