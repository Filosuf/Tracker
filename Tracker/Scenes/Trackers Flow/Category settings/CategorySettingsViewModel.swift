//
//  CategorySettingsViewModel.swift
//  Tracker
//
//  Created by Filosuf on 28.03.2023.
//

import Foundation

final class CategorySettingsViewModel {
    // MARK: - Properties
    private let coordinator: SettingsFlowCoordinator
    private let trackerCategoryStore: TrackerCategoryStoreProtocol
    private let indexPathEditCategory: IndexPath?

    @Observable private(set) var categoryTitle: String?
    @Observable private(set) var savingIsAvailable = false
    @Observable private(set) var warningText = ""

    private enum Constants {
        static let maxTitleLength = 38
    }

    // MARK: - Initialiser
    init(coordinator: SettingsFlowCoordinator, trackerCategoryStore: TrackerCategoryStoreProtocol, indexPathEditCategory: IndexPath?) {
        self.coordinator = coordinator
        self.trackerCategoryStore = trackerCategoryStore
        self.indexPathEditCategory = indexPathEditCategory
        fetchEditCategory()
    }

    // MARK: - Methods
    func handleSaveButtonTap() {
        guard let newTitle = categoryTitle else { return }
        updateCategories(with: newTitle)
        coordinator.pop()
    }

    private func updateCategories(with title: String){
        if let indexPath = indexPathEditCategory,
           let editCategory = trackerCategoryStore.object(at: indexPath) {
            trackerCategoryStore.updateCategoryTitle(previous: editCategory.title, new: title)
        } else {
            let newTrackerCategory = TrackerCategory(title: title, trackers: [])
            trackerCategoryStore.addCategory(newTrackerCategory)
        }
    }

    func fetchEditCategory() {
        guard let indexPath = indexPathEditCategory,
              let editCategory = trackerCategoryStore.object(at: indexPath) else { return }
        categoryTitle = editCategory.title
        savingIsAvailable = true
    }

    func changeCategoryTitle(title: String) {
        let isNotAvailable = trackerCategoryStore.isDuplicateOfCategory(with: title)

        if !title.isEmpty, title.count <= Constants.maxTitleLength, !isNotAvailable {
            savingIsAvailable = true
        }
        else {
            savingIsAvailable = false
        }

        if isNotAvailable {
            warningText = "categoryWarningDuplicateName".localized
        } else if Array(title).count > Constants.maxTitleLength {
            warningText = "categoryWarningLengthName".localized
        } else {
            warningText = ""
        }

        categoryTitle = title
    }

    }
