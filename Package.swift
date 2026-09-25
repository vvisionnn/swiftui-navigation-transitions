// swift-tools-version: 6.2

import PackageDescription

// xctest-dynamic-overlay was renamed to swift-issue-reporting. Both URLs declare an
// `IssueReporting` target and cannot coexist in one graph, and the Point-Free ecosystem
// only moves to the new URL from Swift 6.4 on, so follow the same split.
#if compiler(>=6.4)
let issueReportingPackage: Package.Dependency = .package(
	url: "https://github.com/pointfreeco/swift-issue-reporting", from: "2.1.0"
)
let issueReportingProduct: Target.Dependency = .product(
	name: "IssueReporting", package: "swift-issue-reporting"
)
#else
let issueReportingPackage: Package.Dependency = .package(
	url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.0.0"
)
let issueReportingProduct: Target.Dependency = .product(
	name: "IssueReporting", package: "xctest-dynamic-overlay"
)
#endif

let package = Package(
	name: "swiftui-navigation-transitions",
	platforms: [
		.iOS(.v13),
		.macCatalyst(.v13),
		.tvOS(.v13),
		.visionOS(.v1),
	],
	products: [
		.library(name: "SwiftUINavigationTransitions", targets: ["SwiftUINavigationTransitions"]),
		.library(name: "UIKitNavigationTransitions", targets: ["UIKitNavigationTransitions"]),
	],
	targets: [
		.target(name: "Animation"),

		.target(name: "Animator"),
		.testTarget(name: "AnimatorTests", dependencies: [
			"Animator",
			"TestUtils",
		]),

		.target(name: "AtomicTransition", dependencies: [
			"Animator",
		]),
		.testTarget(name: "AtomicTransitionTests", dependencies: [
			"AtomicTransition",
			"TestUtils",
		]),

		.target(name: "NavigationTransition", dependencies: [
			"Animation",
			"AtomicTransition",
			issueReportingProduct,
		]),

		.target(name: "UIKitNavigationTransitions", dependencies: [
			issueReportingProduct,
			"NavigationTransition",
			.product(name: "ObjCRuntimeTools", package: "objc-runtime-tools"),
			.product(name: "Once", package: "swift-once-macro"),
		]),
		.testTarget(name: "UIKitNavigationTransitionsTests", dependencies: [
			"UIKitNavigationTransitions",
		]),

		.target(name: "SwiftUINavigationTransitions", dependencies: [
			"UIKitNavigationTransitions",
			.product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
		]),

		.target(name: "TestUtils", dependencies: [
			.product(name: "CustomDump", package: "swift-custom-dump"),
			issueReportingProduct,
			"SwiftUINavigationTransitions",
		]),
	],
)

// MARK: Dependencies

package.dependencies = [
	.package(url: "https://github.com/davdroman/objc-runtime-tools", from: "0.1.0"),
	.package(url: "https://github.com/davdroman/swift-once-macro", from: "1.0.0"),
	.package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.0.0"), // dev
	issueReportingPackage,
	.package(url: "https://github.com/siteline/swiftui-introspect", "26.0.0"..<"28.0.0-beta"),
]

for target in package.targets {
	target.swiftSettings = target.swiftSettings ?? []
	target.swiftSettings? += [
		.enableUpcomingFeature("ExistentialAny"),
		.enableUpcomingFeature("ImmutableWeakCaptures"),
		.enableUpcomingFeature("InferIsolatedConformances"),
		.enableUpcomingFeature("InternalImportsByDefault"),
		.enableUpcomingFeature("MemberImportVisibility"),
		.enableUpcomingFeature("NonisolatedNonsendingByDefault"),
	]
}
