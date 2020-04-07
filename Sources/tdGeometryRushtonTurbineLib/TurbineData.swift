// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let rushtonTurbine = try RushtonTurbine(json)
//
/////https://app.quicktype.io?share=a4Hldp81TGUIEjNVrBRX
import Foundation


//TODO Create func to save the object to json, with string keys for impeller
extension RushtonTurbine {
    func saveAsJson(to url: URL) throws {
        print("Saving to:" + url.absoluteString)
    }
}


// MARK: - RushtonTurbine
struct RushtonTurbine: Codable {
    var tankDiameter, tankHeight:Int
    var impellerStartAngle: Double
    var shaft: Shaft
    var impeller: [Int: Impeller]
    var gridx, impellerStartupStepsUntilNormalSpeed: Int
    var baffles: Baffles
    var numImpellers, startingStep: Int
    var name: String
    var resolution: Double

    enum CodingKeys: String, CodingKey {
        case tankDiameter, tankHeight
        case impellerStartAngle = "impeller_start_angle"
        case shaft, impeller, gridx
        case impellerStartupStepsUntilNormalSpeed = "impeller_startup_steps_until_normal_speed"
        case baffles, numImpellers
        case startingStep = "starting_step"
        case name, resolution
    }
}

// MARK: RushtonTurbine convenience initializers and mutators

extension RushtonTurbine {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(RushtonTurbine.self, from: data)
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
        tankDiameter: Int? = nil,
        tankHeight: Int? = nil,
        impellerStartAngle: Double? = nil,
        shaft: Shaft? = nil,
        impeller: [Int: Impeller]? = nil,
        gridx: Int? = nil,
        impellerStartupStepsUntilNormalSpeed: Int? = nil,
        baffles: Baffles? = nil,
        numImpellers: Int? = nil,
        startingStep: Int? = nil,
        name: String? = nil,
        resolution: Double? = nil
    ) -> RushtonTurbine {
        return RushtonTurbine(
            tankDiameter: tankDiameter ?? self.tankDiameter,
            tankHeight: tankHeight ?? self.tankHeight,
            impellerStartAngle: impellerStartAngle ?? self.impellerStartAngle,
            shaft: shaft ?? self.shaft,
            impeller: impeller ?? self.impeller,
            gridx: gridx ?? self.gridx,
            impellerStartupStepsUntilNormalSpeed: impellerStartupStepsUntilNormalSpeed ?? self.impellerStartupStepsUntilNormalSpeed,
            baffles: baffles ?? self.baffles,
            numImpellers: numImpellers ?? self.numImpellers,
            startingStep: startingStep ?? self.startingStep,
            name: name ?? self.name,
            resolution: resolution ?? self.resolution
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Baffles
struct Baffles: Codable {
    var firstBaffleOffset: Double
    var innerRadius, thickness, numBaffles, outerRadius: Int
}

// MARK: Baffles convenience initializers and mutators

extension Baffles {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Baffles.self, from: data)
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
        firstBaffleOffset: Double? = nil,
        innerRadius: Int? = nil,
        thickness: Int? = nil,
        numBaffles: Int? = nil,
        outerRadius: Int? = nil
    ) -> Baffles {
        return Baffles(
            firstBaffleOffset: firstBaffleOffset ?? self.firstBaffleOffset,
            innerRadius: innerRadius ?? self.innerRadius,
            thickness: thickness ?? self.thickness,
            numBaffles: numBaffles ?? self.numBaffles,
            outerRadius: outerRadius ?? self.outerRadius
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Impeller
struct Impeller: Codable {
    var blades: Blades
    var uav, bladeTipAngularVelW0: Double
    var impellerPosition: Int
    var disk: Disk
    var numBlades, firstBladeOffset: Int
    var hub: Disk

    enum CodingKeys: String, CodingKey {
        case blades, uav
        case bladeTipAngularVelW0 = "blade_tip_angular_vel_w0"
        case impellerPosition = "impeller_position"
        case disk, numBlades, firstBladeOffset, hub
    }
}

// MARK: Impeller convenience initializers and mutators

extension Impeller {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Impeller.self, from: data)
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
        blades: Blades? = nil,
        uav: Double? = nil,
        bladeTipAngularVelW0: Double? = nil,
        impellerPosition: Int? = nil,
        disk: Disk? = nil,
        numBlades: Int? = nil,
        firstBladeOffset: Int? = nil,
        hub: Disk? = nil
    ) -> Impeller {
        return Impeller(
            blades: blades ?? self.blades,
            uav: uav ?? self.uav,
            bladeTipAngularVelW0: bladeTipAngularVelW0 ?? self.bladeTipAngularVelW0,
            impellerPosition: impellerPosition ?? self.impellerPosition,
            disk: disk ?? self.disk,
            numBlades: numBlades ?? self.numBlades,
            firstBladeOffset: firstBladeOffset ?? self.firstBladeOffset,
            hub: hub ?? self.hub
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Blades
struct Blades: Codable {
    var innerRadius, top: Int
    var thickness:Int
    var outerRadius: Int, bottom: Int

    enum CodingKeys: String, CodingKey {
        case innerRadius, top
        case thickness = "bladeThickness"
        case outerRadius, bottom
    }
}

// MARK: Blades convenience initializers and mutators

extension Blades {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Blades.self, from: data)
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
        innerRadius: Int? = nil,
        top: Int? = nil,
        bladeThickness: Int? = nil,
        outerRadius: Int? = nil,
        bottom: Int? = nil
    ) -> Blades {
        return Blades(
            innerRadius: innerRadius ?? self.innerRadius,
            top: top ?? self.top,
            thickness: bladeThickness ?? self.thickness,
            outerRadius: outerRadius ?? self.outerRadius,
            bottom: bottom ?? self.bottom
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Disk
struct Disk: Codable {
    var top, bottom, radius: Int
}

// MARK: Disk convenience initializers and mutators

extension Disk {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Disk.self, from: data)
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
        top: Int? = nil,
        bottom: Int? = nil,
        radius: Int? = nil
    ) -> Disk {
        return Disk(
            top: top ?? self.top,
            bottom: bottom ?? self.bottom,
            radius: radius ?? self.radius
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Shaft
struct Shaft: Codable {
    var radius: Int
}

// MARK: Shaft convenience initializers and mutators

extension Shaft {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Shaft.self, from: data)
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
        radius: Int? = nil
    ) -> Shaft {
        return Shaft(
            radius: radius ?? self.radius
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

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}
