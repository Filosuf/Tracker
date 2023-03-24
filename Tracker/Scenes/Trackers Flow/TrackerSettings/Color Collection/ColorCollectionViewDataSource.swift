//
//  ColorCollectionViewDataSource.swift
//  Tracker
//
//  Created by Filosuf on 03.03.2023.
//

import UIKit

final class ColorCollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private let colorsName: [String]
    var tapAction: ((String) -> Void)?

    init(colors: [String]) {
        self.colorsName = colors
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        colorsName.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.identifier, for: indexPath) as! ColorCollectionViewCell
        let colorName = colorsName[indexPath.row]
        let color = UIColor(named: colorName)
        cell.setupCell(color: color)
        return cell
    }

    //MARK: - UICollectionViewDelegateFlowLayout
    private var sideInset: CGFloat { return 16}

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tapAction?(colorsName[indexPath.row])
    }
}
