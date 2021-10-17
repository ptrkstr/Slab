import SwiftSoup

public struct Configuration {
    
    public static var `default`: Configuration {
        .init(modify: nil)
    }
    
    public let modify: ((_ element: Element, _ row: Int, _ column: Int) throws -> Element)?
}
