import ApolloAPI



public extension BoosterSchema {
    struct JSON: CustomScalarType, Hashable {
        /// The `JSON` scalar type represents JSON values as specified by [ECMA-404](http://www.ecma-international.org/publications/files/ECMA-ST/ECMA-404.pdf).
        let value: JSONValue

        public init(_jsonValue value: JSONValue) throws {
            if let value = value as? String {
                self.value = value
            } else if let value = value as? JSONObject {
                self.value = value
            } else {
                throw JSONDecodingError.couldNotConvert(value: value, to: String.self)
            }
        }

        public var _jsonValue: JSONValue { value }
    }
}
