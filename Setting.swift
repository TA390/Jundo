//
//  Setting.swift
//  Jundo
//
//  Created by TA on 30/04/2017.
//  Copyright © 2017 Splynter Inc. All rights reserved.
//

import Foundation

enum inAppPurchase: String {
    case pathFinder = "PathFinder"
    case snailSpeed = "SnailSpeed"
    case ghosting = "Ghosting"
    case breadCrumbs = "BreadCrumbs"
}

enum SettingKey: String {
    case sound = "sound"
    case gems = "gems"
    case level = "level"
    case levelGems = "levelGems"
}

let Setting = _Setting()

class _Setting {
    
    private var _sound: Bool
    var sound: Bool { return _sound }
    private var _gems: Int
    var gems: Int { return _gems }
    private var _level: Int
    var level: Int { return _level }
    private var _levelGems: [Int]
    
    init() {
        
        let defaults: [String : Any] = [
            SettingKey.sound.rawValue : true,
            SettingKey.gems.rawValue: 0,
            SettingKey.level.rawValue: 1,
            SettingKey.levelGems.rawValue: Array(repeating: 0, count: 24),
            inAppPurchase.pathFinder.rawValue: false,
            inAppPurchase.snailSpeed.rawValue: false,
            inAppPurchase.ghosting.rawValue: false,
            inAppPurchase.breadCrumbs.rawValue: false
        ]
        UserDefaults.standard.register(defaults: defaults)
        _sound = UserDefaults.standard.bool(forKey: SettingKey.sound.rawValue)
        _gems = UserDefaults.standard.integer(forKey: SettingKey.gems.rawValue)
        _level = UserDefaults.standard.integer(forKey: SettingKey.level.rawValue)
        _levelGems = UserDefaults.standard.array(forKey: SettingKey.levelGems.rawValue) as! [Int]
        
    }
    
    func save(_ key: SettingKey? = nil) {
        if let settingKey = key {
            let name = settingKey.rawValue
            switch settingKey {
            case .gems:
                UserDefaults.standard.set(_gems, forKey: name)
            case .sound:
                UserDefaults.standard.set(_sound, forKey: name)
            case .level:
                UserDefaults.standard.set(_level, forKey: name)
            case .levelGems:
                UserDefaults.standard.set(_levelGems, forKey: name)
            }
        } else {
            UserDefaults.standard.setValuesForKeys([
                SettingKey.sound.rawValue : sound,
                SettingKey.gems.rawValue : _gems,
                SettingKey.level.rawValue: _level,
                SettingKey.levelGems.rawValue: _levelGems])
        }
    }
    
    func canPurchase(gems: Int) -> Bool {
        return !Int.addWithOverflow(_gems, gems).overflow
    }
    
    func purchase(gems: Int, save: Bool = true){
        let total = Int.addWithOverflow(_gems, gems)
        _gems = total.overflow ? Int.max : (total.0 < 0 ? 0 : total.0)
        if save { self.save(.gems) }
    }

    func gems(level: Int) -> Int {
        return isValid(level: level) ? _levelGems[level-1] : 0
    }
    
    func isValid(level: Int) -> Bool {
        return level >= 1 && level <= _levelGems.count
    }
    
    func isEnabled(level: Int) -> Bool {
        return isValid(level: level) && level <= _level
    }
    
    func isEnabled(iap: inAppPurchase) -> Bool {
        return UserDefaults.standard.bool(forKey: iap.rawValue)
    }
    
    func enable(iap: inAppPurchase) {
        UserDefaults.standard.set(true, forKey: iap.rawValue)
    }
    
    func disable(iap: inAppPurchase) {
        UserDefaults.standard.set(false, forKey: iap.rawValue)
    }
    
    func name(iap: inAppPurchase) -> String {
        return iap.rawValue
    }
    
    func price(iap: inAppPurchase) -> Int {
        switch iap {
        case .pathFinder: return 3
        case .snailSpeed: return 6
        case .ghosting: return 12
        case .breadCrumbs: return 15
        }
    }
    
    func toggleSound() {
        _sound = !_sound
        save(.sound)
    }
    
};
