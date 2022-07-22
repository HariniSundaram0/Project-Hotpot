//
//  SongTableViewCell.swift
//  Project-Hotpot
//
//  Created by Harini Sundaram on 7/21/22.
//

import UIKit

class SongTableViewCell: UITableViewCell {
    @IBOutlet weak var songTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
