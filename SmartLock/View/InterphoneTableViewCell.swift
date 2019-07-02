//
//  InterphoneTableViewCell.swift
//  SmartLock
//
//  Created by Salvatore Capuozzo on 01/07/2019.
//  Copyright © 2019 Salvatore Capuozzo. All rights reserved.
//

import UIKit

class InterphoneTableViewCell: UITableViewCell {
    
    var nameLabel = UILabel()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nameLabel = UILabel(frame: CGRect(x: 8, y: 8, width: self.frame.width*2, height: self.frame.height))
        nameLabel.center = CGPoint(x: self.frame.width*3/2, y: self.frame.height*3/2)
        nameLabel.font = UIFont.systemFont(ofSize: self.frame.height)
        nameLabel.textColor = .black
        self.addSubview(nameLabel)
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
