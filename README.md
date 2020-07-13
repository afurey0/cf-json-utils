# cf_json_utils

ColdFusion component for working with JSON.

## Functions

### writeToStream

Takes an array, struct, query, or simple value and an output stream. Serializes the first argument as JSON and writes it to the output stream. For the first argument, any combination of nested arrays, structs, queries, and simple values is allowed. If no output stream is provided, the response's output stream is used by default.

#### Comparison to Built-in Serialization

Using ColdFusion's built-in serialization works well in most situations, but can be inefficient in a few cases. Take, for example, a piece of code that outputs JSON for an ajax response:

```cfml
<cfscript>
  myData = queryExecute(...);
  writeOutput(serializeJson(myData)); // build a serialized string from myData in memory, then write it to the output stream
  abort;
</cfscript>
```

The above code consumes memory unnecessarily, because `myData` will be in memory at the same time as the JSON serialization of `myData`. If `myData` is extremely large (e.g. a query with a million+ rows), this can cause a java heap space error. The `writeToStream` method is more efficient in this scenario, because it streams the serialization gradually instead of building one big string in memory. Combine with a `cfflush` tag with the `interval` attribute so ColdFusion can flush the output buffer as it fills up.

```cfml
<cfscript>
  myData = queryExecute(...);
  cfflush(interval=10000); // tell ColdFusion to flush the output stream as it fills up
  new Json().writeToStream(myData); // stream the serialization of myData to the output stream
  abort;
</cfscript>
```
