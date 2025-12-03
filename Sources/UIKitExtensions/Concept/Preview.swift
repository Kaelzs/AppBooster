//
//  Preview.swift
//  AppBooster
//
//  Created by Kael on 9/23/25.
//

#if canImport(SwiftUI)
#if os(iOS)
import SwiftUI

struct PreviewControllerContainer<T: UIViewController>: UIViewControllerRepresentable {
    let viewController: T

    init(_ viewControllerBuilder: @autoclosure @escaping () -> T) {
        viewController = viewControllerBuilder()
    }

    func makeUIViewController(context: Context) -> T {
        return viewController
    }

    func updateUIViewController(_ uiViewController: T, context: Context) {}
}

struct PreviewViewContainer<T: UIView>: UIViewRepresentable {
    let view: T

    public init(_ viewBuilder: @autoclosure @escaping () -> T) {
        view = viewBuilder()
    }

    public func makeUIView(context: Context) -> some UIView {
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return view
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {}
}

public extension UIViewController {
    @MainActor
    func toPreview() -> some View {
        PreviewControllerContainer(self)
    }
}

public extension UIView {
    @MainActor
    func toPreview() -> some View {
        PreviewViewContainer(self)
    }

    @MainActor
    func toPreview(size: CGSize) -> some View {
        let vc = UIViewController(nibName: nil, bundle: nil)
        vc.view.addSubview(self)

        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size.width),
            heightAnchor.constraint(equalToConstant: size.height),
            centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
        ])

        return vc.toPreview().frame(width: size.width, height: size.height)
    }
}

#endif
#endif
