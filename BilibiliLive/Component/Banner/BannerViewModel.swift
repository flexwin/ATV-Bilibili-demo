//
//  BannerViewModel.swift
//  BilibiliLive
//
//  Created by iManTie on 10/11/25.
//

import SwiftUI
import UIKit

protocol BannerConvertible {
    func toBannerModel() -> BannerModel?
}

struct BannerModel: PlayableData, Codable {
    var cover: String
    var upper: VideoOwner?
    var id: Int
    var type: Int?
    var title: String
    var ogv: Ogv?
    var ownerName: String { upper?.name ?? "" }
    var pic: URL? { URL(string: cover) }

    var intro: String?
    struct Ogv: Codable, Hashable {
        let season_id: Int?
    }

    var aid: Int {
        return id
    }

    var cid: Int {
        return 0
    }
}

class BannerViewModel: ObservableObject {
    @Published var BannerDatas: [BannerModel] = []
    @Published var selectData: BannerModel?

    @Published var offsetY: CGFloat = 0
    @Published var currentIndex = 0
    @Published var selectIndex = 0
    @Published var resetFouce = 0

    @Published var isAnimate = true // 控制标题显示的动画

    @Published var pageAnimageTime = 5.0

    var focusedBannerButton: (() -> Void)?
    var overMoveLeft: (() -> Void)?
    var playAction: ((_ data: BannerModel) -> Void)?
    var detailAction: ((_ data: BannerModel) -> Void)?

    func createDatas() {
        let ower = VideoOwner(mid: 3493082095946091, name: "不再犹豫的达达猪", face: "https://i0.hdslb.com/bfs/face/e6035d9cdc7df738988ccd6893b800106ef36201.jpg")
        let data1 = BannerModel(cover: "https://i0.hdslb.com/bfs/archive/79a14985ca2240cd7fb224bf264edd524616d3c4.jpg", upper: ower, id: 935456, title: "【巫师3 新手攻略】【巫师3 新手攻略】【巫师3 新手攻略】【巫师3 新手攻略】【巫师3 新手攻略】", intro: "「艾尔登法环」「ELDEN RING」7个“大卢恩”—6个“神授塔”（葛瑞克、拉卡德、拉塔恩、蒙葛特、蒙格、玛丽妮亚、无缘诞生者的大卢恩）（宁姆格福、西亚坛、盖利德、东亚坛、孤立、利耶尼亚神授塔）")
        let data2 = BannerModel(cover: "https://archive.biliimg.com/bfs/archive/eb80c516bfeb6ff0d9220bf723aea565d98c46d2.jpg", upper: ower, id: 935457, title: "【巫师3 新手攻略】", intro: "「艾尔登法环」")
        let data3 = BannerModel(cover: "https://archive.biliimg.com/bfs/archive/158c399607224ee95a5f7ba69a98787e5bf216be.jpg", upper: ower, id: 935458, title: "【巫师3 新手攻略】", intro: "「艾尔登法环」「ELDEN RING」7个“大卢恩”—6个“神授塔”（葛瑞克、拉卡德、拉塔恩、蒙葛特、蒙格、玛丽妮亚、无缘诞生者的大卢恩）（宁姆格福、西亚坛、盖利德、东亚坛、孤立、利耶尼亚神授塔）")

        BannerDatas = [data1, data2, data3]
        selectData = BannerDatas.first
    }

    @MainActor
    func loadBannerDataList(isReset: Bool = true) async throws {
        let style = Settings.bannerType

        if style == .BannertypeHistory {
            Task { [weak self] in
                guard let self = self else { return }
                historyData { [weak self] HistoryDatas in
                    let banners = HistoryDatas
                        .compactMap { $0.toBannerModel() }
                        .prefix(20)
                        .map { $0 } // ArraySlice -> Array

                    // 回到主线程更新 UI
                    DispatchQueue.main.async {
                        self?.BannerDatas = banners
                        self?.setTopShelfInfo(isReset: isReset)
                    }
                }
            }
        } else {
            // 收藏
            if style == .BannertypeFav {
                Task {
                    do {
                        if let favList = try? await WebRequest.requestFavVideosList(),
                           !favList.isEmpty,
                           let firstId = favList.first?.id {
                            let result = try await WebRequest.requestFavVideos(mid: String(firstId), page: 0)

                            // 后台线程处理数据
                            let banners = result
                                .compactMap { $0.toBannerModel() }
                                .prefix(20)
                                .map { $0 } // ArraySlice -> Array

                            // 主线程刷新 UI
                            await MainActor.run {
                                self.BannerDatas = banners
                            }
                        }
                    } catch {
                        print("请求失败:", error)
                    }
                }

            } else if style == .BannertypeFeed {
                Task { // 异步子线程
                    do {
                        let result = try await requestFeedDatas()
                        let banners = result
                            .compactMap { $0.toBannerModel() }
                            .prefix(20)
                            .map { $0 }

                        // ⚡️ 在主线程更新 UI
                        await MainActor.run {
                            self.BannerDatas = banners
                            self.setTopShelfInfo(isReset: isReset)
                        }
                    } catch {
                        print("请求失败:", error)
                    }
                }
            } else if style == .BannertypeHot {
                Task { // 异步子线程
                    do {
                        let result = try await requestHotDatas()
                        let banners = result
                            .compactMap { $0.toBannerModel() }
                            .prefix(20)
                            .map { $0 }

                        // ⚡️ 在主线程更新 UI
                        await MainActor.run {
                            self.BannerDatas = banners
                            self.setTopShelfInfo(isReset: isReset)
                        }
                    } catch {
                        print("请求失败:", error)
                    }
                }
            } else if style == .BannertypeFollows {
                Task { // 异步子线程
                    do {
                        let result = try await requestFollowsFeed(offset: "", page: 1)
                        let banners = result.items
                            .compactMap { $0.toBannerModel() }
                            .prefix(20)
                            .map { $0 }

                        // ⚡️ 在主线程更新 UI
                        await MainActor.run {
                            self.BannerDatas = banners
                            self.setTopShelfInfo(isReset: isReset)
                        }
                    } catch {
                        print("请求失败:", error)
                    }
                }
            }
            await MainActor.run {
                setTopShelfInfo(isReset: isReset)
            }
        }
    }

