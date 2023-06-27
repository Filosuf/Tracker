//
//  SettingsStorage.swift
//  Tracker
//
//  Created by Filosuf on 23.03.2023.
//

import Foundation

protocol SettingsStorageProtocol {
    var skipOnboarding: Bool { get }
    var numberOfCompletedTrackers: Int { get }
    var filter: Filter { get }

    func setSkipOnboarding(_ newValue: Bool)
    func updateCompletedTrackers(_ newValue: Int)
    func saveFilter(_ newValue: Filter)
}

final class SettingsStorage: SettingsStorageProtocol {

    private let userDefaults = UserDefaults.standard
    private let skipOnboardingKey = "skipOnboardingKey"
    private let numberOfCompletedTrackersKey = "numberOfCompletedTrackersKey"
    private let filterKey = "filterKey"

    var skipOnboarding: Bool {
        get {
            return userDefaults.bool(forKey: skipOnboardingKey)
        }
    }

    var numberOfCompletedTrackers: Int {
        get {
            return userDefaults.integer(forKey: numberOfCompletedTrackersKey)
        }
    }

    var filter: Filter {
        get {
            guard let name =  userDefaults.string(forKey: filterKey) else { return Filter.all }
            return Filter(rawValue: name) ?? Filter.all
        }
    }

    func setSkipOnboarding(_ newValue: Bool) {
        userDefaults.set(newValue, forKey: skipOnboardingKey)
    }

    func updateCompletedTrackers(_ newValue: Int) {
        userDefaults.set(newValue, forKey: numberOfCompletedTrackersKey)
    }

    func saveFilter(_ newValue: Filter) {
        userDefaults.set(newValue.rawValue, forKey: filterKey)
    }
}
