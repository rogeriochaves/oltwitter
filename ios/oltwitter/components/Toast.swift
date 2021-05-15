//
//  Toast.swift
//  oltwitter
//
//  Created by Rogerio Chaves on 15/05/21.
//

import SwiftUI

struct Toast: View {
    struct ToastDataModel {
        var title:String
        var image:String
    }
    let dataModel: ToastDataModel
    @Binding var show: Bool

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Image(systemName: dataModel.image)
                Text(dataModel.title)
            }.font(.headline)
            .foregroundColor(.primary)
            .padding([.top,.bottom], 20)
            .padding([.leading,.trailing], 20)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(Capsule())
        }
        .frame(width: UIScreen.main.bounds.width / 1.25)
        .padding(.bottom, 60)
        .transition(AnyTransition.move(edge: .bottom).combined(with: .opacity))
        .onTapGesture {
            withAnimation {
                self.show = false
            }
        }
    }
}

struct Overlay<T: View>: ViewModifier {

    @Binding var show: Bool
    let overlayView: T

    func body(content: Content) -> some View {
        ZStack {
            content
            if show {
                overlayView
            }
        }
    }
}

extension View {
    func overlay<T: View>( overlayView: T, show: Binding<Bool>) -> some View {
        self.modifier(Overlay.init(show: show, overlayView: overlayView))
    }
}
