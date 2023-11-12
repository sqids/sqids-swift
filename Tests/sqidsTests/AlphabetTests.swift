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

final class AlphabetTests: XCTestCase {
    func testSimple() throws {
        let sqids = Sqids(alphabet: "0123456789abcdef")
        let numbers: Sqids.Ids = [1, 2, 3]
        let id = "489158"

        XCTAssertEqual(try sqids.encode(numbers), id)
        XCTAssertEqual(try sqids.decode(id), numbers)
    }
    
    func testShortAlphabet() throws {
        let sqids = Sqids(alphabet: "abc")
        let numbers: Sqids.Ids = [1, 2, 3]
        let id = try sqids.encode(numbers)
        
        XCTAssertEqual("aacacbaa", id)
        XCTAssertEqual(try sqids.decode(id), numbers)
    }
    
    func testLongAlphabet() throws {
        let sqids = Sqids(
            alphabet: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_+|{}[];:'\"/?.>,<`~"
        )
        let numbers: Sqids.Ids = [1, 2, 3]
        let id = try sqids.encode(numbers)

        XCTAssertEqual("+;w<gw", id)
        XCTAssertEqual(try sqids.decode(id), numbers)
    }
}
