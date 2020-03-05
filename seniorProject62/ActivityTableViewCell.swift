//
//  ActivityTableViewCell.swift
//  seniorProject62
//
//  Created by Praewey Spokkokkak on 24/1/2563 BE.
//  Copyright © 2563 Praewey Spokkokkak. All rights reserved.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var readView: UIView!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentCellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        contentCellView.layer.cornerRadius = 10
        contentCellView.clipsToBounds = true
    }

}
