//
//  TopShelfDataManager.swift
//  BilibiliLive
//
//  Created by iManTie on 10/17/25.
//

import Foundation

struct TopShelfContentModel: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let imageURL: URL
}

enum TopShelfStyle: String, Codable, CaseIterable {
    case TopShelfStyleSectionedContent = "TVTopShelfSectionedContent"
    case TopShelfStyleCarouselContent = "TVTopShelfCarouselContent"
    case TopShelfStyleNormal

    var hideInSetting: Bool {
        self == .TopShelfStyleNormal
    }
}

extension TopShelfStyle {
    var desp: String {
        switch self {
        case .TopShelfStyleSectionedContent:
            return "小图展示"
        case .TopShelfStyleCarouselContent:
            return "全屏展示"
        case .TopShelfStyleNormal:
            return "小图展示"
        }
    }
}

class TopShelfDataManager {
    static let shared = TopShelfDataManager()

    private let userDefaultsKey = "TopShelfItems"
    private let userDefaultsTopShelfStyleKey = "TopShelfStyle"
    private let suiteName = "group.com.example.mtgrouplili" // App Group 名称
    private var userDefaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    private(set) var items: [TopShelfContentModel] = []

    private init() {
        loadFromUserDefaults()
    }

    // MARK: - CRUD

    func addItem(_ item: TopShelfContentModel) {
        items.append(item)
        saveToUserDefaults()
    }

    func removeItem(withId id: String) {
        items.removeAll { $0.id == id }
        saveToUserDefaults()
    }

    func removeAllItem() {
        items.removeAll()
        saveToUserDefaults()
    }

    func refresh() {
        saveToUserDefaults()
    }

    // MARK: - UserDefaults

    private func saveToUserDefaults() {
        if let data = try? JSONEncoder().encode(items) {
            userDefaults?.set(data, forKey: userDefaultsKey)
        }
    }

    private func loadFromUserDefaults() {
        guard let data = userDefaults?.data(forKey: userDefaultsKey),
              let savedItems = try? JSONDecoder().decode([TopShelfContentModel].self, from: data) else {
            return
        }
        items = savedItems
    }

    func setTopShelfStyle(_ style: TopShelfStyle) {
        userDefaults?.set(style.rawValue, forKey: userDefaultsTopShelfStyleKey)
    }

    func getTopShelfStyle() -> TopShelfStyle {
        if let raw = userDefaults?.string(forKey: userDefaultsTopShelfStyleKey),
           let style = TopShelfStyle(rawValue: raw) {
            return style
        } else {
            return .TopShelfStyleSectionedContent // 默认值
        }
    }
}
