//
//  Async.swift
//
//  The MIT License (MIT)
//  Copyright (c) 2014 Tobias Due Munk
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import SwiftUI

private struct Char: Identifiable {
    var id: String { "\(index) \(char)" }

    let index: Int
    let char: Character
}

extension Char {
    var string: String { "\(char)" }
}

struct TextViewSizeKey: PreferenceKey {
    typealias Value = [CGSize]

    static var defaultValue: [CGSize] { [] }
    static func reduce(value: inout [CGSize], nextValue: () -> [CGSize]) {
        value.append(contentsOf: nextValue())
    }
}

struct PropagateSize<V: View>: View {
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

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

public struct CrookedText: View {

    public enum Position {
        case inside, center, outside
    }

    public let text: String
    public let radius: CGFloat
    public let alignment: Position

    private var textModifier: (Text) -> Text
    private var spacing: CGFloat = 0

    @State private var sizes: [CGSize] = []

    public init(text: String,
                radius: CGFloat,
                alignment: Position = .center,
                textModifier: @escaping (Text) -> Text = { $0 }) {
        self.text = text
        self.radius = radius
        self.alignment = alignment
        self.textModifier = textModifier
    }

    private func textRadius(at index: Int) -> CGFloat {
        switch alignment {
        case .inside:
            return radius - size(at: index).height / 2
        case .center:
            return radius
        case .outside:
            return radius + size(at: index).height / 2
        }
    }

    public var body: some View {
        VStack {
            ZStack {
                ForEach(chars()) { item in
                    PropagateSize {
                        self.textView(char: item)
                    }
                    .frame(width: self.size(at: item.index).width,
                           height: self.size(at: item.index).height)
                    .offset(x: 0,
                            y: -self.textRadius(at: item.index))
                    .rotationEffect(self.angle(at: item.index))
                }
            }
            .frame(width: radius * 2, height: radius * 2)
            .onPreferenceChange(TextViewSizeKey.self) { sizes in
                self.sizes = sizes
            }
        }
        .accessibility(label: Text(text))
    }

    private func chars() -> [Char] {
        text.enumerated().map(Char.init)
    }

    private func textView(char: Char) -> some View {
        textModifier(Text(char.string))
    }

    private func size(at index: Int) -> CGSize {
        sizes[safe: index] ?? CGSize(width: 1000000, height: 0)
    }

    private func angle(at index: Int) -> Angle {
        let arcSpacing = Double(spacing / radius)
        let letterWidths = sizes.map { $0.width }
        let prevWidth =
            index < letterWidths.count ?
            letterWidths.dropLast(letterWidths.count - index).reduce(0, +) :
            0
        let prevArcWidth = Double(prevWidth / radius)
        let totalArcWidth = Double(letterWidths.reduce(0, +) / radius)
        let prevArcSpacingWidth = arcSpacing * Double(index)
        let arcSpacingOffset = -arcSpacing * Double(letterWidths.count - 1) / 2
        let charWidth = letterWidths[safe: index] ?? 0
        let charOffset = Double(charWidth / 2 / radius)
        let arcCharCenteringOffset = -totalArcWidth / 2
        let charArcOffset = prevArcWidth + charOffset + arcCharCenteringOffset + arcSpacingOffset + prevArcSpacingWidth
        return Angle(radians: charArcOffset)
    }
}

extension CrookedText {
    public func kerning(_ kerning: CGFloat) -> CrookedText {
        var copy = self
        copy.spacing = kerning
        return copy
    }

    public func italic() -> CrookedText {
        var copy = self
        copy.textModifier = {
            self.textModifier($0)
                .italic()
        }
        return copy
    }

    public func bold() -> CrookedText {
        fontWeight(.bold)
    }

    public func fontWeight(_ weight: Font.Weight?) -> CrookedText {
        var copy = self
        copy.textModifier = {
            self.textModifier($0)
                .fontWeight(weight)
        }
        return copy
    }

    public func baselineOffset(_ offset: CGFloat) -> CrookedText {
        var copy = self
        copy.textModifier = {
            self.textModifier($0)
                .baselineOffset(offset)
        }
        return copy
    }

    public func underline(_ active: Bool = true, color: Color? = nil) -> CrookedText {
        var copy = self
        copy.textModifier = {
            self.textModifier($0)
                .underline(active, color: color)
        }
        return copy
    }

    public func strikethrough(_ active: Bool = true, color: Color? = nil) -> CrookedText {
        var copy = self
        copy.textModifier = {
            self.textModifier($0)
                .strikethrough(active, color: color)
        }
        return copy
    }

//    public func legibillityWeighted(regular: Font.Weight, bold: Font.Weight) -> some View {
//        var copy = self
//        copy.textModifier = {
//            self.textModifier($0)
//                .legibillityWeighted(regular: regular, bold: bold)
//        }
//        return copy
//    }
}
