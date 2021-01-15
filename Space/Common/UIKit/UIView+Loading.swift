import Lottie
import UIKit

protocol LoadableView {
    var loadingView: AnimationView { get }

    func set(loading: Bool)
}

extension LoadableView {
    var isLoading: Bool {
        get { loadingView.isAnimationPlaying }
        set { set(loading: newValue) }
    }

    func set(loading: Bool) {
        if loading {
            loadingView.alpha = 1
            loadingView.play()
        } else {
            loadingView.alpha = 0
            loadingView.stop()
        }
    }
}

extension LoadableView {
    func makeLoadingView(in superview: UIView) -> AnimationView {
        let animationView: AnimationView = .init()
        animationView.isUserInteractionEnabled = false
        animationView.loopMode = .loop
        animationView.animation = Animations.earthMoon
        animationView.backgroundBehavior = .pauseAndRestore

        superview.addSubview(animationView)
        animationView.snap(to: superview)

        return animationView
    }
}
