//
//  SearchScreen.swift
//  oltwitter
//
//  Created by Rogerio Chaves on 24/10/20.
//

import SwiftUI

struct SearchScreen: View {
    @State private var query = ""

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")

                TextField("search", text: $query, onCommit: {
                    if let q = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
                       let url = URL(string: "https://twitter.com/search?q=\(q)") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }

                })
                    .foregroundColor(.primary)
                    .keyboardType(.webSearch)

                Button(action: {
                    self.query = ""
                }) {
                    Image(systemName: "xmark.circle.fill").opacity(query == "" ? 0 : 1)
                }
            }
            .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
            .foregroundColor(.secondary)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10.0)
            .padding(.top, 20)
            Spacer()
        }
        .padding(.horizontal)
        .navigationBarTitle("Search", displayMode: .inline)
    }
}

struct SearchScreen_Previews: PreviewProvider {
    static var previews: some View {
        SearchScreen()
    }
}
