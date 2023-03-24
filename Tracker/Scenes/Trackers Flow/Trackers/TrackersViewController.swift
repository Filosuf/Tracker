//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Filosuf on 30.01.2023.
//

import UIKit

final class TrackersViewController: UIViewController {

    // MARK: - Properties
    private var coordinator: TrackersFlowCoordinator
    private let trackerStore: TrackerStoreProtocol
    private let recordStore: TrackerRecordStoreProtocol
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
        label.text = "Что будем отслеживать?"
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

    // MARK: - Initialiser
    init(coordinator: TrackersFlowCoordinator, trackerStore: TrackerStoreProtocol, recordStore: TrackerRecordStoreProtocol) {
        self.coordinator = coordinator
        self.trackerStore = trackerStore
        self.recordStore = recordStore
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setBar()
        layout()
    }
    
    // MARK: - Methods
    private func setBar() {
        navigationItem.searchController = searchBar
        navigationItem.title = "Трекеры"
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addTracker))
        navigationItem.leftBarButtonItem?.tintColor = .Custom.blackDay
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }

    private func setupPlaceholder() {
        if trackerStore.numberOfSections == 0 {
            trackerCollectionView.isHidden = true
            infoLabel.isHidden = false
            infoImage.isHidden = false
        } else {
            trackerCollectionView.isHidden = false
            infoLabel.isHidden = true
            infoImage.isHidden = true
        }
    }

    @objc private func addTracker() {
        coordinator.showNewTracker()
    }

    @objc func handleDatePicker(_ datePicker: UIDatePicker) {
        currentDate = datePicker.date
        self.dismiss(animated: false, completion: nil)
        updateVisibleCategories()
    }

    private func layout() {
        [infoImage,
         infoLabel,
         trackerCollectionView].forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            infoImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            infoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoImage.heightAnchor.constraint(equalToConstant: 80),
            infoImage.widthAnchor.constraint(equalToConstant: 80),

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
        if isTodayCompleted {
            recordStore.deleteRecord(trackerId: tracker.id, date: currentDate)
        } else {
            recordStore.addRecord(trackerId: tracker.id, date: currentDate)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        trackerStore.numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        trackerStore.numberOfRowsInSection(section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.identifier, for: indexPath) as! TrackersCollectionViewCell
        let (tracker, records) = trackerStore.object(at: indexPath)
        guard let tracker = tracker  else { return UICollectionViewCell()}
        let numberOfCompleted = records.count
        let isTodayCompleted = records.contains(where: { $0.date == currentDate })
        cell.setupCell(tracker: tracker, numberOfMarks: numberOfCompleted, isTodayCompleted: isTodayCompleted, isHabit: !tracker.schedule.isEmpty)
        cell.buttonAction = { [weak self] in
            self?.changeRecord(tracker: tracker)
            collectionView.reloadItems(at: [indexPath])
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
}

//MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        textOfSearchQuery = searchController.searchBar.text ?? ""
        updateVisibleCategories()
    }
}

//MARK: - TrackerStoreDelegate
extension TrackersViewController: TrackerStoreDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        setupPlaceholder()
        trackerCollectionView.reloadData()
        //TODO: - Переделать на обновление отдельных ячеек
//        trackerCollectionView.performBatchUpdates {
//            let insertedIndexPaths = update.insertedIndexes.map { IndexPath(item: $0, section: 0) }
//            let deletedIndexPaths = update.deletedIndexes.map { IndexPath(item: $0, section: 0) }
//            trackerCollectionView.insertRows(at: insertedIndexPaths, with: .automatic)
//            trackerCollectionView.deleteRows(at: deletedIndexPaths, with: .fade)
//        }
    }
}
