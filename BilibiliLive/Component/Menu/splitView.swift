//
//  splitView.swift
//  BilibiliLive
//
//  Created by mantieus on 2025/10/15.
//

import Kingfisher
import SwiftUI
import UIKit

struct ControllerContainer: UIViewControllerRepresentable {
    let viewController: UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        // 包装在容器控制器中，自动填充
        let container = UIViewController()
        container.addChild(viewController)
        container.view.addSubview(viewController.view)

        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: container.view.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: container.view.bottomAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: container.view.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: container.view.trailingAnchor),
        ])

        viewController.didMove(toParent: container)
        return container
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // 不需要额外更新
    }
}

enum MenuItem: String, CaseIterable, Identifiable {
    case follows
    case feed
    case hot
    case ranking
    case live
    case favorite
    case history
    case setting

    var id: String { rawValue }

    /// 菜单标题
    var title: String {
        switch self {
        case .follows: return "关注"
        case .feed: return "动态"
        case .hot: return "热门"
        case .ranking: return "排行榜"
        case .live: return "直播"
        case .favorite: return "收藏"
        case .history: return "历史记录"
        case .setting: return "设置"
        }
    }

    /// 菜单图标（SF Symbol 名称）
    var image: String {
        switch self {
        case .follows: return "person.2.fill"
        case .feed: return "rectangle.stack.fill"
        case .hot: return "livephoto.play"
        case .ranking: return "theatermasks.circle"
        case .live: return "infinity.circle"
        case .favorite: return "star.circle"
        case .history: return "gauge.with.needle"
        case .setting: return "gear"
        }
    }

    /// 菜单图标（SF Symbol 名称）
    var viewController: ControllerContainer {
        lazy var vc = FollowsViewController()
        lazy var feed = FeedViewController()
        lazy var hot = HotViewController()
        switch self {
        case .follows: return ControllerContainer(viewController: vc)
        case .feed: return ControllerContainer(viewController: feed)
        case .hot: return ControllerContainer(viewController: hot)
        case .ranking: return ControllerContainer(viewController: RankingViewController())
        case .live: return ControllerContainer(viewController: LiveViewController())
        case .favorite: return ControllerContainer(viewController: FavoriteViewController())
        case .history: return ControllerContainer(viewController: HistoryViewController())
        case .setting: return ControllerContainer(viewController: PersonalViewController.create())
        }
    }
}

struct splitView: View {
    @StateObject var viewModel = splitViewModel()
    @State private var selectedTab: MenuItem = .feed

    var body: some View {
        ZStack(alignment: .topTrailing) {
            TabView(selection: $selectedTab) {
                ForEach(MenuItem.allCases) { item in
                    item.viewController.ignoresSafeArea()
                        .tabItem {
                            Label(item.title, systemImage: item.image)
                        }
                        .tag(item)
                }
            }
            .tabViewStyle(.sidebarAdaptable)
            
        }
    }
}

struct customImageView: View {
    var body: some View {
        Image("cover")
            .resizable()
            .renderingMode(.original)
            .frame(width: 56, height: 56)
            .cornerRadius(28)
    }
}

#Preview {
    splitView()
}
