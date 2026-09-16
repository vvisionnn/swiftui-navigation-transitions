#if !os(tvOS) && !os(visionOS)
import Testing
import UIKit
@testable import UIKitNavigationTransitions

@MainActor
struct InteractionTests {
	@Test
	func preservesCustomCompletionThresholdAndSpeed() throws {
		let cases: [(percent: CGFloat, velocity: CGFloat, finishes: Bool, speed: CGFloat)] = [
			(0.49, 0, false, 0.42),
			(0.50, 0, true, 0.525),
			(0.10, 675, false, 0.50625),
			(0.10, 676, true, 0.63375),
			(0.80, -200, false, 0.42),
			(0.80, 2400, true, 0.9),
		]

		for scenario in cases {
			let controller = UINavigationController()
			controller.setNavigationTransition(.slide, interactivity: .contentPan)
			let delegate = try #require(controller.customDelegate)
			let interaction = RecordingInteraction()
			delegate.interactionController = interaction
			let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
			let gesture = EndedPanGesture()
			gesture.percent = scenario.percent
			gesture.speed = scenario.velocity
			view.addGestureRecognizer(gesture)

			controller.handleInteraction(gesture)

			#expect(interaction.finished == scenario.finishes)
			#expect(interaction.cancelled == !scenario.finishes)
			#expect(abs(interaction.completionSpeed - scenario.speed) < 0.00001)
			#expect(delegate.interactionController == nil)
		}
	}
}

@MainActor
private final class RecordingInteraction: UIPercentDrivenInteractiveTransition {
	var finished = false
	var cancelled = false

	override func finish() { finished = true }
	override func cancel() { cancelled = true }
}

@MainActor
private final class EndedPanGesture: UIPanGestureRecognizer {
	var percent: CGFloat = 0
	var speed: CGFloat = 0

	override var state: UIGestureRecognizer.State {
		get { .ended }
		set {}
	}
	override func translation(in view: UIView?) -> CGPoint {
		CGPoint(x: percent * (view?.bounds.width ?? 0), y: 0)
	}
	override func velocity(in view: UIView?) -> CGPoint {
		CGPoint(x: speed, y: 0)
	}
}
#endif
