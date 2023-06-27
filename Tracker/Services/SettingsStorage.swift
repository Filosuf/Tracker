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
    func setSkipOnboarding(_ newValue: Bool)
    func updateCompletedTrackers(_ newValue: Int)
}

final class SettingsStorage: SettingsStorageProtocol {

    private let userDefaults = UserDefaults.standard
    private let skipOnboardingKey = "skipOnboardingKey"
    private let numberOfCompletedTrackersKey = "numberOfCompletedTrackersKey"

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

    func setSkipOnboarding(_ newValue: Bool) {
        userDefaults.set(newValue, forKey: skipOnboardingKey)
    }

    func updateCompletedTrackers(_ newValue: Int) {
        userDefaults.set(newValue, forKey: numberOfCompletedTrackersKey)
    }
}
