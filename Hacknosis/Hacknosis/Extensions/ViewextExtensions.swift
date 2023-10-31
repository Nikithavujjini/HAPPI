
import SwiftUI
import Foundation

public func withOutAnimation(execute: ()->Void, completion:(()->Void)? = nil ){
    UIView.setAnimationsEnabled(false)
    UINavigationBar.setAnimationsEnabled(false)
    execute()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        UINavigationBar.setAnimationsEnabled(true)
        UIView.setAnimationsEnabled(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            completion?()
        }
    }
    
    
    /*var transaction = Transaction(animation: .linear)
    transaction.disablesAnimations = true
    withTransaction(transaction) {
        execute()
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
        completion?()
    }*/
}

extension View {
    
    /// Hide or show the view based on a boolean value.
    ///
    /// Example for visibility:
    ///
    ///     Text("Label")
    ///         .isHidden(true)
    ///
    /// Example for complete removal:
    ///
    ///     Text("Label")
    ///         .isHidden(true, remove: true)
    ///
    /// - Parameters:
    ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
    ///   - remove: Boolean value indicating whether or not to remove the view.
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
    
    /**
     The uiKit on Appear is a function that appears to be much more dependable than SwiftUI onAppear function especially in a TabView. Here's the issue this attempts to fix [https://developer.apple.com/forums/thread/655338](https://developer.apple.com/forums/thread/655338)
     */
    func uiKitOnAppear(_ perform: @escaping () -> Void) -> some View {
        self.background(UIKitAppear(action: perform))
    }
    
    func onLayoutChange(_ perform: @escaping () -> Void) -> some View {
        self.background(UIKitLayoutChange(action: perform))
    }
    
    func onViewTransition(_ perform: @escaping () -> Void) -> some View {
        self.background(UIKitTransitionChange(action: perform))
    }
    
    func uiKitOnDisAppear(_ perform: @escaping () -> Void) -> some View {
        self.background(UIKitDisAppear(action: perform))
    }
    
    /**
     Allow for custom placeholder forTextfield.
     */
    func placeholder<Content: View>(when shouldShow: Bool, alignment: Alignment = .leading, @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

extension View {
   
    
    func getCurrentOrientation(environmentOrientation: Binding<UIDeviceOrientation>) -> some View {
        modifier(UIOrientationChange(orientation: environmentOrientation))
    }
    
    func addHapticGenerator() -> some View {
        modifier(HapticFeedback())
    }
}


struct UIOrientationChange: ViewModifier {
    
    @Binding  var orientation : UIDeviceOrientation
    
    init(orientation:Binding<UIDeviceOrientation> = .constant(.portrait)) {
        self._orientation = orientation
    }
    
    func body(content: Content) -> some View {
        ZStack {
            // to recognise the orientation change
            content
                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                    if !UIDevice.current.orientation.isFlat {
                        if UIDevice.current.orientation.isValidInterfaceOrientation {
                            orientation = UIDevice.current.orientation
                        }
                    }
                }
        }
    }
}

struct HapticFeedback: ViewModifier {
    private let generator: UIImpactFeedbackGenerator
    
    init(feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle = .heavy) {
        generator = UIImpactFeedbackGenerator(style: feedbackStyle)
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .simultaneousGesture(LongPressGesture().onEnded({ _ in
                    generator.impactOccurred()
                }))
        }
    }
}

struct SimultaniousTapGestureHandler: ViewModifier {
    @Binding var isInputFocused: Bool
    
    init(isInputFocused:Binding<Bool> = .constant(false)) {
        self._isInputFocused = isInputFocused
    }
    
    
    func body(content: Content) -> some View {
        ZStack {
            if isInputFocused {
                content
            } else {
                content
                //do not remove the below block
                //added this to fix touch issue for select, date fields
                    .simultaneousGesture(TapGesture().onEnded({ _ in
                        debugPrint("tapped")
                    }))
            }
        }
    }
}

//struct ResignKeyboardOnDragGesture: ViewModifier {
//    var gesture = DragGesture().onChanged{_ in
//        UIApplication.shared.endEditing(true)
//    }
//    func body(content: Content) -> some View {
//        content.simultaneousGesture(gesture)
//    }
//}



struct UIKitAppear: UIViewControllerRepresentable {
    let action: () -> Void
    func makeUIViewController(context: Context) -> UIAppearViewController {
       let vc = UIAppearViewController()
        vc.action = action
        return vc
    }
    func updateUIViewController(_ controller: UIAppearViewController, context: Context) {
    }
}

struct UIKitDisAppear: UIViewControllerRepresentable {
    let action: () -> Void
    func makeUIViewController(context: Context) -> UIDisAppearViewController {
       let vc = UIDisAppearViewController()
        vc.action = action
        return vc
    }
    func updateUIViewController(_ controller: UIDisAppearViewController, context: Context) {
    }
}

struct UIKitLayoutChange: UIViewControllerRepresentable {
    let action: () -> Void
    func makeUIViewController(context: Context) -> UILayoutChangeViewController {
       let vc = UILayoutChangeViewController()
        vc.action = action
        return vc
    }
    func updateUIViewController(_ controller: UILayoutChangeViewController, context: Context) {
    }
}

