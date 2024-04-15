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
    private var isOnlineState: Bool = false

    init(onNetworkAvailable: @escaping () -> Void, onNetworkAbsent: @escaping () -> Void) {

        isOnlineState = monitor.currentPath.status == .satisfied

        monitor.pathUpdateHandler = { [weak self] path in
            if path.status == .satisfied {

                self?.isOnlineState = true

                onNetworkAvailable()

            } else {
                self?.isOnlineState = false
                onNetworkAbsent()
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }

    func isOnline() -> Bool {
        return isOnlineState
    }
}
