import SwiftUI

internal struct TextViewSizeKey: PreferenceKey {
    typealias Value = [CGSize]
    static var defaultValue: [CGSize] { [] }
    static func reduce(value: inout [CGSize], nextValue: () -> [CGSize]) {
        value.append(contentsOf: nextValue())
    }
}

internal struct PropagateSize<V: View>: View {
    var content: () -> V
    var body: some View {
        GeometryReader { proxy in
            self.content()
                .background(GeometryReader { proxy in
                    Color.clear.preference(key: TextViewSizeKey.self, value: [proxy.size])
                })
        }
    }
}
