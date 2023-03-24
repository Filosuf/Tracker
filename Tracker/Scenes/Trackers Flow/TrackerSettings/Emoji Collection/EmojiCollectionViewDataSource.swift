//
//  EmojiCollectionViewDataSource.swift
//  Tracker
//
//  Created by Filosuf on 02.03.2023.
//

import UIKit

final class EmojiCollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private let emojis: [String]
    var tapAction: ((String) -> Void)?

    init(emojis: [String]) {
        self.emojis = emojis
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        emojis.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.identifier, for: indexPath) as! EmojiCollectionViewCell
        let emoji = emojis[indexPath.row]
        cell.setupCell(emoji: emoji)
        return cell
    }


    //MARK: - UICollectionViewDelegateFlowLayout
    private var sideInset: CGFloat { return 16}

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tapAction?(emojis[indexPath.row])
    }
}
