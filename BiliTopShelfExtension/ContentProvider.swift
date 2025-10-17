//
//  ContentProvider.swift
//  BiliTopShelfExtension
//
//  Created by iManTie on 10/17/25.
//

import TVServices

class ContentProvider: TVTopShelfContentProvider {
    override func loadTopShelfContent() async -> (any TVTopShelfContent)? {
        // Fetch and return content asynchronously.
        // 创建一个 TVContentItem 的数组
        // 异步获取数据示例
        // 示例数据

        let sampleContents = TopShelfDataManager.shared.items
        // 创建 TVTopShelfItem 数组
        let items: [TVTopShelfCarouselItem] = sampleContents.map { model in
            let imageURL = model.imageURL
            let item = TVTopShelfCarouselItem(identifier: model.id)
            item.setImageURL(imageURL, for: .screenScale2x) // ✅ 新版用法
            item.title = "播放"

            // 播放
//            let playAction = TVTopShelfAction(url: URL(string: "mtvideolili://video/\(model.id)")!)
//
//            item.playAction = playAction

            // 详情
            let displayAction = TVTopShelfAction(url: URL(string: "mtvideolili://content/\(model.id)")!)
            item.displayAction = displayAction

            return item
        }

        // 创建 TVTopShelfItem 数组
        let seciontItems: [TVTopShelfSectionedItem] = sampleContents.map { model in
            let imageURL = model.imageURL
            let item = TVTopShelfSectionedItem(identifier: model.id)
            item.setImageURL(imageURL, for: .screenScale2x) // ✅ 新版用法
            item.title = "播放"

//            // 播放
//            let playAction = TVTopShelfAction(url: URL(string: "mtvideolili://play/\(model.id)")!)
//
//            item.playAction = playAction

            // 详情
            let displayAction = TVTopShelfAction(url: URL(string: "mtvideolili://content/\(model.id)")!)
            item.displayAction = displayAction

            return item
        }

        if TopShelfDataManager.shared.getTopShelfStyle() == .TopShelfStyleCarouselContent {
            let topShelfCarouselContent = TVTopShelfCarouselContent(style: .actions, items: items)
            return topShelfCarouselContent
        } else {
            let shelfItemCollection = TVTopShelfItemCollection(items: seciontItems)

            let topShelfSectionedContent = TVTopShelfSectionedContent(sections: [shelfItemCollection])

            return topShelfSectionedContent
        }
    }
}
