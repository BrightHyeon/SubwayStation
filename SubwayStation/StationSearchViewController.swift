//
//  StationSearchViewController.swift
//  SubwayStation
//
//  Created by HyeonSoo Kim on 2022/03/02.
//

import UIKit
import SnapKit

class StationSearchViewController: UIViewController {

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
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
}

//MARK: - UISearchBar Delegate
//user의 행동을 입력받는 객체들은 대부분 delegate프로토콜을 가지고 있음. ex) UITextField, UITextView 등등.
extension StationSearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tableView.isHidden = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        tableView.isHidden = true
    }
}

//MARK: - private extension
private extension StationSearchViewController {
    
    //UINavigationBar & UISearchController Settings
    func setupNavigationBar() {
        
        self.navigationItem.title = "지하철 도착 정보"
        self.navigationItem.hidesSearchBarWhenScrolling = false
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

