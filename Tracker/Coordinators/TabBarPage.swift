//
//  TabBarPage.swift
//  Tracker
//
//  Created by Filosuf on 15.02.2023.
//

import UIKit

enum TabBarPage: CaseIterable {
    case trackers
    case stats

    var pageTitle: String {
        switch self {
        case .trackers:
            return "trackers".localized
        case .stats:
            return "stats".localized
        }
    }

    var image: UIImage? {
        switch self {
        case .trackers:
            return UIImage(systemName: "record.circle.fill")
        case .stats:
            return UIImage(systemName: "hare.fill")
        }
    }
}
