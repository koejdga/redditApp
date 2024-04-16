//
//  NetworkChecker.swift
//  RedditApp
//
//  Created by Соня Буділова on 15.04.2024.
//

import Foundation
import Network

class NetworkChecker {
    private let monitor = NWPathMonitor()

    init(onNetworkAvailable: @escaping () -> Void, onNetworkAbsent: @escaping () -> Void) {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                onNetworkAvailable()

            } else {
                onNetworkAbsent()
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
}
