//
//  NavigationBar.swift
//  Seknova-Practice
//
//  Created by imac-2627 on 2025/10/7.
//

import UIKit

struct NavigationBar {

    static func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Color.mainRed
        
        appearance.titleTextAttributes = [
            .foregroundColor: Color.mainWhite,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        

        let barButtonItemAppearance = UIBarButtonItemAppearance()
        barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: Color.mainWhite]
        barButtonItemAppearance.highlighted.titleTextAttributes = [.foregroundColor: Color.mainWhite]
        
        appearance.buttonAppearance = barButtonItemAppearance
        appearance.backButtonAppearance = barButtonItemAppearance
        

        let navBar = UINavigationBar.appearance()
        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
        navBar.compactAppearance = appearance
        navBar.tintColor = Color.mainWhite 
    }
}
