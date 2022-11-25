//
//  SectionHeaderView.swift
//  Vidio2
//
//  Created by Arifin Firdaus on 25/11/22.
//

import UIKit

class SectionHeaderView: UICollectionReusableView {
    
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(titleLabel)
        titleLabel.frame = self.frame
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
