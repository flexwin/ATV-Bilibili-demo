//
//  AppDelegate.swift
//  BilibiliLive
//
//  Created by Etan on 2021/3/27.
//

import AVFoundation
import CocoaLumberjackSwift
import SwiftUI
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Logger.setup()
        AVInfoPanelCollectionViewThumbnailCellHook.start()
        CookieHandler.shared.restoreCookies()
        BiliBiliUpnpDMR.shared.start()
        URLSession.shared.configuration.headers.add(.userAgent("BiLiBiLi AppleTV Client/1.0.0 (github/yichengchen/ATV-Bilibili-live-demo)"))
        window = UIWindow()
        if ApiRequest.isLogin() {
            if let expireDate = ApiRequest.getToken()?.expireDate {
                let now = Date()
                if expireDate.timeIntervalSince(now) < 60 * 60 * 30 {
                    ApiRequest.refreshToken()
                }
            } else {
                ApiRequest.refreshToken()
            }

//            // 创建 SwiftUI 的根视图
//            let swiftUIView = splitView()
//
//            // 用 UIHostingController 包装
//            let hostingController = UIHostingController(rootView: swiftUIView)
//
//            // 约束铺满整个屏幕
//            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
//            window?.rootViewController = hostingController

            window?.rootViewController = MenusViewController.create()
        } else {
            window?.rootViewController = LoginViewController.create()
        }
        WebRequest.requestIndex()
        window?.makeKeyAndVisible()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
    }

    func showLogin() {
        window?.rootViewController = LoginViewController.create()
    }

    func showTabBar() {
        window?.rootViewController = MenusViewController.create()
    }

    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    // 处理 Top Shelf 或其他外部 URL 打开
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        guard url.scheme == "mtvideolili" else { return false }

        if url.host == "play", let id = url.pathComponents.dropFirst().first {
            // 用户按 Top Shelf 播放按钮
            print("播放内容 ID=\(id)")
            if let id = Int(id) {
                let player = VideoPlayerViewController(playInfo: PlayInfo(aid: id, cid: 0, epid: 0, isBangumi: false))
                window?.rootViewController?.present(player, animated: true)
            }

            // 这里可以跳转到播放页面或开始播放视频
        } else if url.host == "content", let id = url.pathComponents.dropFirst().first {
            // 用户点击 Top Shelf 条目
            print("打开内容详情 ID=\(id)")
            // 这里可以跳转到详情页面
            if let id = Int(id) {
                let player = VideoPlayerViewController(playInfo: PlayInfo(aid: id, cid: 0, epid: 0, isBangumi: false))
                window?.rootViewController?.present(player, animated: true)
            }
        }

        return true
    }
}
