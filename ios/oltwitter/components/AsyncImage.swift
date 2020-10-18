//
//  AsyncImage.swift
//  oltwitter
//
//  Created by Rogerio Chaves on 18/10/20.
//

import SwiftUI
import Foundation

struct AsyncImage: View {
    @ObservedObject var imageLoader : ImageLoader
    let url : String?

    init(url: String?, imageLoader: ImageLoader) {
        self.url = url
        self.imageLoader = imageLoader
        if let url_ = url {
            imageLoader.load(url: url_)
        }
    }

    var body: some View {
        if let url_ = url, let image = imageLoader.images[url_] {
            return AnyView(Image(uiImage: image)
                .renderingMode(.original)
                .resizable())
        } else {
            return AnyView(Image("egg-avatar")
                .renderingMode(.original)
                .resizable())
        }
    }
}
