//
//  AllPageDatasView.swift
//  BilibiliLive
//
//  Created by mantieus on 2025/10/17.
//
import SwiftUI

struct VideoListView: View {
    #if DEBUG
        var pages = (1 ... 500).map { VideoPage(cid: $0, page: $0, epid: nil, from: "tvOS", part: "\($0)") }
    #else
        var pages: [VideoPage] = []
    #endif

    var pageAction: ((_ page: VideoPage) -> Void)?

    private let columns = Array(repeating: GridItem(.fixed(260), spacing: 22), count: 6)

    // ✅ 用 FocusState 代替旧的 focusable 回调
    @FocusState private var focusedPage: String?
    @State var isSelect = false

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 22) {
                ForEach(pages, id: \.self) { page in

                    // 低版本兼容处理
                    Text("\(page.part)")
                        .font(.system(size: 22))
                        .foregroundStyle(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                        .background(focusedPage == page.part ? Color.blue : Color.gray.opacity(0.3))
                        .cornerRadius(44)
                        .focusable(true)
                        // ✅ 使用新的 FocusState API
                        .focused($focusedPage, equals: page.part)
                        .onTapGesture {
                            pageAction?(page)
                        }
                       
                }
            }
            .padding()
        }
    }
}

struct VideoListView_Previews: PreviewProvider {
    static var previews: some View {
        VideoListView()
    }
}