struct UIKitTransitionChange: UIViewControllerRepresentable {
    let action: () -> Void
    func makeUIViewController(context: Context) -> UITransitionViewController {
       let vc = UITransitionViewController()
        vc.action = action
        return vc
    }
    func updateUIViewController(_ controller: UITransitionViewController, context: Context) {
    }
}

class UIAppearViewController: UIViewController {
    var action: () -> Void = {}
    override func viewDidLoad() {
        view.addSubview(UILabel())
    }
    override func viewDidAppear(_ animated: Bool) {
        action()
    }
}

class UIDisAppearViewController: UIViewController {
    var action: () -> Void = {}
    override func viewDidLoad() {
        view.addSubview(UILabel())
    }
    override func viewWillDisappear(_ animated: Bool) {
        action()
    }
}


class UILayoutChangeViewController: UIViewController {
    var action: () -> Void = {}
    override func viewDidLoad() {
        view.addSubview(UILabel())
    }
    
    override func viewDidLayoutSubviews() {
        OperationQueue.main.addOperation {
            self.action()
        }
    }
}

class UITransitionViewController: UIViewController {
    var action: () -> Void = {}
    override func viewDidLoad() {
        view.addSubview(UILabel())
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        OperationQueue.main.addOperation {
            self.action()
        }
        
    }
}

class ContentHostingController: UIHostingController<RootScreenView> {
      // 1. We change this variable
    private var currentStatusBarStyle: UIStatusBarStyle = .lightContent
      // 2. To change this property of `UIHostingController`
    override var preferredStatusBarStyle: UIStatusBarStyle {
        currentStatusBarStyle
    }
    
      // 3. A function we can call to change the style programmatically
    func changeStatusBarStyle(_ style: UIStatusBarStyle) {
        self.currentStatusBarStyle = style
          // 4. Required for view to update
        self.setNeedsStatusBarAppearanceUpdate()
    }
}


extension View {
    func cornerRadius(radius: CGFloat, corners: UIRectCorner) -> some View {
        ModifiedContent(content: self, modifier: CornerRadiusStyle(radius: radius, corners: corners))
    }
}

struct CornerRadiusStyle: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner

    struct CornerRadiusShape: Shape {

        var radius = CGFloat.infinity
        var corners = UIRectCorner.allCorners

        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            return Path(path.cgPath)
        }
    }

    func body(content: Content) -> some View {
        content
            .clipShape(CornerRadiusShape(radius: radius, corners: corners))
    }
}


extension View {
  func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Color.clear
          .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
      }
    )
    .onPreferenceChange(SizePreferenceKey.self) { values in
        DispatchQueue.main.async {
            onChange(values)
        }
    }
  }
}

private struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

//MARK: - Present a Vieew Controller -

struct ViewControllerHolder {
    weak var value: UIViewController?
}

struct ViewControllerKey: EnvironmentKey {
    static var defaultValue: ViewControllerHolder {
        return ViewControllerHolder(value: UIApplication.shared.windows.first?.rootViewController)
    }
    
    static var presentedValue: ViewControllerHolder {
        return ViewControllerHolder(value: UIApplication.shared.windows.first?.rootViewController?.presentedViewController)
    }
}


extension EnvironmentValues {
    var viewController: UIViewController? {
        get { return self[ViewControllerKey.self].value }
        set { self[ViewControllerKey.self].value = newValue }
    }
    
    var presentedViewController: UIViewController? {
        get { return ViewControllerKey.presentedValue.value }
    }
}

extension UIViewController {
    func present<Content: View>(on viewController:UIViewController? = nil,
                                backgroundColor:UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5),
                                style: UIModalPresentationStyle = .overCurrentContext,
                                shouldAnimate:Bool = true,
                                transitionStyle: UIModalTransitionStyle = .coverVertical,
                                @ViewBuilder builder: () -> Content) {
        let toPresent = PresentedHostingController(rootView: AnyView(EmptyView()))
        toPresent.modalPresentationStyle = style
        toPresent.modalTransitionStyle = transitionStyle
        toPresent.view.backgroundColor = backgroundColor
        toPresent.rootView = AnyView(
            builder()
                //.environment(\.viewController, toPresent)
        )
        if let viewController {
            viewController.present(toPresent, animated: shouldAnimate, completion: nil)
        } else {
            self.present(toPresent, animated: shouldAnimate, completion: nil)
        }
    }
        
}

class PresentedHostingController: UIHostingController<AnyView> {
    private var currentStatusBarStyle: UIStatusBarStyle = .lightContent

    override var preferredStatusBarStyle: UIStatusBarStyle {
        currentStatusBarStyle
    }
    
    func changeStatusBarStyle(_ style: UIStatusBarStyle) {
        self.currentStatusBarStyle = style
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLayoutSubviews() {
        if let window = UIApplication.shared.windows.first {
            if UIDevice.isIPhone {
                view.frame = CGRect(x: 0, y: 0, width: window.bounds.size.width, height: window.bounds.size.height)
            } else {
                view.frame = CGRect(x: 0, y: window.safeAreaInsets.top, width: window.bounds.size.width, height: window.bounds.size.height - window.safeAreaInsets.top)
            }
        }
    }
    
}

extension UIView {
    func superview<T>(of type: T.Type) -> T? {
        return superview as? T ?? superview?.superview(of: type)
    }
}
