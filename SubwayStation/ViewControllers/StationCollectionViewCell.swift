//
//  StationCollectionViewCell.swift
//  SubwayStation
//
//  Created by HyeonSoo Kim on 2022/03/04.
//

import UIKit
import SnapKit

class StationCollectionViewCell: UICollectionViewCell {
    
    private lazy var lineLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .label
        
        return label
    }()
    
    private lazy var remainTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .light)
        label.textColor = .label
        
        return label
    }()
    
    func setup(stationInfo: RealTimeArrival) {
        setupLayout()
        
        lineLabel.text = stationInfo.line
        remainTimeLabel.text = stationInfo.remainTime
        
    }
}

private extension StationCollectionViewCell {
    func setupLayout() {
        
        //cell의 배경색에 대한 세팅을 해주어야 기준점이 생겨서 테두리그림자가 성공적으로 생성된다.
        //지정해주지않을경우, 기준을 잘 잡지못하고, 라벨주변으로 그림자가 생기는 불상사가 발생!
        backgroundColor = .white // = self.backgroundColor = .white
        
        [lineLabel, remainTimeLabel].forEach { addSubview($0) }
        
        lineLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(10)
            $0.bottom.equalTo(snp.centerY)
        }
        
        remainTimeLabel.snp.makeConstraints {
            $0.leading.equalTo(lineLabel)
            $0.top.equalTo(lineLabel.snp.bottom)
        }
    }
}
