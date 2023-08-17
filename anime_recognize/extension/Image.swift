import SwiftUI

extension Image: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
}
