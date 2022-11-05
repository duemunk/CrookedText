//
//  CrookedText.swift
//
//  The MIT License (MIT)
//  Copyright (c) 2019 Tobias Due Munk
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

public struct CrookedText: View {

    public enum Position {
        case inside, center, outside
    }

    public let text: String
    public let radius: CGFloat
    public let alignment: Position

    internal var textModifier: (Text) -> Text
    internal var spacing: CGFloat = 0

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
                ForEach(textAsCharacters()) { item in
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

    private func textAsCharacters() -> [IdentifiableCharacter] {
        text.enumerated().map(IdentifiableCharacter.init)
    }

    private func textView(char: IdentifiableCharacter) -> some View {
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
