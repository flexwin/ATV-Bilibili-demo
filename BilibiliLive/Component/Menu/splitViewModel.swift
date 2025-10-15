//
//  splitViewModel.swift
//  BilibiliLive
//
//  Created by mantieus on 2025/10/15.
//

import UIKit

class splitViewModel: ObservableObject {

    @Published var userHeadIamgeUrl:String?
    @Published var userName:String?
    
    func loadUserInfo(){
        WebRequest.requestLoginInfo { [weak self] response in
            switch response {
            case let .success(json):
                self?.userHeadIamgeUrl = json["face"].stringValue
                self?.userName = json["uname"].stringValue
            case .failure:
                break
            }
        }
    }
}
