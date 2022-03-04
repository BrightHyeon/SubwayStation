//
//  StationArrivalDataResponseModel.swift
//  SubwayStation
//
//  Created by HyeonSoo Kim on 2022/03/04.
//

import Foundation

struct StationArrivalDataResponseModel: Decodable {
    //빈상태라도 초기화 빈 배열은 있도록.
    var realtimeArrivalList: [RealTimeArrival] = []
    
}

struct RealTimeArrival: Decodable {
    let line: String
    let remainTime: String
    let currentStation: String
    
    enum CodingKeys: String, CodingKey {
        case line = "trainLineNm"
        case remainTime = "arvlMsg2"
        case currentStation = "arvlMsg3"
    }
}
