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
    
    func testIncrementalNumbersSameIndex0() throws {
        let sqids = Sqids()
        let ids: [String: Sqids.Ids] = [
            "SvIz": [0, 0],
            "n3qa": [0, 1],
            "tryF": [0, 2],
            "eg6q": [0, 3],
            "rSCF": [0, 4],
            "sR8x": [0, 5],
            "uY2M": [0, 6],
            "74dI": [0, 7],
            "30WX": [0, 8],
            "moxr": [0, 9],
        ]
        for (id, numbers) in ids {
            XCTAssertEqual(try sqids.encode(numbers), id)
            XCTAssertEqual(try sqids.decode(id), numbers)
        }
    }

    
    func testIncrementalNumbersSameIndex1() throws {
        let sqids = Sqids()
        let ids: [String: Sqids.Ids] = [
            "SvIz": [0, 0],
            "nWqP": [1, 0],
            "tSyw": [2, 0],
            "eX68": [3, 0],
            "rxCY": [4, 0],
            "sV8a": [5, 0],
            "uf2K": [6, 0],
            "7Cdk": [7, 0],
            "3aWP": [8, 0],
            "m2xn": [9, 0],
        ]
        for (id, numbers) in ids {
            XCTAssertEqual(try sqids.encode(numbers), id)
            XCTAssertEqual(try sqids.decode(id), numbers)
        }
    }
    
    func testMultiInput() throws {
        let sqids = Sqids()
        let numbers: Sqids.Ids = Array(1..<100)
        let output = try sqids.decode(try sqids.encode(numbers))
        
        XCTAssertEqual(numbers, output)
    }
    
    func testEncodingNoNumbers() throws {
        let sqids = Sqids()
        
        XCTAssertEqual(try sqids.encode([]), "")
    }
    
    func testDecodingEmptyString() throws {
        let sqids = Sqids()
        
        XCTAssertEqual(try sqids.decode(""), [])
    }
    
    func testDecodingInvalidCharacter() throws {
        let sqids = Sqids()
        
        XCTAssertEqual(try sqids.decode("*"), [])
    }
    
    func testEncodeOutOfRangeNumbers() throws {
        let sqids = Sqids()
        
        do {
            _ = try sqids.encode([-1])
            XCTFail()
        }
        catch Sqids.Error.valueError(let id) {
            XCTAssertEqual(-1, id)
        }
    }
    
    func testDecodeOfUntrustedInput() throws {
        let sqids = Sqids()
        let badInput = try sqids.encode([Int64.max]) + "a"
        do {
            _ = try sqids.decode(badInput) // Should not crash
        }
        catch Sqids.Error.overflow { }
    }
}
