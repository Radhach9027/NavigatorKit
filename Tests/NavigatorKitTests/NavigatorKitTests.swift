import Foundation
import Testing
@testable import NavigatorKit

enum TestError: Error {
    case message(String)
    init(_ message: String) { self = .message(message) }
}

@Test("RouteParam Codable roundtrip should preserve values")
func testRouteParamCodable() throws {
    let params: [RouteParam] = [
        .string("Bookify"),
        .int(42),
        .double(3.14),
        .bool(true),
        .object(try JSONEncoder().encode(["key": "value"]))
    ]

    for param in params {
        let data = try JSONEncoder().encode(param)
        let decoded = try JSONDecoder().decode(RouteParam.self, from: data)
        #expect(decoded == param)
    }
}

@Test("RouteParam type conversions should work correctly")
func testRouteParamTypeConversions() {
    let route = Route(path: "/test", params: [
        "title": .string("Bookify"),
        "count": .int(5),
        "price": .double(99.9),
        "active": .bool(true)
    ])

    #expect(route.string("title") == "Bookify")
    #expect(route.int("count") == 5)
    #expect(route.double("price") == 99.9)
    #expect(route.bool("active") == true)
}

@Test("RouteParam decoding complex Codable type should succeed")
func testRouteParamDecodableObject() throws {
    struct Hotel: Codable, Hashable {
        let id: String
        let rating: Double
    }

    let hotel = Hotel(id: "H001", rating: 4.8)
    let encoded = try JSONEncoder().encode(hotel)
    let route = Route(path: "/hotel/details", params: ["hotel": .object(encoded)])

    let decoded: Hotel? = route.decode("hotel", as: Hotel.self)
    #expect(decoded == hotel)
}

// MARK: - DeepLinkHandler Tests

@Test("DeepLinkHandler should parse query params into type-safe RouteParams")
func testDeepLinkHandlerParsesCorrectly() async throws {
    guard let url = URL(string: "bookify://hotel/details?id=101&name=OceanView&rating=4.9&active=true")
    else { throw TestError("Invalid URL") }

    let route = DeepLinkHandler.shared.handle(url: url)

    #expect(route?.path == "/hotel/details")
    #expect(route?.int("id") == 101)
    #expect(route?.string("name") == "OceanView")
    #expect(route?.double("rating") == 4.9)
    #expect(route?.bool("active") == true)
    #expect(route?.source == .deeplink)
    #expect(route?.presentation == .push)
}

@Test("DeepLinkHandler should handle incomplete URLs gracefully")
func testDeepLinkHandlerHandlesInvalidURL() {
    let invalidURL = URL(string: "bookify://")!
    let route = DeepLinkHandler.shared.handle(url: invalidURL)
    #expect(route == nil)
}

@Test("DeepLinkHandler should parse boolean edge cases correctly")
func testDeepLinkHandlerBoolInference() {
    let urls = [
        URL(string: "bookify://profile?vip=yes")!,
        URL(string: "bookify://profile?vip=no")!,
        URL(string: "bookify://profile?vip=1")!,
        URL(string: "bookify://profile?vip=0")!
    ]

    let expected = [true, false, true, false]

    for (url, expectedValue) in zip(urls, expected) {
        let route = DeepLinkHandler.shared.handle(url: url)
        #expect(route?.bool("vip") == expectedValue)
    }
}

// MARK: - Route Equality & Encoding

@Test("Route should encode and decode consistently")
func testRouteCodableRoundTrip() throws {
    let route = Route(
        path: "/booking",
        params: ["id": .int(555), "confirmed": .bool(true)],
        source: .inApp,
        presentation: .sheet
    )

    let encoded = try JSONEncoder().encode(route)
    let decoded = try JSONDecoder().decode(Route.self, from: encoded)
    #expect(decoded == route)
}
