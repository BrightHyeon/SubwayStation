//
//  StationResponseModel.swift
//  SubwayStation
//
//  Created by HyeonSoo Kim on 2022/03/04.
//

import Foundation

//전체모델
struct StationResponseModel: Decodable {
    
    //제일 상위 key
    private let searchInfo: SearchInfoBySubwayNameServiceModel
    
    //원하는 값 접근편하도록
    var stations: [Station] { searchInfo.row }
    
    
    enum CodingKeys: String, CodingKey {
        case searchInfo = "SearchInfoBySubwayNameService"
    }
    
    
    struct SearchInfoBySubwayNameServiceModel: Decodable {
        
        var row: [Station] = [] //빈배열로 초기화.
        
    }
    
}

//각각의 Station
struct Station: Decodable {
    
    let stationName: String
    let lineNumber: String
    
    enum CodingKeys: String, CodingKey {
        case stationName = "STATION_NM"
        case lineNumber = "LINE_NUM"
    }
}
