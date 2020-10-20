//
//  Styles.swift
//  oltwitter
//
//  Created by Rogerio Chaves on 18/10/20.
//

import SwiftUI

class Styles {
    static var gray = Color(
        red: 0.6,
        green: 0.6,
        blue: 0.6
    )
    static var linkBlue = Color(
        red: 33 / 255,
        green: 110 / 255,
        blue: 150 / 255
    )

    static var blueText = Color(red: 56 / 255, green: 68 / 255, blue : 152 / 255)

    static var lightestBlue = Color(red: 242 / 255, green: 255 / 255, blue: 255 / 255)

    static var lightBlue = Color(red: 115 / 255, green: 213 / 255, blue: 255 / 255)

    // This will be black on dark mode
    static var white = Color(UIColor.systemBackground)

    // This will be white on dark mode
    static var black = Color(UIColor.label)

    static var tweetFontSize : CGFloat = 16
}
