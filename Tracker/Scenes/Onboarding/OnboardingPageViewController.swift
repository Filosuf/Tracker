//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Filosuf on 23.03.2023.
//

import UIKit


final class OnboardingPageViewController: UIPageViewController {
    // MARK: - Properties
    private let settingsStorage: SettingsStorageProtocol
    private let coordinator: MainCoordinator
    private let pages: [UIViewController]

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .Custom.blackDay
        pageControl.pageIndicatorTintColor = .Custom.gray
        pageControl.addTarget(self, action: #selector(pageControlHandle), for: .valueChanged)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()

    // MARK: - LifeCycle
    init(pages: [UIViewController], settingsStorage: SettingsStorageProtocol, coordinator: MainCoordinator) {
        self.pages = pages
        self.settingsStorage = settingsStorage
        self.coordinator = coordinator
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        layout()
        setupAction()
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
    }

    // MARK: - Methods
    private func setupAction() {
        for page in pages {
            if let page = page as? OnboardingViewController {
                page.tapAction = { [weak self] in
                    self?.skipOnboarding()
                }
            }
        }
    }

    @objc private func pageControlHandle(sender: UIPageControl){
        let index = sender.currentPage
        if index < pages.count {
            let page = pages[index]
            setViewControllers([page], direction: .forward, animated: true, completion: nil)
        }
    }

    private func skipOnboarding() {
        settingsStorage.setSkipOnboarding(true)
        coordinator.switchToTabBarController()
    }

    private func layout() {
        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingPageViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else {
            return nil
        }

        return pages[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1

        guard nextIndex < pages.count else {
            return nil
        }

        return pages[nextIndex]
    }

}

// MARK: - UIPageViewControllerDelegate
extension OnboardingPageViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
