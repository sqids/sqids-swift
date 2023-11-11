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

final class SqidsBlocklistTests: XCTestCase {
    func testDefaultBlocklist() throws {
        let sqids = Sqids()
        
        XCTAssertEqual(try sqids.decode("aho1e"), [4572721])
        XCTAssertEqual(try sqids.encode([4572721]), "JExTR")
    }
    
    func testEmptyBlocklist() throws {
        let sqids = Sqids(blocklist: [])
        
        XCTAssertEqual(try sqids.decode("aho1e"), [4572721])
        XCTAssertEqual(try sqids.encode([4572721]), "aho1e")
    }
    
    func testCustomBlocklist() throws {
        let sqids = Sqids(blocklist: ["ArUO"])
        
        XCTAssertEqual(try sqids.decode("aho1e"), [4572721])
        XCTAssertEqual(try sqids.encode([4572721]), "aho1e")
        
        XCTAssertEqual(try sqids.decode("ArUO"), [100000])
        XCTAssertEqual(try sqids.encode([100000]),"QyG4")
        XCTAssertEqual(try sqids.decode("QyG4"), [100000])
    }
    
    func testBlocklist() throws {
        let sqids = Sqids(
            blocklist: [
                "JSwXFaosAN", // normal result of 1st encoding, block that word on purpose
                "OCjV9JK64o", // result of 2nd encoding
                "rBHf", // result of 3rd encoding is `4rBHfOiqd3`, let's block a substring
                "79SM", // result of 4th encoding is `dyhgw479SM`, let's block the postfix
                "7tE6", // result of 4th encoding is `7tE6jdAHLe`, let's block the prefix
            ]
        )
        
        XCTAssertEqual(try sqids.encode([1000000, 2000000]), "1aYeB7bRUt")
        XCTAssertEqual(try sqids.decode("1aYeB7bRUt"), [1000000, 2000000])
    }
    
    func testDecodingBlocklistWords() {
        let sqids = Sqids(blocklist: ["86Rf07", "se8ojk", "ARsz1p", "Q8AI49", "5sQRZO"])
        
        XCTAssertEqual(try sqids.decode("86Rf07"), [1, 2, 3])
        XCTAssertEqual(try sqids.decode("se8ojk"), [1, 2, 3])
        XCTAssertEqual(try sqids.decode("ARsz1p"), [1, 2, 3])
        XCTAssertEqual(try sqids.decode("Q8AI49"), [1, 2, 3])
        XCTAssertEqual(try sqids.decode("5sQRZO"), [1, 2, 3])
    }
    
    func test_match_against_short_blocklist_word() throws {
        let sqids = Sqids(blocklist: ["pnd"])
        
        XCTAssertEqual(try sqids.decode(try sqids.encode([1000])), [1000])
    }
    
    func testBlocklistFilteringInConstructor() throws {
        // lowercase blocklist in only-uppercase alphabet
        let sqids = Sqids(alphabet: "ABCDEFGHIJKLMNOPQRSTUVWXYZ", blocklist: ["sxnzkl"])
        let id = try sqids.encode([1, 2, 3])
        let numbers = try sqids.decode(id)
        
        // without blocklist, would've been "SXNZKL"
        XCTAssertEqual(id, "IBSHOZ")
        XCTAssertEqual(numbers, [1, 2, 3])
    }
    
    func testMaxEncodingAttempts() throws {
        let alphabet = "abc"
        let minLength = 3
        let blocklist = ["cab", "abc", "bca"]
        
        let sqids = Sqids(alphabet: alphabet, minLength: minLength, blocklist: blocklist)
        
        XCTAssertEqual(minLength, alphabet.count)
        XCTAssertEqual(minLength, blocklist.count)

        do {
            _ = try sqids.encode([0])
            XCTFail()
        }
        catch(error: Sqids.Error.maximumAttemptsReached) {
            
        }
    }
}
