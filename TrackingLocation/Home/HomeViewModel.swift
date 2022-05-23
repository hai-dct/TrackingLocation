// 
//  HomeViewModel.swift
//  TrackingLocation
//
//  Created by Hai Nguyen H.P. [3] VN.Danang on 5/23/22.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation

// MARK: - I/O Protocols
protocol HomeViewModelInputs {
    var viewDidLoad: PublishRelay<Void> { get }
    var didBecomeActive: PublishRelay<Void> { get }
    var segmentValueChanged: PublishRelay<Int> { get }
    var clearData: PublishRelay<Void> { get }
}

protocol HomeViewModelOutputs {
    func numberOfRows() -> Int
    func getLocation(at indexPath: IndexPath) -> Location
    var reloadTableView: PublishRelay<Void> { get }
    var showMap: PublishRelay<Void> { get }
    var showList: PublishRelay<Void> { get }
    var segmentTitles: PublishRelay<[String]> { get }
    var showTitle: PublishRelay<String> { get }
    var points: PublishRelay<[CLLocationCoordinate2D]> { get }
}

protocol HomeViewModel {
    var inputs: HomeViewModelInputs { get }
    var outputs: HomeViewModelOutputs { get }
}

// MARK: - Interface
extension DefaultHomeViewModel: HomeViewModel {
    var inputs: HomeViewModelInputs { self }
    var outputs: HomeViewModelOutputs { self }
}

final class DefaultHomeViewModel: HomeViewModelInputs, HomeViewModelOutputs {
    
    // MARK: - Inputs
    let viewDidLoad: PublishRelay<Void> = .init()
    let didBecomeActive: PublishRelay<Void> = .init()
    let segmentValueChanged: PublishRelay<Int> = .init()
    let clearData: PublishRelay<Void> = .init()
    
    // MARK: - Outputs
    let reloadTableView: PublishRelay<Void> = .init()
    let showMap: PublishRelay<Void> = .init()
    let showList: PublishRelay<Void> = .init()
    let segmentTitles: PublishRelay<[String]> = .init()
    let showTitle: PublishRelay<String> = .init()
    let points: PublishRelay<[CLLocationCoordinate2D]> = .init()
    
    // MARK: - Private Properties
    private var locations: BehaviorRelay<[Location]> = .init(value: [])
    private var disposeBag = DisposeBag()
    
    init() {
        bind()
    }
    
    private func bind() {
        viewDidLoad
            .do(onNext: { [weak self] in
                self?.fetchData()
                self?.segmentTitles.accept(["List", "Map"])
                self?.showList.accept(())
                self?.showTitle.accept("Home")
            })
            .bind(to: reloadTableView)
            .disposed(by: disposeBag)
        
        didBecomeActive
            .do(onNext: { [weak self] in
                self?.fetchData()
            })
            .bind(to: reloadTableView)
            .disposed(by: disposeBag)
                
        segmentValueChanged
            .filter { $0 == 0 }
            .map { _ in () }
            .bind(to: showList)
            .disposed(by: disposeBag)
        
        segmentValueChanged
            .filter { $0 == 1 }
            .map { _ in () }
            .bind(to: showMap)
            .disposed(by: disposeBag)
        
        locations
            .map { values in
                values.map { CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.long) }
            }
            .bind(to: points)
            .disposed(by: disposeBag)
        
        clearData
            .do(onNext: { [weak self] in
                Session.shared.locationsSaved = []
                self?.fetchData()
            })
            .bind(to: reloadTableView)
            .disposed(by: disposeBag)
    }
    
    private func fetchData() {
        locations.accept(Session.shared.locationsSaved)
    }
    
    func numberOfRows() -> Int {
        return locations.value.count
    }
    
    func getLocation(at indexPath: IndexPath) -> Location {
        return locations.value[indexPath.row]
    }
}

struct Location: Codable {
    var lat, long: Double
}
