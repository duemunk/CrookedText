import SwiftUI

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
