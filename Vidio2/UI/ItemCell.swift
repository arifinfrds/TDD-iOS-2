//
//  ItemCell.swift
//  Vidio2
//
//  Created by Arifin Firdaus on 25/11/22.
//

import UIKit

final class ItemCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .red
    }

}
