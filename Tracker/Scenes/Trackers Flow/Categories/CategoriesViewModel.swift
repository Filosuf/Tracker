//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Filosuf on 25.03.2023.
//

import Foundation

struct CellViewModel {
    let title: String
    let isSetCheckmark: Bool
}

final class CategoriesViewModel {

    // MARK: - Properties
    private let trackerCategoryStore: TrackerCategoryStoreProtocol
    private let coordinator: SettingsFlowCoordinator
    private let delegate: CategoriesViewControllerProtocol

    @Observable private(set) var currentCategory: TrackerCategory? 
//    @Observable private(set) var placeholderIsShown = true
    @Observable private(set) var numberOfCategories = 0

    // MARK: - Initialiser
    init(categoryStore: TrackerCategoryStoreProtocol, coordinator: SettingsFlowCoordinator, current category: TrackerCategory?, delegate: CategoriesViewControllerProtocol) {
        self.trackerCategoryStore = categoryStore
        self.coordinator = coordinator
        self.currentCategory = category
        self.delegate = delegate
        numberOfCategories = numberOfRowsInSection(0)
    }

    // MARK: - Methods
    func showCategorySettings() {
        coordinator.showCategorySettings(indexPathEditCategory: nil)
    }

    func selectCategory(with indexPath: IndexPath) {
        guard let categorySelected = trackerCategoryStore.object(at: indexPath) else { return }
        currentCategory = categorySelected
        delegate.categoriesDidUpdate(selected: categorySelected)
        coordinator.pop()
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        trackerCategoryStore.numberOfRowsInSection(section)
    }

    func fetchViewModelForCell(with indexPath: IndexPath) -> CellViewModel? {
        guard let category = trackerCategoryStore.object(at: indexPath) else { return nil }
        let isSetCheckmark = category == currentCategory
        let cellViewModel = CellViewModel(title: category.title, isSetCheckmark: isSetCheckmark)
        return cellViewModel
    }
}

extension CategoriesViewModel: TrackerCategoryStoreDelegate {
    func didUpdate(_ update: TrackerCategoryStoreUpdate) {
        numberOfCategories = numberOfRowsInSection(0)
    }
}
