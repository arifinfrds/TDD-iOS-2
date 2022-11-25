//
//  SectionCell.swift
//  Vidio2
//
//  Created by Arifin Firdaus on 25/11/22.
//

import UIKit

final class SectionCell: UICollectionViewCell {

    @IBOutlet weak private var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    var items = [Item]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupCollectionView()
    }
    
    private func setupCollectionView() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        let nib = UINib(nibName: "ItemCell", bundle: .main)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "ItemCell")
    }
}

extension SectionCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCell
        cell.titleLabel.text = item.title
        return cell
    }
}

extension SectionCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 200, height: 100)
    }
}
