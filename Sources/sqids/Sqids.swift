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

import Foundation

public struct Sqids {
    public typealias Id = Int64
    public typealias Ids = [Id]
    
    public enum Error: Swift.Error {
        case invalidMinLength(Int)
        case valueError(Id)
        case maximumAttemptsReached
        case overflow
    }
    public static let defaultAlphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    public static let minAlphabetLength = 3
    public static let minLengthLimit = 255
    public static let minBlocklistWordLength = 3

    public let alphabet: [Character]
    public let minLength: Int
    public let blocklist: Set<String>
    
    public init(
        alphabet: String = Self.defaultAlphabet,
        minLength: Int = 0,
        blocklist: [String]? = nil
    ) {
        let wordList = blocklist ?? _DEFAULT_BLOCKLIST
        
        assert(
            alphabet.count >= Self.minAlphabetLength,
            "Alphabet length must be at least \(Self.minAlphabetLength)"
        )
        assert(
            minLength >= 0 && minLength <= Self.minLengthLimit,
            "Minimum length has to be between 0 and \(Self.minLengthLimit)"
        )
        assert(
            alphabet.reduce(true, { $0 && $1.isASCII }),
            "Alphabet cannot contain multibyte characters."
        )
        assert(
            Set(alphabet).count == alphabet.count,
            "Alphabet must contain unique characters."
        )
        self.alphabet = Self.shuffle(alphabet: Array(alphabet))
        self.minLength = minLength
        self.blocklist = Set(wordList.map({ $0.lowercased() }).filter {word in
            if word.count < Self.minAlphabetLength {
                return false
            }
            else {
                let alphabet = Set(alphabet.lowercased())
                let characters = Array(word)
                let reduced = characters.filter { alphabet.contains($0) }
                return word.count == reduced.count
            }
        })
    }
    
    public func encode(_ numbers: Ids) throws -> String {
        if numbers.isEmpty {
            return ""
        }
        else {
            for n in numbers {
                if n < 0 {
                    throw Error.valueError(n)
                }
            }
            return try _encode(numbers)
        }
    }
    
    private func _encode(_ numbers: Ids) throws -> String {
        let count = Id(alphabet.count)
        
        for increment in 0..<alphabet.count {
            var offset = numbers.enumerated().reduce(numbers.count)  {result, value in
                result + value.0 + Int(self.alphabet[Int(value.1 % count)].asciiValue!)
            } % self.alphabet.count
            
            offset = (offset + increment) % self.alphabet.count
            var alphabet = splitReverse(offset: offset)
            var result = [self.alphabet[offset]]
            
            for (i, number) in numbers.enumerated() {
                let id = toId(
                    number: number, alphabet: Array(alphabet.suffix(from: 1))
                )
                result.append(contentsOf: id)
                if i < numbers.count - 1 {
                    result.append(alphabet[0])
                    alphabet = Self.shuffle(alphabet: alphabet)
                }
            }
            if minLength > result.count {
                result.append(alphabet[0])
                while minLength > result.count {
                    let range = 0..<min(minLength - result.count, alphabet.count)
                    
                    alphabet = Self.shuffle(alphabet: alphabet)
                    result.append(contentsOf: alphabet[range])
                }
            }
            let id = String(result)
            if !isBlocked(id: id) {
                return id
            }
        }
        throw Error.maximumAttemptsReached
    }
    
    func splitReverse(offset: Int) -> [Character] {
        var alphabet = [Character](self.alphabet.suffix(from: offset))
        
        alphabet.append(contentsOf: self.alphabet.prefix(offset))
        return alphabet.reversed()
    }
    
    public func decode(_ id: String) throws -> [Id] {
        var result = [Id]()
        
        if !id.isEmpty {
            let characterSet = CharacterSet(alphabet.flatMap({ $0.unicodeScalars }))
            
            if id.unicodeScalars.reduce(true, { $0 && characterSet.contains($1) }) {
                let offset = alphabet.firstIndex(of: id.first!)!
                var alphabet = splitReverse(offset: offset)
                var value = String(Array(id).suffix(from: 1))

                while !value.isEmpty {
                    let separator = String(alphabet.first!)
                    let chunks = value.components(separatedBy: separator)
                    
                    if !chunks.isEmpty {
                        if chunks[0].isEmpty {
                            break
                        }
                        else {
                            let number = try toNumber(
                                id: chunks[0],
                                alphabet: Array(alphabet.suffix(from: 1))
                            )
                            result.append(number)
                            if chunks.count > 1 {
                                alphabet = Self.shuffle(alphabet: alphabet)
                            }
                        }
                        value = chunks.count > 1 ? chunks.suffix(from: 1).joined(separator: separator) : ""
                    }
                }
            }
        }
        return result
    }
    
