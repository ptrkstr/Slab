import SwiftSoup
import Foundation

enum SlabError: Error, Equatable {
	case tableBodyNotFound
	case tableBodyContainsNoRows
	case tableBodyExpectedOnlyTableHeaderForFirstRow
	case tableHeadersNotUnique
	case tableDataColspanNotInteger(tr: Int, td: Int, colspan: String)
	case tableDataRowspanNotInteger(tr: Int, td: Int, rowspan: String)
    case tableDataMissing(tr: Int, td: Int)
}

extension SlabError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .tableBodyNotFound:
            return "<body> wasn't found."
        case .tableBodyContainsNoRows:
            return "<tr> wasn't found within <body>."
        case .tableBodyExpectedOnlyTableHeaderForFirstRow:
            return "First row contained something other than <th>."
        case .tableHeadersNotUnique:
            return "<th> values aren't unique."
        case .tableDataColspanNotInteger(let tr, let td, let colspan):
            return "Expected colspan at (tr: \(tr), td: \(td)) to be an integer. Instead found '\(colspan)'."
        case .tableDataRowspanNotInteger(let tr, let td, let rowspan):
            return "Expected rolspan at (tr: \(tr), td: \(td)) to be an integer. Instead found '\(rowspan)'."
        case .tableDataMissing(let tr, let td):
            return "No <td> found for (tr: \(tr), td: \(td))."
        }
    }
}
