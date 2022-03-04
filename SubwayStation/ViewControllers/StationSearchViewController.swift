//
//  StationSearchViewController.swift
//  SubwayStation
//
//  Created by HyeonSoo Kim on 2022/03/02.
//

import UIKit
import SnapKit
import Alamofire

class StationSearchViewController: UIViewController {
    
    private lazy var stationList: [Station] = [] //{
//        didSet {
//            tableView.reloadData()
//        }
//    }
    

    //MARK: - tableView
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        //!!!delegate랑 dataSource이거 lazy로 선언안하면 등록이 안된다 ~!!! 왜지?!!!
        tableView.delegate = self
        tableView.dataSource = self
        //Maybe... 사용되기도 전에 메모리에 올라가면, type충돌..?
        tableView.isHidden = true //default값
        return tableView
    }()

    //MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupNavigationBar()
        
        setupTableViewLayout()
    
    }
}

extension StationSearchViewController: UITableViewDelegate, UITableViewDataSource {
    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stationList.count
        //return 10 -> Cell의 갯수가 0이 아닐 때 searchBar가 사라짐. why? 아직 모름.
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell") //indentifier에 그냥 임의값 넣기.
        
        cell.textLabel?.text = stationList[indexPath.row].stationName
        cell.detailTextLabel?.text = stationList[indexPath.row].lineNumber
        
        return cell
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = DetailedInfoViewController(stationName: stationList[indexPath.row].stationName)
        
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

//MARK: - UISearchBar Delegate
//user의 행동을 입력받는 객체들은 대부분 delegate프로토콜을 가지고 있음. ex) UITextField, UITextView 등등.
extension StationSearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.tableView.reloadData()
        tableView.isHidden = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.stationList = []
        tableView.isHidden = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) { //searchBar에 입력된 값이 searchText임. 이 값이 바뀔 때마다 이 메서드 호출됨.
//        self.stationList = []
        requestStationName(from: searchText)
    }
}

//MARK: - private extension
private extension StationSearchViewController {
    
    //UINavigationBar & UISearchController Settings
    func setupNavigationBar() {
        
        self.navigationItem.title = "지하철 도착 정보"
        self.navigationItem.hidesSearchBarWhenScrolling = false //일단 이거 false하면 괜찮음. cell이 있으면 자동 스크롤되나..?
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        let searchController = UISearchController()
        searchController.searchBar.placeholder = "지하철역을 입력해주세요."
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.obscuresBackgroundDuringPresentation = false //검색 시 뒷배경 어둡게 할지 여부.
        searchController.searchBar.delegate = self //서치바의 delegate위임.
        
        self.navigationItem.searchController = searchController
    }
    
    //TableView Layout Settings
    func setupTableViewLayout() {

        view.addSubview(tableView)

        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func requestStationName(from stationName: String) {
        let urlString = "http://openapi.seoul.go.kr:8088/sample/json/SearchInfoBySubwayNameService/1/5/\(stationName)"
        //url String을 넘기면됨.
        //server로 가면서 한글이 깨지는 것을 방지하려면 adding~(withAllow~: .urlQueryAllowed)를 해주면됨.
        AF.request(urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
            //요청 후, 가져올 response
            .responseDecodable(of: StationResponseModel.self) { [weak self] response in
                //response는 1)성공, 2)실패의 두 가지 경우를 가진 열거형? 임. 이를 이용.
                guard let self = self,
                    case .success(let data) = response.result else { return }
                
//                data.stations.forEach {
//                    self.stationList.append($0)
//                }
                self.stationList = data.stations //같은 타입이니 그냥 이렇게 해주면됨. 이러면 textDidChange에서 초기화할 필요없이 data바뀌면 그 값 들어가니까!
                self.tableView.reloadData() //didSet에서 할 필요없이 여기서 바로 하는 것이 더 좋아보임.
            }
            .resume() //마지막에 이건 필수!!!!!
    }
}







/*
 <구현할 기능>
 
 1. 검색창 입력 시작
    : 검색창을 누르면 검색창에 입력된 값의 자동 검색 결과를 표시하기 위한 UITableView를 표시.
 
 2. 자동완성 기능 구현
    : 검색창에 입력된 값에 맞는 지하철 역 이름 자동완성 결과를 서버에 요청. 서버에서 받은 값을 UITableView에 표시.
 
 3. 검색창을 닫으면
    : UITableView를 숨기고, 표시하고 있던 자동완성 정보를 초기화.
 
 <기능구현을 위해 사용할 UI Components>
 
 1) UISearchController
    : UIKit의 UI컴포넌트의 종률 중 하나. UINavigationItem에 추가해서 사용해볼 예정.
    : UINavigationBar 위에 UISearchController를 올리고, UISearchBar를 설치하는 것.
    : SearchBar를 User가 선택하고 무언가 이벤트를 주었을 때, 관련 동작들을 총 관리하는 Controller.
 
 2) UITableView
    : UISearchController의 SearchBar의 상태에 따라 서버에서 받은 지하철 역 정보를 표시.
    : main화면인 "지하철 도착 정보" title의 viewController는 사실 UITableView를 가지고 있음. SearchBar가 활성화될때만 isHidden = false로 하여 나타나게 해볼 예정.
 */


/*
 <네트워크 통신 허가?>
 
 1. info.plist에 App Transport Security Settings 추가.
 2. 그 하위에 Allow Arbitrary Loads추가해서 NO -> YES로 변경.
 
 @ ATS란 App Transport Security의 약자로 2015년 iOS 9 버전부터 도입된 보안 사양이다.
 ATS는 보안에 취약한 네트워크의 연결을 차단시킨다.
 기존에 많이 쓰이던 HTTP도 마찬가지이다!
 
 HTTP프로토콜을 사용하기 위해서는 Info.plist에서 위와같이 편집해야하는 것!
 이후로 앱을 다시 빌드하여 실행해보면 HTTP 프로토콜이 연결되는 것을 볼 수 있다.
 */