    private func toId(number: Id, alphabet: [Character]) -> String {
        let count = Id(alphabet.count)
        var number = number
        var result = [Character]()
        
        while true {
            result.insert(alphabet[Int(number % count)], at: 0)
            number /= count
            if number <= 0 {
                break
            }
        }
        return String(result)
    }
    
    static func shuffle(alphabet: String) -> String {
        return String(shuffle(alphabet: Array(alphabet)))
    }
    
    static func shuffle(alphabet: [Character]) -> [Character] {
        var characters = Array(alphabet)
        var i = 0
        var j = characters.count - 1
        
        while j > 0 {
            let ci = Int(characters[i].asciiValue!)
            let cj = Int(characters[j].asciiValue!)
            let r = (i * j + ci + cj) % characters.count
            
            (characters[i], characters[r]) = (characters[r], characters[i])
            i += 1
            j -= 1
        }
        return characters
    }
    
    func toNumber(id: String, alphabet: [Character]) throws -> Id {
        let count = Id(alphabet.count)
        
        return try id.reduce(0) {
            let (product, productOverflow) = $0.multipliedReportingOverflow(by: count)
            guard !productOverflow else { throw Error.overflow }
            
            let (sum, sumOverflow) = product.addingReportingOverflow(Id(alphabet.firstIndex(of: $1) ?? -1))
            guard !sumOverflow else { throw Error.overflow }
            
            return sum
        }
    }
    
    public func isBlocked(id: String) -> Bool {
        let id = id.lowercased()
        
        for word in blocklist {
            if word.count <= id.count {
                if id.count <= 3 || word.count <= 3 {
                    if id == word {
                        return true
                    }
                } 
                else if word.first!.isNumber {
                    if id.hasPrefix(word) || id.hasSuffix(word) {
                        return true
                    }
                } 
                else if id.range(of: word) != nil {
                    return true
                }
            }
        }
        return false
    }
}

