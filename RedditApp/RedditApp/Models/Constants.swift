//
//  ColorExtension.swift
//  RedditApp
//
//  Created by Соня Буділова on 16.04.2024.
//

import Foundation
import SwiftUI

extension Color {
    static let ui = Color.UI()

    struct UI {
        let theme = Color("ThemeColor")
        let grey = Color("GreyColor")
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case notDecoded
}
