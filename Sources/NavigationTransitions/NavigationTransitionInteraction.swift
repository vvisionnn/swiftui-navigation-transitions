import UIKit

extension UINavigationController {
	@objc func handleInteraction(_ gestureRecognizer: UIPanGestureRecognizer) {
		guard let delegate = customDelegate else {
			return
		}
		guard let gestureRecognizerView = gestureRecognizer.view else {
			delegate.interactionController = nil
			return
		}
		
		let translation = gestureRecognizer.translation(in: gestureRecognizerView).x
		let width = gestureRecognizerView.bounds.size.width
		let percent = translation / width
		
		switch gestureRecognizer.state {
		case .possible:
			break
			
		case .began:
			delegate.interactionController = UIPercentDrivenInteractiveTransition()
			popViewController(animated: true)
			delegate.interactionController?.update(percent)
			
		case .changed:
			delegate.interactionController?.update(percent)
			
		case .ended:
			let velocity = gestureRecognizer.velocity(in: gestureRecognizerView).x
			let resistance: Double = 800
			let maxSpeed: Double = 1.2
			let nominalSpeed = max(0.7, velocity / resistance)
			let speed = min(nominalSpeed, maxSpeed)
			if velocity > 675 || (percent >= 0.5 && velocity > -200) {
				delegate.interactionController?.completionSpeed = speed * 0.8
				delegate.interactionController?.finish()
			} else {
				delegate.interactionController?.completionSpeed = speed * 0.6
				delegate.interactionController?.cancel()
			}
			
			delegate.interactionController = nil
			
		case .failed, .cancelled:
			delegate.interactionController?.cancel()
			delegate.interactionController = nil
			
		@unknown default:
			break
		}
	}
}