let _DEFAULT_BLOCKLIST = [
    "0rgasm",
    "1d10t",
    "1d1ot",
    "1di0t",
    "1diot",
    "1eccacu10",
    "1eccacu1o",
    "1eccacul0",
    "1eccaculo",
    "1mbec11e",
    "1mbec1le",
    "1mbeci1e",
    "1mbecile",
    "a11upat0",
    "a11upato",
    "a1lupat0",
    "a1lupato",
    "aand",
    "ah01e",
    "ah0le",
    "aho1e",
    "ahole",
    "al1upat0",
    "al1upato",
    "allupat0",
    "allupato",
    "ana1",
    "ana1e",
    "anal",
    "anale",
    "anus",
    "arrapat0",
    "arrapato",
    "arsch",
    "arse",
    "ass",
    "b00b",
    "b00be",
    "b01ata",
    "b0ceta",
    "b0iata",
    "b0ob",
    "b0obe",
    "b0sta",
    "b1tch",
    "b1te",
    "b1tte",
    "ba1atkar",
    "balatkar",
    "bastard0",
    "bastardo",
    "batt0na",
    "battona",
    "bitch",
    "bite",
    "bitte",
    "bo0b",
    "bo0be",
    "bo1ata",
    "boceta",
    "boiata",
    "boob",
    "boobe",
    "bosta",
    "bran1age",
    "bran1er",
    "bran1ette",
    "bran1eur",
    "bran1euse",
    "branlage",
    "branler",
    "branlette",
    "branleur",
    "branleuse",
    "c0ck",
    "c0g110ne",
    "c0g11one",
    "c0g1i0ne",
    "c0g1ione",
    "c0gl10ne",
    "c0gl1one",
    "c0gli0ne",
    "c0glione",
    "c0na",
    "c0nnard",
    "c0nnasse",
    "c0nne",
    "c0u111es",
    "c0u11les",
    "c0u1l1es",
    "c0u1lles",
    "c0ui11es",
    "c0ui1les",
    "c0uil1es",
    "c0uilles",
    "c11t",
    "c11t0",
    "c11to",
    "c1it",
    "c1it0",
    "c1ito",
    "cabr0n",
    "cabra0",
    "cabrao",
    "cabron",
    "caca",
    "cacca",
    "cacete",
    "cagante",
    "cagar",
    "cagare",
    "cagna",
    "cara1h0",
    "cara1ho",
    "caracu10",
    "caracu1o",
    "caracul0",
    "caraculo",
    "caralh0",
    "caralho",
    "cazz0",
    "cazz1mma",
    "cazzata",
    "cazzimma",
    "cazzo",
    "ch00t1a",
    "ch00t1ya",
    "ch00tia",
    "ch00tiya",
    "ch0d",
    "ch0ot1a",
    "ch0ot1ya",
    "ch0otia",
    "ch0otiya",
    "ch1asse",
    "ch1avata",
    "ch1er",
    "ch1ng0",
    "ch1ngadaz0s",
    "ch1ngadazos",
    "ch1ngader1ta",
    "ch1ngaderita",
    "ch1ngar",
    "ch1ngo",
    "ch1ngues",
    "ch1nk",
    "chatte",
    "chiasse",
    "chiavata",
    "chier",
    "ching0",
    "chingadaz0s",
    "chingadazos",
    "chingader1ta",
    "chingaderita",
    "chingar",
    "chingo",
    "chingues",
    "chink",
    "cho0t1a",
    "cho0t1ya",
    "cho0tia",
    "cho0tiya",
    "chod",
    "choot1a",
    "choot1ya",
    "chootia",
    "chootiya",
    "cl1t",
    "cl1t0",
    "cl1to",
    "clit",
    "clit0",
    "clito",
    "cock",
    "cog110ne",
    "cog11one",
    "cog1i0ne",
    "cog1ione",
    "cogl10ne",
    "cogl1one",
    "cogli0ne",
    "coglione",
    "cona",
    "connard",
    "connasse",
    "conne",
    "cou111es",
    "cou11les",
    "cou1l1es",
    "cou1lles",
    "coui11es",
    "coui1les",
    "couil1es",
    "couilles",
    "cracker",
    "crap",
    "cu10",
    "cu1att0ne",
    "cu1attone",
    "cu1er0",
    "cu1ero",
    "cu1o",
    "cul0",
    "culatt0ne",
    "culattone",
    "culer0",
    "culero",
    "culo",
    "cum",
    "cunt",
    "d11d0",
    "d11do",
    "d1ck",
    "d1ld0",
    "d1ldo",
    "damn",
    "de1ch",
    "deich",
    "depp",
    "di1d0",
    "di1do",
    "dick",
    "dild0",
    "dildo",
    "dyke",
    "encu1e",
    "encule",
    "enema",
    "enf01re",
    "enf0ire",
    "enfo1re",
    "enfoire",
    "estup1d0",
    "estup1do",
    "estupid0",
    "estupido",
    "etr0n",
    "etron",
    "f0da",
    "f0der",
    "f0ttere",
    "f0tters1",
    "f0ttersi",
    "f0tze",
    "f0utre",
    "f1ca",
    "f1cker",
    "f1ga",
    "fag",
    "fica",
    "ficker",
    "figa",
    "foda",
    "foder",
    "fottere",
    "fotters1",
    "fottersi",
    "fotze",
    "foutre",
    "fr0c10",
    "fr0c1o",
    "fr0ci0",
    "fr0cio",
    "fr0sc10",
    "fr0sc1o",
    "fr0sci0",
    "fr0scio",
    "froc10",
    "froc1o",
    "froci0",
    "frocio",
    "frosc10",
    "frosc1o",
    "frosci0",
    "froscio",
    "fuck",
    "g00",
    "g0o",
    "g0u1ne",
    "g0uine",
    "gandu",
    "go0",
    "goo",
    "gou1ne",
    "gouine",
    "gr0gnasse",
    "grognasse",
    "haram1",
    "harami",
    "haramzade",
    "hund1n",
    "hundin",
    "id10t",
    "id1ot",
    "idi0t",
    "idiot",
    "imbec11e",
    "imbec1le",
    "imbeci1e",
    "imbecile",
    "j1zz",
    "jerk",
    "jizz",
    "k1ke",
    "kam1ne",
    "kamine",
    "kike",
    "leccacu10",
    "leccacu1o",
    "leccacul0",
    "leccaculo",
    "m1erda",
    "m1gn0tta",
    "m1gnotta",
    "m1nch1a",
    "m1nchia",
    "m1st",
    "mam0n",
    "mamahuev0",
    "mamahuevo",
    "mamon",
    "masturbat10n",
    "masturbat1on",
    "masturbate",
    "masturbati0n",
    "masturbation",
    "merd0s0",
    "merd0so",
    "merda",
    "merde",
    "merdos0",
    "merdoso",
    "mierda",
    "mign0tta",
    "mignotta",
    "minch1a",
    "minchia",
    "mist",
    "musch1",
    "muschi",
    "n1gger",
    "neger",
    "negr0",
    "negre",
    "negro",
    "nerch1a",
    "nerchia",
    "nigger",
    "orgasm",
    "p00p",
    "p011a",
    "p01la",
    "p0l1a",
    "p0lla",
    "p0mp1n0",
    "p0mp1no",
    "p0mpin0",
    "p0mpino",
    "p0op",
    "p0rca",
    "p0rn",
    "p0rra",
    "p0uff1asse",
    "p0uffiasse",
    "p1p1",
    "p1pi",
    "p1r1a",
    "p1rla",
    "p1sc10",
    "p1sc1o",
    "p1sci0",
    "p1scio",
    "p1sser",
    "pa11e",
    "pa1le",
    "pal1e",
    "palle",
    "pane1e1r0",
    "pane1e1ro",
    "pane1eir0",
    "pane1eiro",
    "panele1r0",
    "panele1ro",
    "paneleir0",
    "paneleiro",
    "patakha",
    "pec0r1na",
    "pec0rina",
    "pecor1na",
    "pecorina",
    "pen1s",
    "pendej0",
    "pendejo",
    "penis",
    "pip1",
    "pipi",
    "pir1a",
    "pirla",
    "pisc10",
    "pisc1o",
    "pisci0",
    "piscio",
    "pisser",
    "po0p",
    "po11a",
    "po1la",
    "pol1a",
    "polla",
    "pomp1n0",
    "pomp1no",
    "pompin0",
    "pompino",
    "poop",
    "porca",
    "porn",
    "porra",
    "pouff1asse",
    "pouffiasse",
    "pr1ck",
    "prick",
    "pussy",
    "put1za",
    "puta",
    "puta1n",
    "putain",
    "pute",
    "putiza",
    "puttana",
    "queca",
    "r0mp1ba11e",
    "r0mp1ba1le",
    "r0mp1bal1e",
    "r0mp1balle",
    "r0mpiba11e",
    "r0mpiba1le",
    "r0mpibal1e",
    "r0mpiballe",
    "rand1",
    "randi",
    "rape",
    "recch10ne",
    "recch1one",
    "recchi0ne",
    "recchione",
    "retard",
    "romp1ba11e",
    "romp1ba1le",
    "romp1bal1e",
    "romp1balle",
    "rompiba11e",
    "rompiba1le",
    "rompibal1e",
    "rompiballe",
    "ruff1an0",
    "ruff1ano",
    "ruffian0",
    "ruffiano",
    "s1ut",
    "sa10pe",
    "sa1aud",
    "sa1ope",
    "sacanagem",
    "sal0pe",
    "salaud",
    "salope",
    "saugnapf",
    "sb0rr0ne",
    "sb0rra",
    "sb0rrone",
    "sbattere",
    "sbatters1",
    "sbattersi",
    "sborr0ne",
    "sborra",
    "sborrone",
    "sc0pare",
    "sc0pata",
    "sch1ampe",
    "sche1se",
    "sche1sse",
    "scheise",
    "scheisse",
    "schlampe",
    "schwachs1nn1g",
    "schwachs1nnig",
    "schwachsinn1g",
    "schwachsinnig",
    "schwanz",
    "scopare",
    "scopata",
    "sexy",
    "sh1t",
    "shit",
    "slut",
    "sp0mp1nare",
    "sp0mpinare",
    "spomp1nare",
    "spompinare",
    "str0nz0",
    "str0nza",
    "str0nzo",
    "stronz0",
    "stronza",
    "stronzo",
    "stup1d",
    "stupid",
    "succh1am1",
    "succh1ami",
    "succhiam1",
    "succhiami",
    "sucker",
    "t0pa",
    "tapette",
    "test1c1e",
    "test1cle",
    "testic1e",
    "testicle",
    "tette",
    "topa",
    "tr01a",
    "tr0ia",
    "tr0mbare",
    "tr1ng1er",
    "tr1ngler",
    "tring1er",
    "tringler",
    "tro1a",
    "troia",
    "trombare",
    "turd",
    "twat",
    "vaffancu10",
    "vaffancu1o",
    "vaffancul0",
    "vaffanculo",
    "vag1na",
    "vagina",
    "verdammt",
    "verga",
    "w1chsen",
    "wank",
    "wichsen",
    "x0ch0ta",
    "x0chota",
    "xana",
    "xoch0ta",
    "xochota",
    "z0cc01a",
    "z0cc0la",
    "z0cco1a",
    "z0ccola",
    "z1z1",
    "z1zi",
    "ziz1",
    "zizi",
    "zocc01a",
    "zocc0la",
    "zocco1a",
    "zoccola",
]
