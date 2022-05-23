//
//  HomeViewController+UITableView.swift
//  TrackingLocation
//
//  Created by Hai Nguyen H.P. [3] VN.Danang on 5/23/22.
//

import UIKit

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")!
        var content = cell.defaultContentConfiguration()

        // Configure content.
        content.image = UIImage(systemName: "star")
        
        let location = viewModel.outputs.getLocation(at: indexPath)
        content.text = "\(location.lat), \(location.long)"
        // Customize appearance.
        content.imageProperties.tintColor = .purple

        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.outputs.numberOfRows()
    }
}
