# JSONSchema static validation
JSONSchema is a swift framework that allows add support for json serialization to your models in a safe manner.

# JSON Schema standard
The core of `JSONSchema` is a standard used for validation json data defined called [json schema](http://json-schema.org/). The idea behind it is defining the schema for json structure (which includes attributes names, their types and values validation rules) in a separate json document. Having json schema defined enables to run it's validation check against any arbitrary json data and tell if it matches or not.

# JSONSchema overview
`JSONSchema` framework provides a way to define json schema in a typesafe manner (as opposed to having schema defined as another json document, thus unsafe) as well it adds some basic unboxing mechanics. Framework also provides better abstraction for parsed json data (better than `[String: Any]` provided by `NSJSONSerialization`) — `JSONValue` and `JSONObject`.

# Basic definitions
Framework consists of several parts which are the following:

## JSONValue
Adds thin layer of abstraction for any arbitrary json data. Represented as `enum` defining all basic json primitives: `null`, `bool`, `string`, `number`, `array`, `object`. `JSONObject` is a convenience typealias for `[String: JSONValue]`, also has convenience initializer for any untyped dictionary that usually comes out of `NSJSONSerialization`. Since untyped dictionary can theoretically contain non-json data, `JSONObject` initializer is failable. 

## JSONSchema
This is a core of a framework. `JSONSchemaType` is starting point for providing Schema definition. It's a protocol that your custom schema type has to implement in order for the type to be used as schema definition.

## SafeJSONSerializable
Defines a mix-in interface that any model type can adopt to start supporting json de-serialization using schema validation. Types adopting this protocol must provide associated schema type and the routine to unwrap data from json data object, that is called after validation successfully completed.

## Schema validation DSL
In order to build validation rules a set of functions is provided forming a kind of DSL that looks very closely to how validation rules are defined in json schema.


# Usage
Suppose you have a type representing model object like following:

```swift
struct MyModel {
    var boolField: Bool
    var stringField: String
    var arrayField: [Int]
}
```

in order to add json schema validation to this type you adopt `SafeJSONSerializable` protocol and define schema and de-serializaion routine:

```swift
extension MyModel: SafeJSONSerializable {
    struct Schema: JSONSchemaType {
        enum PropertyName: String {
            case bool_field
            case string_field
            case array_field
        }
        let required: [PropertyName] = [.bool_field]
        
        var properties: [PropertyName : JSONValueValidator] {
            return [
                .bool_field: bool(),
                .string_field: string(
                    length(min: 10, max: 50)
                ),
                .array_field: array(
                    items(
                        number()
                    )
                )
            ]
        }        
    }

    public static func fromValidatedJSON(json: [Schema.PropertyName : Any]) throws -> MyModel {
        let boolField = (json[.bool_field] as! Bool)
        let stringField = json[.string_field] as? String
        let arrayField = (json[.array_field] as? [JSONValue]).flatMap { $0.map { $0.asString() }}

        
        return MyModel(boolField: boolField,
                    stringField: stringField,
                    arrayField: arrayField
        )
    
    }
}
```

Notice how we unwrapping validated json data. First, we have values already unwrapped from JSONValue for primitives (except arrays and objects) as we can force cast `boolField` because it was explicitly marked as required in schema (which means it is guaranteed for the attribute to be present and be of that expected type.)
Also note, values in this `json` is only unwrapped on upper level. If there nested values, like array of `JSONValue`, or `JSONObject` — only container is unwrapped, and instead of `.array([JSONValue])` you will receive `[JSONValue]`.

In order to construct model object defined as described above, follow this:
```
let data: [String: Any] = ... //use NSJSONSerialization here
let jsonData = try! JSONObject(raw: data)
let model = try! MyModel.fromJSON(json: jsonData)
```


# Validators DSL reference
Here is the list of available DSL validators:

## Type validators
these make sure that value matches type
- `null`, `number`, `string`, `bool`, `object`, `array`

## String validators
- `format` matches built-in format, currently supported: `email`, `datetime`
- `pattern` that takes regular expression to match against
- `length` validates length of a string to match min and max values
- `enum` checks if value is within given list

## Number validators
- `value` checks if value is within given range
- `multipleOf` checks if value is of given multiple

## Array specific validators
- `items` take generic json value validator to check array members against
- `length` checks that array's count of items is within range
- `unique` checks of there are no duplicates in the array

## Combinatoric validators
Logical combination of given set of validators.

- `allOf`
- `anyOf`
- `oneOf`
- `noneOf`

# Credits
`JSONSchema` created by Sergey Gavrilyuk [@octogavrix](http://twitter.com/octogavrix).


## License
`JSONSchema` is distributed under MIT license. See LICENSE for more info.

## Contributing
Fork, branch & pull request.

