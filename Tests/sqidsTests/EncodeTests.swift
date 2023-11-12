/*
 MIT License
 
 Copyright (c) 2023-present Sqids maintainers.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import XCTest
@testable import sqids

final class EncodeTests: XCTestCase {
    func testSimple() throws {
        let sqids = Sqids()
        let numbers: Sqids.Ids = [1, 2, 3]
        let id = "86Rf07"
        
        XCTAssertEqual(try sqids.encode(numbers), id)
        XCTAssertEqual(try sqids.decode(id), numbers)
    }
    
    
    func testDifferentInputs() throws {
        let sqids = Sqids()
        let numbers = [0, 0, 0, 1, 2, 3, 100, 1_000, 100_000, 1_000_000, Sqids.Id.max]
        
        XCTAssertEqual(try sqids.decode(try sqids.encode(numbers)), numbers)
    }
    
    
    func testIncrementalNumbers() throws {
        let sqids = Sqids()
        let data: [String: [Int64]] = [
            "bM": [0],
            "Uk": [1],
            "gb": [2],
            "Ef": [3],
            "Vq": [4],
            "uw": [5],
            "OI": [6],
            "AX": [7],
            "p6": [8],
            "nJ": [9],
        ]
        
        for id in data.keys {
            let numbers = data[id]!
            
            XCTAssertEqual(try sqids.encode(numbers), id)
            XCTAssertEqual(try sqids.decode(id), numbers)
        }
    }
}
