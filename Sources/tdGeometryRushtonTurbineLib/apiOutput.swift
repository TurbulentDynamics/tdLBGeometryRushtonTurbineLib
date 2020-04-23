//
//  apiOutput.swift
//  
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let output = try Output(json)
//https://app.quicktype.io?share=egPgPZcPgEwTNPPxrDqs

import Foundation




// MARK: - Output
public struct qVecOutputData: Codable {
    public var volume: [Volume]
    public var ortho2DXY, ortho2DXZ, ortho2DYZ: [Ortho2D]
//    public var angle2D: [Angle2D]
}


// MARK: Output convenience initializers and mutators

extension qVecOutputData {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(qVecOutputData.self, from: data)
    }

    init(json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        volume: [Volume]? = nil,
        ortho2DXY: [Ortho2D]? = nil,
        ortho2DXZ: [Ortho2D]? = nil,
        ortho2DYZ: [Ortho2D]? = nil
    ) -> qVecOutputData {
        return qVecOutputData(
            volume: volume ?? self.volume,
            ortho2DXY: ortho2DXY ?? self.ortho2DXY,
            ortho2DXZ: ortho2DXZ ?? self.ortho2DXZ,
            ortho2DYZ: ortho2DYZ ?? self.ortho2DYZ
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}



// MARK: - Volume
public struct Volume: Codable {
    public var every: Int
    public var from, to: Int?
}

// MARK: Volume convenience initializers and mutators

extension Volume {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Volume.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        every: Int? = nil,
        from: Int?? = nil,
        to: Int?? = nil
    ) -> Volume {
        return Volume(
            every: every ?? self.every,
            from: from ?? self.from,
            to: to ?? self.to
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}





// MARK: - Ortho2D
public struct Ortho2D: Codable {
    public var at, every: Int
    public var from, to: Int?
}

// MARK: Ortho2D convenience initializers and mutators

extension Ortho2D {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Ortho2D.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        at: Int? = nil,
        every: Int? = nil,
        from: Int?? = nil,
        to: Int?? = nil
    ) -> Ortho2D {
        return Ortho2D(
            at: at ?? self.at,
            every: every ?? self.every,
            from: from ?? self.from,
            to: to ?? self.to
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}








// MARK: - Angle2D
public struct Angle2D: Codable {
    public var atAngle, every: Int
    public var from, to: Int?
}
// MARK: Angle2D convenience initializers and mutators

extension Angle2D {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Angle2D.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        atAngle: Int? = nil,
        every: Int? = nil,
        from: Int?? = nil,
        to: Int?? = nil
    ) -> Angle2D {
        return Angle2D(
            atAngle: atAngle ?? self.atAngle,
            every: every ?? self.every,
            from: from ?? self.from,
            to: to ?? self.to
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}












// MARK: - Helper functions for creating encoders and decoders

//func newJSONDecoder() -> JSONDecoder {
//    let decoder = JSONDecoder()
//    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
//        decoder.dateDecodingStrategy = .iso8601
//    }
//    return decoder
//}
//
//func newJSONEncoder() -> JSONEncoder {
//    let encoder = JSONEncoder()
//    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
//        encoder.dateEncodingStrategy = .iso8601
//    }
//    return encoder
//}
