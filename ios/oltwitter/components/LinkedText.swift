//
//  LinkedText.swift
//  oltwitter
//
//  Base: https://gist.github.com/mjm/0581781f85db45b05e8e2c5c33696f88
//

import UIKit
import SwiftUI
import SwifteriOS
import SafariServices

private let tcoDetector = try! NSRegularExpression(pattern: "(https://t.co/[A-Z0-9-_]+)", options: .caseInsensitive)
private let mentionsDetector = try! NSRegularExpression(pattern: "(\\s|^)@([A-Z0-9-_]+)", options: .caseInsensitive)
private let hashtagsDetector = try! NSRegularExpression(pattern: "(\\s|^)#([A-Z0-9-_]+)", options: .caseInsensitive)

struct LinkColoredText: View {
    enum Component {
        case text(String)
        case link(String)
    }

    let text: String
    let components: [Component]

    init(text: String, links: [LinkedResult]) {
        self.text = text
        let nsText = text as NSString

        var components: [Component] = []
        var index = 0
        for (_, result) in links {
            if result.range.location > index {
                components.append(.text(nsText.substring(with: NSRange(location: index, length: result.range.location - index))))
            }
            components.append(.link(nsText.substring(with: result.range)))
            index = result.range.location + result.range.length
        }

        if index < nsText.length {
            components.append(.text(nsText.substring(from: index)))
        }

        self.components = components
    }

    var body: some View {
        components.map { component in
            switch component {
            case .text(let text):
                return Text(verbatim: text)
            case .link(let text):
                return Text(verbatim: text)
                    .foregroundColor(Styles.blueText)
            }
        }.reduce(Text(""), +)
    }
}

enum LinkedType {
    case browserLink(URL)
    case embededLink(URL)
    case mentionLink
    case hashtagLink
}

typealias LinkedResult = (LinkedType, NSTextCheckingResult)

struct LinkedText: View {
    let text: String
    let links: [LinkedResult]
    @State var isLinkActive: Bool = false
    @State var destination : AnyView = AnyView(EmptyView())

    init (_ text: String, _ tweet: JSON) {
        // Replacing
        var displayText = String(text)
        let urls = tweet["entities"]["urls"].array ?? []
        for url in urls {
            if let url_: String = url["url"].string,
               let displayUrl: String = url["display_url"].string {
                displayText = displayText.replacingOccurrences(of: url_, with: displayUrl, options: .literal)
            }
        }
        let medias = tweet["entities"]["media"].array ?? []
        for media in medias {
            if let url: String = media["url"].string,
               let displayUrl: String = media["display_url"].string {
                displayText = displayText.replacingOccurrences(of: url, with: displayUrl, options: .literal)
            }
        }
        self.text = displayText

        // Matching links
        let nsText = displayText as NSString
        let wholeString = NSRange(location: 0, length: nsText.length)

        var links: [LinkedResult] = []
        links += mentionsDetector.matches(in: displayText, options: [], range: wholeString).map { (.mentionLink, $0) }
        links += hashtagsDetector.matches(in: displayText, options: [], range: wholeString).map { (.hashtagLink, $0) }
        links += tcoDetector.matches(in: displayText, options: [], range: wholeString).compactMap {
            let result = nsText.substring(with: $0.range)
            if let url = URL(string: result) {
                return (LinkedType.browserLink(url), $0)
            }
            return nil
        }

        for url in urls {
            if let displayUrl = url["display_url"].string,
               let expandedUrl = url["expanded_url"].string,
               let expandedUrl_ = URL(string: expandedUrl) {

                do {
                    let re = try NSRegularExpression(pattern: NSRegularExpression.escapedPattern(for: displayUrl))
                    links += re.matches(in: displayText, options: [], range: wholeString).map { (.browserLink(expandedUrl_), $0) }
                } catch {
                    // ignore
                }
            }
        }
        for media in medias {
            if let displayUrl = media["display_url"].string,
               let expandedUrl = media["media_url_https"].string,
               let expandedUrl_ = URL(string: expandedUrl) {

                do {
                    let re = try NSRegularExpression(pattern: NSRegularExpression.escapedPattern(for: displayUrl))
                    links += re.matches(in: displayText, options: [], range: wholeString).map { (.embededLink(expandedUrl_), $0) }
                } catch {
                    // ignore
                }
            }
        }
        links = links.sorted(by: { (a, b) -> Bool in
            a.1.range.lowerBound < b.1.range.lowerBound
        })
        self.links = links
    }

    func changeRoute(view: AnyView) {
        self.destination = view
        self.isLinkActive = true
    }

    var body: some View {
        ZStack {
            LinkColoredText(text: text, links: links)
                .font(.system(size: Styles.tweetFontSize))
                .overlay(LinkTapOverlay(text: text, links: links, changeRoute: changeRoute))

            NavigationLink(destination: destination, isActive: $isLinkActive) {
                Text("")
            }
        }
    }
}

