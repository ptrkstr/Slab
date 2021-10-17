import XCTest
@testable import Slab
import SwiftSoup
import Foundation
import Collections

final class SlabTests: XCTestCase {
    
    let slab = Slab()
	
	func test_error_tableBodyNotFound() throws {
		
		XCTAssertThrowsError(
			try slab.convert(
"""
<table>
</table>
"""),
			"",
			{ error in
				XCTAssertEqual(error as! SlabError, .tableBodyNotFound)
			}
		)
	}
	
	func test_error_tableBodyContainsNoRows() throws {

		XCTAssertThrowsError(
			try slab.convert(
"""
<table>
	<tbody></tbody>
</table>
"""),
			"",
			{ error in
				XCTAssertEqual(error as! SlabError, .tableBodyContainsNoRows)
			}
		)
	}
	
	func test_error_tableBodyExpectedOnlyTableHeaderForFirstRow() throws {
		
		XCTAssertThrowsError(
			try slab.convert(
"""
<table>
	<tbody>
		<tr>
			<td></td>
		</tr>
	</tbody>
</table>
"""),
			"",
			{ error in
				XCTAssertEqual(error as! SlabError, .tableBodyExpectedOnlyTableHeaderForFirstRow)
			}
		)
	}
	
	func test_error_tableHeadersNotUnique() throws {
		
		XCTAssertThrowsError(
			try slab.convert(
"""
<table>
	<tbody>
		<tr>
			<th>A</th>
			<th>A</th>
		</tr>
	</tbody>
</table>
"""
			),
			"",
			{ error in
				XCTAssertEqual(error as! SlabError, .tableHeadersNotUnique)
			}
		)
	}
	
	func test_error_tableDataRowspanNotInteger() throws {
		
		XCTAssertThrowsError(
			try slab.convert(
"""
<table>
	<tbody>
		<tr>
			<th>A
			</th>
			<th>B
			</th>
		</tr>
		<tr>
			<td rowspan="a">1
			</td>
			<td>2
			</td>
		</tr>
		<tr>
			<td>4
			</td>
		</tr>
	</tbody>
</table>
"""),
			"",
			{ error in
				XCTAssertEqual(error as! SlabError, .tableDataRowspanNotInteger(tr: 0, td: 0, rowspan: "a"))
			}
		)
	}
	
	func test_error_tableDataColspanNotInteger() throws {
		
		XCTAssertThrowsError(
			try slab.convert(
"""
<table>
	<tbody>
		<tr>
			<th>A
			</th>
			<th>B
			</th>
		</tr>
		<tr>
			<td colspan="a">1
			</td>
		</tr>
		<tr>
			<td>3
		    </td>
			<td>4
			</td>
		</tr>
	</tbody>
</table>
"""),
			"",
			{ error in
				XCTAssertEqual(error as! SlabError, .tableDataColspanNotInteger(tr: 0, td: 0, colspan: "a"))
			}
		)
	}
	
	func test_simple() throws {

		XCTAssertEqual(
			try slab.convert(
"""
<table>
	<tbody>
		<tr>
			<th>A
			</th>
			<th>B
			</th>
		</tr>
		<tr>
			<td>1
			</td>
			<td>2
			</td>
		</tr>
		<tr>
		    <td>3
			</td>
			<td>4
			</td>
		</tr>
	</tbody>
</table>
"""
			),
			[
				["A": "1", "B": "2"],
				["A": "3", "B": "4"]
			]
		)
	}
    
    func test_linebreaks_header() throws {
    
        XCTAssertEqual(
            try slab.convert(
"""
<table>
    <tbody>
        <tr>
            <th>A<br>A
            </th>
            <th>B
            </th>
        </tr>
        <tr>
            <td>1
            </td>
            <td>2
            </td>
        </tr>
        <tr>
            <td>3
            </td>
            <td>4
            </td>
        </tr>
    </tbody>
</table>
"""
            ),
            [
                ["A\\nA": "1", "B": "2"],
                ["A\\nA": "3", "B": "4"]
            ]
        )
    }
    
    func test_linebreaks_rows() throws {
    
        XCTAssertEqual(
            try slab.convert(
"""
<table>
    <tbody>
        <tr>
            <th>A
            </th>
            <th>B
            </th>
        </tr>
        <tr>
            <td>1<br>1
            </td>
            <td>2
            </td>
        </tr>
        <tr>
            <td>3
            </td>
            <td>4
            </td>
        </tr>
    </tbody>
</table>
"""
            ),
            [
                ["A": "1\\n1", "B": "2"],
                ["A": "3", "B": "4"]
            ]
        )
    }
	
    func test_rowspan_1() throws {
		
		XCTAssertEqual(
			try slab.convert(
"""
<table>
	<tbody>
		<tr>
			<th>A
			</th>
			<th>B
			</th>
		</tr>
		<tr>
			<td rowspan="2">1
			</td>
			<td>2
			</td>
		</tr>
		<tr>
			<td>4
			</td>
		</tr>
	</tbody>
</table>
"""
			),
			[
				["A": "1", "B": "2"],
				["A": "1", "B": "4"]
			]
		)
	}
	
	func test_rowspan_2() throws {
		
		XCTAssertEqual(
			try slab.convert(
"""
<table>
	<tbody>
		<tr>
			<th>A
			</th>
			<th>B
			</th>
		</tr>
		<tr>
			<td>1
			</td>
			<td rowspan="2">2
			</td>
		</tr>
		<tr>
			<td>4
			</td>
		</tr>
	</tbody>
</table>
"""
			),
			[
				["A": "1", "B": "2"],
				["A": "4", "B": "2"]
			]
		)
	}
	
	func test_colspan_1() throws {
		
		XCTAssertEqual(
			try slab.convert(
"""
<table>
	<tbody>
		<tr>
			<th>A
			</th>
			<th>B
			</th>
		</tr>
		<tr>
			<td colspan="2">1
			</td>
		</tr>
		<tr>
            <td>3
            </td>
			<td>4
			</td>
		</tr>
	</tbody>
</table>
"""
			),
			[
				["A": "1", "B": "1"],
				["A": "3", "B": "4"]
			]
		)
	}
    
    func test_colspan_rowspan() throws {
        
        XCTAssertEqual(
            try slab.convert(
"""
<table>
    <tbody>
        <tr>
            <th>A
            </th>
            <th>B
            </th>
        </tr>
        <tr>
            <td>1
            </td>
            <td rowspan="2">2
            </td>
        </tr>
        <tr>
            <td>4
            </td>
        </tr>
        <tr>
            <td colspan="2">5
            </td>
        </tr>
    </tbody>
</table>
"""
            ),
            [
                ["A": "1", "B": "2"],
                ["A": "4", "B": "2"],
                ["A": "5", "B": "5"]
            ]
        )
    }
}
