import SwiftSoup

enum SlabError: Error, Equatable {
	case tableBodyNotFound
	case tableBodyContainsNoRows
	case tableBodyExpectedOnlyTableHeaderForFirstRow
	case tableHeadersNotUnique
	case tableDataColspanNotInteger(tr: Int, td: Int, colspan: String)
	case tableDataRowspanNotInteger(tr: Int, td: Int, rowspan: String)
    case tableDataMissing(tr: Int, td: Int)
}