    func setTopShelfInfo(isReset: Bool = true) {
        if isReset {
            resetFouce = resetFouce + 1
        }
        if selectIndex < BannerDatas.count {
            selectData = BannerDatas[selectIndex]
            currentIndex = selectData?.id ?? 0
        } else {
            selectData = BannerDatas.first
            currentIndex = selectData?.id ?? 0
            resetFouce = resetFouce + 1
        }
        TopShelfDataManager.shared.removeAllItem()
        BannerDatas.forEach { bannerData in
            if let dataUrl = bannerData.pic {
                let model = TopShelfContentModel(id: String(bannerData.id), title: bannerData.title, description: bannerData.intro ?? "", imageURL: dataUrl)
                TopShelfDataManager.shared.addItem(model)
            }
        }
    }

    func setIndex(index: Int) {
        if index < BannerDatas.count {
            selectData = BannerDatas[index]
            currentIndex = selectData?.id ?? 0
        }
    }

    func changPageAnimageTime() {
        pageAnimageTime = 20.0
        BLAfter(afterTime: 10.0) {
            self.pageAnimageTime = 5.0
        }
    }

    // 热门视频
    func requestHotDatas() async throws -> [VideoDetail.Info] {
        return try await WebRequest.requestHotVideo(page: 1, pageSize: 20).list
    }

    // 推荐视频
    func requestFeedDatas() async throws -> [ApiRequest.FeedResp.Items] {
        return try await ApiRequest.getFeeds()
    }

    // 关注
    func requestFollowsFeed(offset: String, page: Int) async throws -> WebRequest.DynamicFeedInfo {
        var param: [String: Any] = ["type": "all", "timezone_offset": "-480", "page": page]
        if let offsetNum = Int(offset) {
            param["offset"] = offsetNum
        }
        let res: WebRequest.DynamicFeedInfo = try await WebRequest.request(url: "https://api.bilibili.com/x/polymer/web-dynamic/v1/feed/all", parameters: param)
        if res.videoFeeds.isEmpty, res.has_more {
            return try await requestFollowsFeed(offset: res.offset, page: page)
        }
        return res
    }

    // 播放列表
    func historyData(complete: (([HistoryData]) -> Void)?) {
        WebRequest.requestHistory(complete: complete)
    }
}

// 收藏
extension FavData: BannerConvertible {
    func toBannerModel() -> BannerModel? {
        if cover.isEmpty {
            return nil
        }
        return BannerModel(cover: cover, upper: upper, id: aid, title: title, intro: intro)
    }
}

// 热门视频
extension VideoDetail.Info: BannerConvertible {
    func toBannerModel() -> BannerModel? {
        if pic == nil || pic!.absoluteString.isEmpty {
            return nil
        }
        return BannerModel(cover: pic?.absoluteString ?? "", upper: owner, id: aid, title: title, intro: desc)
    }
}

// 推荐
extension ApiRequest.FeedResp.Items: BannerConvertible {
    func toBannerModel() -> BannerModel? {
        if pic == nil || pic!.absoluteString.isEmpty {
            return nil
        }
        return BannerModel(cover: cover, id: Int(param) ?? 0, title: title)
    }
}

extension DynamicFeedData: BannerConvertible {
    func toBannerModel() -> BannerModel? {
        if pic == nil || pic!.absoluteString.isEmpty {
            return nil
        }

        let ower = VideoOwner(mid: ownerMid ?? 0, name: ownerName, face: avatar?.absoluteString)
        return BannerModel(cover: pic?.absoluteString ?? "", id: aid, title: title)
    }
}

// 历史
extension HistoryData: BannerConvertible {
    func toBannerModel() -> BannerModel? {
        if pic == nil || pic!.absoluteString.isEmpty {
            return nil
        }
        return BannerModel(cover: pic?.absoluteString ?? "", upper: owner, id: aid, title: title)
    }
}
