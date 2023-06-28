//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Filosuf on 30.01.2023.
//

import UIKit
import YandexMobileMetrica

final class TrackersViewController: UIViewController {

    // MARK: - Properties
    private var coordinator: TrackersFlowCoordinatorProtocol
    private let trackerStore: TrackerStoreProtocol
    private let recordStore: TrackerRecordStoreProtocol
    private let statsStorage: SettingsStorageProtocol
    private var currentDate = Date()
    private var textOfSearchQuery = ""

    private lazy var searchBar: UISearchController = {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        return searchController
    }()

    private let infoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "star")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "trackersEmptyPlaceholderTitle".localized
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .Custom.blackDay
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var trackerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: TrackersCollectionViewCell.identifier)
        collectionView.register(HeaderCollectionView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionView.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(handleDatePicker), for: .valueChanged)
        return datePicker
    }()

    private let filterButton: UIButton = {
        let button = UIButton()
        button.setTitle("filters".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.layer.cornerRadius = 16
        button.backgroundColor = .Custom.blue
        button.addTarget(self, action: #selector(filter), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Initialiser
    init(coordinator: TrackersFlowCoordinatorProtocol, trackerStore: TrackerStoreProtocol, recordStore: TrackerRecordStoreProtocol, statsStorage: SettingsStorageProtocol) {
        self.coordinator = coordinator
        self.trackerStore = trackerStore
        self.recordStore = recordStore
        self.statsStorage = statsStorage
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setBar()
        layout()
        setupPlaceholder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("event open")
        let params : [AnyHashable : Any] = ["event": "open", "screen": "main"]
        YMMYandexMetrica.reportEvent("EVENT", parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("event close")
        let params : [AnyHashable : Any] = ["event": "close", "screen": "main"]
        YMMYandexMetrica.reportEvent("EVENT", parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }

    // MARK: - Methods
    private func setBar() {
        navigationItem.searchController = searchBar
        navigationItem.title = "trackers".localized
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addTracker))
        navigationItem.leftBarButtonItem?.tintColor = .Custom.blackDay
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }

    private func setupPlaceholder() {
        if trackerStore.trackersIsEmpty() {
            trackerCollectionView.isHidden = true
            infoLabel.isHidden = false
            infoImage.isHidden = false
            infoImage.image = UIImage(named: "star")
            infoLabel.text = "trackersEmptyPlaceholderTitle".localized
        } else if trackerStore.numberOfSections == 0 {
            trackerCollectionView.isHidden = true
            infoLabel.isHidden = false
            infoImage.isHidden = false
            infoImage.image = UIImage(named: "findError")
            infoLabel.text = "trackersNoFindPlaceholderTitle".localized
        } else {
            trackerCollectionView.isHidden = false
            infoLabel.isHidden = true
            infoImage.isHidden = true
        }
    }

    @objc private func filter() {
        coordinator.showFilters(delegate: self)
        print("event click, item filter")
        let params : [AnyHashable : Any] = ["event": "click", "screen": "main", "item": "filter"]
        YMMYandexMetrica.reportEvent("EVENT", parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }

    @objc private func addTracker() {
        coordinator.showNewTracker()
        print("event click, item add_track")
        let params : [AnyHashable : Any] = ["event": "click", "screen": "main", "item": "add_track"]
        YMMYandexMetrica.reportEvent("EVENT", parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }

    @objc private func handleDatePicker(_ datePicker: UIDatePicker) {
        currentDate = datePicker.date
        self.dismiss(animated: false, completion: nil)
        updateVisibleCategories()
        setupPlaceholder()
    }

    private func makePreview(indexPath: IndexPath) -> UIViewController {
        let viewController = UIViewController()
        let preview = TrackersSubviewCell(frame: CGRect(x: 0, y: 0, width: 167, height: 90))
        viewController.view = preview
        if let tracker = trackerStore.object(at: indexPath) {
            preview.setupView(tracker: tracker)
            viewController.view.backgroundColor = tracker.color
        }
        viewController.preferredContentSize = preview.frame.size

        return viewController
    }

    private func layout() {
        [infoImage,
         infoLabel,
         trackerCollectionView,
         filterButton].forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            infoImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            infoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoImage.heightAnchor.constraint(equalToConstant: 80),
            infoImage.widthAnchor.constraint(equalToConstant: 80),

            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),

            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoLabel.topAnchor.constraint(equalTo: infoImage.bottomAnchor, constant: 8),
            infoLabel.heightAnchor.constraint(equalToConstant: 18),

            trackerCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackerCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackerCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trackerCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func updateVisibleCategories() {
        let dayNumberOfWeek = currentDate.dayNumberOfWeek()
        let dayOfWeek = DayOfWeek(number: dayNumberOfWeek)?.rawValue
        trackerStore.updatePredicate(searchText: textOfSearchQuery, dayOfWeek: dayOfWeek)
        trackerCollectionView.reloadData()
    }

    private func changeRecord(tracker: Tracker) {
        guard let records = recordStore.fetchRecords(trackerId: tracker.id) else { return }

        let isTodayCompleted = records.contains(where: { $0.date == currentDate })
        let numberOfCompletedTrackers = statsStorage.numberOfCompletedTrackers
        if isTodayCompleted {
            recordStore.deleteRecord(trackerId: tracker.id, date: currentDate)
            statsStorage.updateCompletedTrackers(numberOfCompletedTrackers - 1)
        } else {
            recordStore.addRecord(trackerId: tracker.id, date: currentDate)
            statsStorage.updateCompletedTrackers(numberOfCompletedTrackers + 1)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return trackerStore.numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        trackerStore.numberOfRowsInSection(section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.identifier, for: indexPath) as! TrackersCollectionViewCell
        let tracker = trackerStore.object(at: indexPath)
        let records = trackerStore.records(at: indexPath)
        guard let tracker = tracker  else { return UICollectionViewCell()}
        let numberOfCompleted = records.count
        let isTodayCompleted = records.contains(where: { $0.date == currentDate })
        cell.setupCell(tracker: tracker, numberOfMarks: numberOfCompleted, isTodayCompleted: isTodayCompleted, isHabit: !tracker.schedule.isEmpty)
        cell.buttonAction = { [weak self] in
            self?.changeRecord(tracker: tracker)
            collectionView.reloadItems(at: [indexPath])
            print("event click, item track")
            let params : [AnyHashable : Any] = ["event": "click", "screen": "main", "item": "track"]
            YMMYandexMetrica.reportEvent("EVENT", parameters: params, onFailure: { error in
                print("REPORT ERROR: %@", error.localizedDescription)
            })
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderCollectionView.identifier, for: indexPath) as? HeaderCollectionView  else { return UICollectionReusableView() }
        let title = trackerStore.sectionTitle(for: indexPath.section)
        view.setTitle(title)
        return view
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    private var lineSpacing: CGFloat { return 16 }
    private var interitemSpacing: CGFloat { return 9 }
    private var sideInset: CGFloat { return 16 }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - interitemSpacing - 2 * sideInset) / 2
        return CGSize(width: width, height: 148)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)

        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        lineSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        interitemSpacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: sideInset, bottom: sideInset, right: sideInset)
    }
}

//MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            let customView = self.makePreview(indexPath: indexPath)
            return customView
        }) { actions in
            let pinTitle = self.trackerIsPinned(indexPath: indexPath) ? "unpinned".localized : "pin".localized
                return UIMenu(children: [
                    UIAction(title: pinTitle) { [weak self] _ in
                        self?.trackerPinned(indexPath: indexPath)
                    },
                    UIAction(title: "edit".localized) { [weak self] _ in
                        self?.editTacker(indexPath: indexPath)
                        print("event click, item edit")
                        let params : [AnyHashable : Any] = ["event": "click", "screen": "main", "item": "edit"]
                        YMMYandexMetrica.reportEvent("EVENT", parameters: params, onFailure: { error in
                            print("REPORT ERROR: %@", error.localizedDescription)
                        })
                    },
                    UIAction(title: "delete".localized, attributes: .destructive) { [weak self] _ in
                        self?.deleteTracker(indexPath: indexPath)
                        print("event click, item delete")
                        let params : [AnyHashable : Any] = ["event": "click", "screen": "main", "item": "delete"]
                        YMMYandexMetrica.reportEvent("EVENT", parameters: params, onFailure: { error in
                            print("REPORT ERROR: %@", error.localizedDescription)
                        })
                    },
                ])
            }
        }

    private func trackerIsPinned(indexPath: IndexPath) -> Bool {
        guard let tracker = trackerStore.object(at: indexPath) else { return false}
        return tracker.isPinned
    }

    private func trackerPinned(indexPath: IndexPath) {
        guard let tracker = trackerStore.object(at: indexPath) else { return }

        let category = trackerStore.sectionTitle(for: indexPath.section)
        let categoryBeforePinned = tracker.isPinned ? nil : category
        let newCategory = tracker.isPinned ? tracker.categoryBeforePinned ?? "" : "pinned"
        let newTracker = Tracker(id: tracker.id, name: tracker.name, color: tracker.color, emoji: tracker.emoji, schedule: tracker.schedule, isPinned: !tracker.isPinned, categoryBeforePinned: categoryBeforePinned)
        trackerStore.saveTracker(newTracker, titleCategory: newCategory)
    }

    private func editTacker(indexPath: IndexPath) {
        guard let schedule = trackerStore.object(at: indexPath)?.schedule else { return }
        let trackerStyle: TrackerStyle = schedule.isEmpty ? .editEvent : .editHabit
        coordinator.showTrackerSettings(trackerStyle: trackerStyle, indexPathEditTracker: indexPath)
    }

    private func deleteTracker(indexPath: IndexPath) {
        coordinator.showDeleteAlert { [weak self] in
            self?.trackerStore.deleteTracker(at: indexPath)
        }
    }
}

//MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        textOfSearchQuery = searchController.searchBar.text ?? ""
        updateVisibleCategories()
        setupPlaceholder()
    }
}

//MARK: - TrackerStoreDelegate
extension TrackersViewController: TrackerStoreDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        updateVisibleCategories()
        setupPlaceholder()
        trackerCollectionView.reloadData()
    }
}

extension TrackersViewController {

    func makeRatePreview(indexPath: IndexPath) -> UIViewController {
        let viewController = UIViewController()
        let preview = TrackersSubviewCell(frame: CGRect(x: 0, y: 0, width: 167, height: 90))
        viewController.view = preview
        if let tracker = trackerStore.object(at: indexPath) {
            preview.setupView(tracker: tracker)
            viewController.view.backgroundColor = tracker.color
        }
        viewController.preferredContentSize = preview.frame.size

        return viewController
    }
}

extension TrackersViewController: FiltersViewControllerDelegate {
    func filterDidUpdate() {
        trackerCollectionView.reloadData()
    }
}
