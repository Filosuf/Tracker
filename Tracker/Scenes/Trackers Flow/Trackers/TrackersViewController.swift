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
    private var categories = [TrackerCategory]()
    private var completedTrackers = [TrackerRecord]()
    private var currentDate = Date()
    private var visibleCategories = [TrackerCategory]()
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
        label.textColor = .Custom.text
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
    init(coordinator: TrackersFlowCoordinator) {
        self.coordinator = coordinator
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        updateVisibleCategories()
    }
    
    // MARK: - Methods
    private func setBar() {
        navigationItem.searchController = searchBar
        navigationItem.title = "Трекеры"
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addTracker))
        navigationItem.leftBarButtonItem?.tintColor = .Custom.text
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }

    private func setupView() {
        if categories.isEmpty {
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
        let categoriesSorted = categories.sorted(by: <)
        coordinator.showNewTracker(rootViewController: self, categories: categoriesSorted)
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
        var categoriesFiltered = categories.map { filterByDateCategory(category: $0) }
        categoriesFiltered = categoriesFiltered.filter { !$0.trackers.isEmpty }
        categoriesFiltered = categoriesFiltered.sorted(by: <)
        visibleCategories = categoriesFiltered
        trackerCollectionView.reloadData()
    }


    private func filterByDateCategory(category: TrackerCategory) -> TrackerCategory {
        var trackers = category.trackers.filter( { ($0.schedule.contains(where: { $0.dayNumberOfWeek == currentDate.dayNumberOfWeek() }) || $0.schedule.isEmpty) && ($0.name.contains(textOfSearchQuery) || textOfSearchQuery == "") })
        trackers = trackers.sorted(by: <)
        let filterCategory = TrackerCategory(title: category.title, trackers: trackers)
        return filterCategory
    }

    private func changeRecord(tracker: Tracker) {
        let isTodayCompleted = !completedTrackers.filter { $0.id == tracker.id && $0.date == currentDate }.isEmpty
        let trackerId = tracker.id
        let record = TrackerRecord(id: trackerId, date: currentDate)
        if isTodayCompleted {
            completedTrackers.removeAll(where: {$0 == record})
        } else {
            completedTrackers.append(record)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackersCollectionViewCell.identifier, for: indexPath) as! TrackersCollectionViewCell
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let numberOfCompleted = completedTrackers.filter { $0.id == tracker.id }.count
        let isTodayCompleted = !completedTrackers.filter { $0.id == tracker.id && $0.date == currentDate }.isEmpty
        cell.setupCell(tracker: tracker, numberOfMarks: numberOfCompleted, isTodayCompleted: isTodayCompleted, isHabit: !tracker.schedule.isEmpty)
        cell.buttonAction = { [weak self] in
            self?.changeRecord(tracker: tracker)
            collectionView.reloadItems(at: [indexPath])
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderCollectionView.identifier, for: indexPath) as? HeaderCollectionView  else { return UICollectionReusableView() }
        view.setTitle(visibleCategories[indexPath.section].title)
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

//MARK: -
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        textOfSearchQuery = searchController.searchBar.text ?? ""
        updateVisibleCategories()
    }
}

//MARK: - TrackerSettingsViewControllerProtocol
extension TrackersViewController: TrackerSettingsViewControllerProtocol {
    func categoriesDidUpdate(with categories: [TrackerCategory]) {
        self.categories = categories
        updateVisibleCategories()
        setupView()
        trackerCollectionView.reloadData()
    }
}
