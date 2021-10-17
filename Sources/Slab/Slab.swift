import SwiftSoup
import Collections
import Foundation

extension Element {
    
    // https://github.com/scinfu/SwiftSoup/issues/156#issuecomment-943009494
    func text(isLineBreakParsed: Bool) throws -> String {
        guard isLineBreakParsed else {
            return try text()
        }
        
        let doc: Document = try SwiftSoup.parse(html())
        //set pretty print to false, so \n is not removed
        doc.outputSettings(OutputSettings().prettyPrint(pretty: false))
        
        //select all <br> tags and append \n after that
        try doc.select("br").after("\\n")
        
        //select all <p> tags and prepend \n before that
        //try doc.select("p").before("\\n") // uncomment if needed
        
        //get the HTML from the document, and retaining original new lines
        let str = try doc.html().replacingOccurrences(of: "\\\\n", with: "\n")
        
        return try SwiftSoup.clean(str, "", Whitelist.none(), OutputSettings().prettyPrint(pretty: false))!
    }
}

public struct Slab {
    
    public init() {}
    
    /// Converts the first `<tbody>` element.
    /// Throws `SlabError`s or `SwiftSoup` errors.
    public func convert(_ html: String) throws -> [[String: String]] {
        
        let document: Document = try SwiftSoup.parse(html)
        
        guard let tbody = try document.select("tbody").first() else {
            throw SlabError.tableBodyNotFound
        }
        
        var rows = tbody.children().array()
        
        guard rows.isEmpty == false else {
            throw SlabError.tableBodyContainsNoRows
        }
        
        let headers = rows.removeFirst().children().array()
        
        try validateTableHeaders(headers)
        
        var orderedDictionary = OrderedDictionary<Int, OrderedDictionary<Int, String>>()
        
        let rowCount = rows.count
        for index in (0..<rowCount) {
            orderedDictionary[index] = .init()
        }
        for rowIndex in (0..<rowCount) {
            let tr = rows[rowIndex]
            let colCount = tr.children().count
            for colIndex in (0..<colCount) {
                var offset = 0
                let td = tr.child(colIndex)
                while(orderedDictionary[rowIndex]![colIndex + offset] != nil) {
                    offset += 1
                }
                
                let colSpanString = try td.attr("colspan")
                let colSpan: Int = colSpanString.isEmpty ? 1 : try {
                    guard let int = Int(colSpanString) else {
                        throw SlabError.tableDataColspanNotInteger(tr: rowIndex, td: colIndex, colspan: colSpanString)
                    }
                    return int
                }()
                
                for i in (0..<colSpan) {
                    
                    let rowSpanString = try td.attr("rowspan")
                    let rowSpan: Int = rowSpanString.isEmpty ? 1 : try {
                        guard let int = Int(rowSpanString) else {
                            throw SlabError.tableDataRowspanNotInteger(tr: rowIndex, td: colIndex, rowspan: rowSpanString)
                        }
                        return int
                    }()
                    
                    for j in (0..<rowSpan) {
                        let row = rowIndex + j
                        let col = colIndex + offset + i
                        try orderedDictionary[row]![col] = td.text(isLineBreakParsed: true)
                    }
                }
            }
        }
        
        orderedDictionary.sort()
        
        var output = [[String: String]]()
        
        for rowOrderedDictionary in orderedDictionary {
            
            var rowDictionary = [String: String]()
            
            var row = rowOrderedDictionary.value
            
            row.sort()
            
            for element in row {
                let header = try headers[element.key].text(isLineBreakParsed: true)
                rowDictionary[header] = element.value
            }
            
            output.append(rowDictionary)
        }
        
        return output
    }
    
    /// Ensures that all `tableHeaders`:
    /// - Are `th` tags
    /// - Appear only once
    private func validateTableHeaders(_ tableHeaders: [Element]) throws {
        var uniqueTableHeaders = [String]()
        
        try tableHeaders.forEach { element in
            
            guard element.tagName() == "th" else {
                throw SlabError.tableBodyExpectedOnlyTableHeaderForFirstRow
            }
            
            let text = try element.text(isLineBreakParsed: true)
            
            guard uniqueTableHeaders.contains(text) == false else {
                throw SlabError.tableHeadersNotUnique
            }
            
            uniqueTableHeaders.append(text)
        }
    }
}
