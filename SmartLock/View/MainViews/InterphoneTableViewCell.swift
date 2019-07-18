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
        
    }
    
    override func layoutSubviews() {
        nameLabel.frame.size.width = self.frame.width
        nameLabel.frame.size.height = self.frame.height
        nameLabel.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        nameLabel.font = UIFont.systemFont(ofSize: self.frame.height/3)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.addSubview(nameLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
