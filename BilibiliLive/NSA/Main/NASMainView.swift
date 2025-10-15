//
//  NASMainView.swift
//  BilibiliLive
//
//  Created by iManTie on 10/15/25.
//

import SwiftUI

struct NASMainView: View {
    var body: some View {
       
        NavigationSplitView {
            /*@START_MENU_TOKEN@*/Text("Sidebar")/*@END_MENU_TOKEN@*/
        } detail: {
            /*@START_MENU_TOKEN@*/Text("Detail")/*@END_MENU_TOKEN@*/
        }
    }
}




#Preview {
    NASMainView()
}
