import Foundation

extension RushtonTurbine {
    public func add(impeller: Impeller) {
        let lastImplellerIndex = impellers.map { $0.key }.compactMap { Int($0) }.max() ?? 0
        self.impellers["\(lastImplellerIndex + 1)"] = impeller
        self.objectWillChange.send()
    }
}
