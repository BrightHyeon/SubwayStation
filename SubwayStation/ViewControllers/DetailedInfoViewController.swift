//
//  DetailedInfoViewController.swift
//  SubwayStation
//
//  Created by HyeonSoo Kim on 2022/03/04.
//

import UIKit
import SnapKit
import Alamofire

final class DetailedInfoViewController: UIViewController {
    
    private let stationName: String
    
    init(stationName: String) {
        self.stationName = stationName
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //UIRefreshControl: 단독으로 사용되기보단 일반적으로 UICollectionView와 함께 사용.
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        
        return refreshControl
    }()
    
    @objc private func fetchData() {
        
        let urlString = "http://swopenapi.seoul.go.kr/api/subway/sample/json/realtimeStationArrival/0/5/\(stationName.replacingOccurrences(of: "역", with: ""))"
        
        AF
            .request(urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
            .responseDecodable(of: StationArrivalDataResponseModel.self) { [weak self] response in //weak self: 메모리이슈 방지.
                
                guard let self = self else { return }
                
                self.refreshControl.endRefreshing()
                
                guard case .success(let data) = response.result else { return }
                
                self.realtimeList = data.realtimeArrivalList
                self.collectionView.reloadData()
            }
            .resume()
    }
 
    private lazy var realtimeList: [RealTimeArrival] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        //아래처럼 해도되고, sizeForItemAt메서드에서 해도되고.
//        layout.estimatedItemSize = CGSize(
//            width: view.frame.width - 20,
//            height: 100
//        )
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        
        collectionView.register(StationCollectionViewCell.self, forCellWithReuseIdentifier: "StationCollectionViewCell")
        collectionView.refreshControl = refreshControl //collectionView는 원래부터 옵셔널로 refreshControl을 내포하고있음.
        
        return collectionView
    }()
    
    //MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        
        setupViews()
        
        fetchData()
        
    }
}

extension DetailedInfoViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return realtimeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StationCollectionViewCell", for: indexPath) as? StationCollectionViewCell else { return UICollectionViewCell() }
        
        let stationInfo = realtimeList[indexPath.row]
        
        cell.setup(stationInfo: stationInfo)
        
        //configure the cell
        cell.layer.cornerRadius = 10.0 //radius
        cell.layer.borderWidth = 0.0 //테두리 두께
        cell.layer.shadowColor = UIColor.blue.cgColor //색
        cell.layer.shadowOffset = CGSize(width: 0, height: 0) //셀 기준 위치
        cell.layer.shadowRadius = 4 //번짐정도
        cell.layer.shadowOpacity = 0.5 //진함정도
        cell.layer.masksToBounds = false //안의 내용이 짤리지않음. true일 경우 벗어나도 그냥 그대로 나옴.
        
        return cell
    }
    
    //필수: Item의 CGSize
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 20, height: 60)
    }
    
    //sectionInset
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
    }
    
}

private extension DetailedInfoViewController {
    func setupViews() {
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            //사방의 constraints를 만들어줘야 나타남.
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(10)
        }
    }
    
    func setupNavigation() {
        self.navigationItem.title = stationName
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
