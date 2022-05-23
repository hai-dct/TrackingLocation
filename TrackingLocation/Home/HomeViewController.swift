//
//  HomeViewController.swift
//  TrackingLocation
//
//  Created by Hai Nguyen H.P. [3] VN.Danang on 5/23/22.
//

import UIKit
import RxSwift
import RxCocoa
import MapKit

final class HomeViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        }
    }
    @IBOutlet private weak var segmentControl: UISegmentedControl!
    @IBOutlet private weak var mapKit: MKMapView!
    
    var viewModel: HomeViewModel!
    let disposeBag: DisposeBag = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        viewModel.inputs.viewDidLoad.accept(())
    }
    
    private func setupUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(rightBarButtonTouchUpInside))
    }
    
    private func bind() {
        NotificationCenter.default.rx
            .notification(UIApplication.didBecomeActiveNotification, object: nil)
            .map { _ in Void() }
            .bind(to: viewModel.inputs.didBecomeActive)
            .disposed(by: disposeBag)
        
        segmentControl.rx.controlEvent(.valueChanged)
            .compactMap { [segmentControl] in segmentControl?.selectedSegmentIndex }
            .bind(to: viewModel.inputs.segmentValueChanged)
            .disposed(by: disposeBag)

        viewModel.outputs.reloadTableView
            .subscribe(onNext: { [tableView] in
                tableView?.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.showList
            .subscribe(onNext: { [mapKit, tableView] in
                mapKit?.isHidden = true
                tableView?.isHidden = false
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.showMap
            .subscribe(onNext: { [mapKit, tableView] in
                mapKit?.isHidden = false
                tableView?.isHidden = true
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.segmentTitles
            .subscribe(onNext: { [segmentControl] titles in
                for (index, item) in titles.enumerated() {
                    segmentControl?.setTitle(item, forSegmentAt: index)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.showTitle
            .bind(to: rx.title)
            .disposed(by: disposeBag)
        
        viewModel.outputs.points
            .map { values -> [MKPointAnnotation] in
                values.map {
                    let point = MKPointAnnotation()
                    point.coordinate = $0
                    return point
                }
            }
            .subscribe(onNext: { [mapKit] annotations in
                guard let annotationCurrent = mapKit?.annotations else { return }
                mapKit?.removeAnnotations(annotationCurrent)
                mapKit?.addAnnotations(annotations)
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func rightBarButtonTouchUpInside() {
        viewModel.inputs.clearData.accept(())
    }
}
