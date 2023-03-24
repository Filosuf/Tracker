//
//  SettingsStorage.swift
//  Tracker
//
//  Created by Filosuf on 23.03.2023.
//

import Foundation

protocol SettingsStorageProtocol {
    var skipOnboarding: Bool { get }
    func setSkipOnboarding(_ newValue: Bool)
}

final class SettingsStorage: SettingsStorageProtocol {

    private let userDefaults = UserDefaults.standard
    private let skipOnboardingKey = "skipOnboardingKey"
    var skipOnboarding: Bool {
        get {
            return userDefaults.bool(forKey: skipOnboardingKey)
        }
    }

    func setSkipOnboarding(_ newValue: Bool) {
        userDefaults.set(newValue, forKey: skipOnboardingKey)
    }
}
