//
//  ViewController.swift
//  Vidio2
//
//  Created by Arifin Firdaus on 25/11/22.
//

import Combine
import UIKit

final class ViewController: UIViewController {
    
    @IBOutlet weak private(set) var collectionView: UICollectionView!
    
    private(set) var sections = [ContentsViewModel.Section]()
    private var subscriptions = Set<AnyCancellable>()
    
    var viewModel: ContentsViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        
        onLoad()
        
        setupCollectionView()
    }
    
    @discardableResult
    func onLoad() -> Task<Void, Never> {
        return Task {
            await self.viewModel?.onLoad()
        }
    }
    
    private func setupCollectionView() {
        let nib = UINib(nibName: "SectionCell", bundle: .main)
        collectionView.register(nib, forCellWithReuseIdentifier: "SectionCell")
        
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderView")
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func bindViewModel() {
        viewModel?.state
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .initial:
                    break
                case .error:
                    self.showErrorView()
                case let .dataUpdated(sections):
                    self.sections = sections
                    self.collectionView.reloadData()
                case .loading:
                    self.showLoadingView()
                }
            })
            .store(in: &subscriptions)
    }
    
    private func showLoadingView() {
        // show custom loading view somehow
    }
    
    private func showErrorView() {
        // show custom error view somehow
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = sections[indexPath.section]
        
        switch section {
        case let .portraitItem(items):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SectionCell", for: indexPath) as! SectionCell
            cell.titleLabel.text = "Portrait Section"
            cell.items = items
            return cell
            
        case let .landscapeItem(items):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SectionCell", for: indexPath) as! SectionCell
            cell.titleLabel.text = "Landscape Section"
            cell.items = items
            return cell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

}

extension ViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: self.collectionView.frame.width, height: 150)
    }
}
