//
//  Styles.swift
//  oltwitter
//
//  Created by Rogerio Chaves on 18/10/20.
//

import SwiftUI

class Styles {
    static let gray = Color(
        red: 0.6,
        green: 0.6,
        blue: 0.6
    )

    static let blueText = Color(UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
        if UITraitCollection.userInterfaceStyle == .dark {
            return UIColor(red: 125 / 255, green: 223 / 255, blue: 255 / 255, alpha: 1)
        } else {
            return UIColor(red: 36 / 255, green: 98 / 255, blue : 152 / 255, alpha: 1)
        }
    })

    static let lightestBlue = Color(UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
        if UITraitCollection.userInterfaceStyle == .dark {
            return UIColor(red: 0 / 255, green: 130 / 255, blue: 190 / 255, alpha: 1)
        } else {
            return UIColor(red: 242 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1)
        }
    })

    static let uiLightBlue = UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
        if UITraitCollection.userInterfaceStyle == .dark {
            return UIColor(red: 30 / 255, green: 160 / 255, blue: 220 / 255, alpha: 1)
        } else {
            return UIColor(red: 105 / 255, green: 203 / 255, blue: 245 / 255, alpha: 1)
        }
    }

    static let lightBlue = Color(uiLightBlue)

    // This will be black on dark mode
    static let white = Color(UIColor.systemBackground)

    // This will be white on dark mode
    static let black = Color(UIColor.label)

    static let tweetFontSize : CGFloat = 16
}
