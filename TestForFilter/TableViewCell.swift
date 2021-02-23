//
//  TableViewCell.swift
//  TestForFilter
//
//  Created by Hartwig Hopfenzitz on 23.02.21.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var Name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
