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

final class MinLengthTests: XCTestCase {
    func test_simple() throws {
        let sqids = Sqids(minLength: Sqids.defaultAlphabet.count)
        let numbers: Sqids.Ids = [1, 2, 3]
        let id = "86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTM"
        
        XCTAssertEqual(try sqids.encode(numbers), id)
        XCTAssertEqual(try sqids.decode(id), numbers)
    }
    
    
    func testIncremental() throws {
        let numbers: Sqids.Ids = [1, 2, 3]
        var map = [
            6: "86Rf07",
            7: "86Rf07x",
            8: "86Rf07xd",
            9: "86Rf07xd4",
            10: "86Rf07xd4z",
            11: "86Rf07xd4zB",
            12: "86Rf07xd4zBm",
            13: "86Rf07xd4zBmi",
        ]
        
        map[Sqids.defaultAlphabet.count + 0] = "86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTM"
        map[Sqids.defaultAlphabet.count + 1] = "86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTMy"
        map[Sqids.defaultAlphabet.count + 2] = "86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTMyf"
        map[Sqids.defaultAlphabet.count + 3] = "86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTMyf1"
        
        for (minLength, id) in map {
            let sqids = Sqids(minLength: minLength)
            
            XCTAssertEqual(try sqids.encode(numbers), id)
            XCTAssertEqual(try sqids.encode(numbers).count, minLength)
            XCTAssertEqual(try sqids.decode(id), numbers)
        }
    }
    
    
    func testIncrementalNumbers() throws {
        let sqids = Sqids(minLength: Sqids.defaultAlphabet.count)
        let ids: [String: Sqids.Ids] = [
            "SvIzsqYMyQwI3GWgJAe17URxX8V924Co0DaTZLtFjHriEn5bPhcSkfmvOslpBu": [0, 0],
            "n3qafPOLKdfHpuNw3M61r95svbeJGk7aAEgYn4WlSjXURmF8IDqZBy0CT2VxQc": [0, 1],
            "tryFJbWcFMiYPg8sASm51uIV93GXTnvRzyfLleh06CpodJD42B7OraKtkQNxUZ": [0, 2],
            "eg6ql0A3XmvPoCzMlB6DraNGcWSIy5VR8iYup2Qk4tjZFKe1hbwfgHdUTsnLqE": [0, 3],
            "rSCFlp0rB2inEljaRdxKt7FkIbODSf8wYgTsZM1HL9JzN35cyoqueUvVWCm4hX": [0, 4],
            "sR8xjC8WQkOwo74PnglH1YFdTI0eaf56RGVSitzbjuZ3shNUXBrqLxEJyAmKv2": [0, 5],
            "uY2MYFqCLpgx5XQcjdtZK286AwWV7IBGEfuS9yTmbJvkzoUPeYRHr4iDs3naN0": [0, 6],
            "74dID7X28VLQhBlnGmjZrec5wTA1fqpWtK4YkaoEIM9SRNiC3gUJH0OFvsPDdy": [0, 7],
            "30WXpesPhgKiEI5RHTY7xbB1GnytJvXOl2p0AcUjdF6waZDo9Qk8VLzMuWrqCS": [0, 8],
            "moxr3HqLAK0GsTND6jowfZz3SUx7cQ8aC54Pl1RbIvFXmEJuBMYVeW9yrdOtin": [0, 9],
        ]
        
        for (id, numbers) in ids {
            XCTAssertEqual(try sqids.encode(numbers), id)
            XCTAssertEqual(try sqids.decode(id), numbers)
        }
    }
    
    
    func testMinLengths() throws {
        for minLength in [0, 1, 5, 10, Sqids.defaultAlphabet.count] {
            for numbers in [
                [0],
                [0, 0, 0, 0, 0],
                [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
                [100, 200, 300],
                [1000, 2000, 3000],
                [1000000],
                [Sqids.Id.max],
            ] {
                let sqids = Sqids(minLength: minLength)
                let id = try sqids.encode(numbers)
                
                XCTAssertGreaterThanOrEqual(id.count, minLength)
                XCTAssertEqual(try sqids.decode(id), numbers)
            }
        }
    }
}