private struct LinkTapOverlay: UIViewRepresentable {
    typealias UIViewType = LinkTapOverlayView

    let text: String
    let links: [LinkedResult]
    let changeRoute : (AnyView) -> Void

    func makeUIView(context: UIViewRepresentableContext<LinkTapOverlay>) -> LinkTapOverlayView {
        let view = LinkTapOverlayView()
        view.textContainer = context.coordinator.textContainer

        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.didTapLabel(_:)))
        let forceTouchGestureRecognizer = ForceTouchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.didForceTouchLabel(_:)))
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.didLongPressLabel(_:)))

        view.addGestureRecognizer(tapGesture)
        view.addGestureRecognizer(forceTouchGestureRecognizer)
        view.addGestureRecognizer(longPressGestureRecognizer)

        return view
    }

    func updateUIView(_ uiView: LinkTapOverlayView, context: UIViewRepresentableContext<LinkTapOverlay>) {
        let attributedString = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: Styles.tweetFontSize)])
        context.coordinator.textStorage = NSTextStorage(attributedString: attributedString)
        context.coordinator.textStorage!.addLayoutManager(context.coordinator.layoutManager)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        let overlay: LinkTapOverlay

        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: .zero)
        var textStorage: NSTextStorage?

        init(_ overlay: LinkTapOverlay) {
            self.overlay = overlay

            textContainer.lineFragmentPadding = 0
            textContainer.lineBreakMode = .byWordWrapping
            textContainer.maximumNumberOfLines = 0
            layoutManager.addTextContainer(textContainer)
        }

        enum LinkedUrl {
            case browser(URL)
            case embeded(URL)
            case mention(String)
        }

        func getUrl(_ location: CGPoint) -> LinkedUrl? {
            if let (type, result) = link(at: location) {
                let stringMatch = textStorage?.attributedSubstring(from: result.range).string.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "") ?? ""

                switch type {
                case let .browserLink(url_):
                    return .browser(url_)
                case let .embededLink(url_):
                    return .embeded(url_)
                case .mentionLink:
                    return .mention(stringMatch.replacingOccurrences(of: "@", with: ""))
                case .hashtagLink:
                    return .browser(URL(string: "https://twitter.com/hashtag/" + stringMatch.replacingOccurrences(of: "#", with: ""))!)
                }
            }

            return nil
        }

        @objc func didTapLabel(_ gesture: UITapGestureRecognizer) {
            let location = gesture.location(in: gesture.view!)
            guard let url = getUrl(location) else { return }

            switch url {
            case .browser(let url_):
                UIApplication.shared.open(url_, options: [:], completionHandler: nil)
            case .embeded(let url_):
                let embededBrowser = SFSafariViewController(url: url_)
                UIApplication.topViewController?.present(embededBrowser, animated: true)
            case .mention(let screenName):
                self.overlay.changeRoute(
                    AnyView(ProfileScreen(screenName: screenName))
                )
            }
        }

        @objc func didForceTouchLabel(_ gesture: ForceTouchGestureRecognizer) {
            let location = gesture.location(in: gesture.view!)
            guard let url = getUrl(location) else { return }

            if case let .browser(url_) = url {
                UIApplication.share(url_)
            }
        }

        @objc func didLongPressLabel(_ gesture: UILongPressGestureRecognizer) {
            let location = gesture.location(in: gesture.view!)
            guard let url = getUrl(location) else { return }

            if case let .browser(url_) = url {
                UIApplication.share(url_)
            }
        }

        private func link(at point: CGPoint) -> LinkedResult? {
            guard !overlay.links.isEmpty else {
                return nil
            }

            let indexOfCharacter = layoutManager.characterIndex(
                for: point,
                in: textContainer,
                fractionOfDistanceBetweenInsertionPoints: nil
            )

            return overlay.links.first { (_, result) in result.range.contains(indexOfCharacter) }
        }
    }
}

private class LinkTapOverlayView: UIView {
    var textContainer: NSTextContainer!

    override func layoutSubviews() {
        super.layoutSubviews()

        var newSize = bounds.size
        newSize.height += 20 // need some extra space here to actually get the last line
        textContainer.size = newSize
    }
}

import UIKit.UIGestureRecognizerSubclass

final class ForceTouchGestureRecognizer: UIGestureRecognizer {

    private let threshold: CGFloat = 0.75

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first {
            handleTouch(touch)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        if let touch = touches.first {
            handleTouch(touch)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        state = UIGestureRecognizer.State.failed
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        state = UIGestureRecognizer.State.failed
    }

    private func handleTouch(_ touch: UITouch) {
        guard touch.force != 0 && touch.maximumPossibleForce != 0 else { return }

        if touch.force / touch.maximumPossibleForce >= threshold {
            state = UIGestureRecognizer.State.recognized
        }
    }

}
