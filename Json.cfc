/**
 * Component containing functions for working with JSON.
 */
component {

	/**
	 * Efficiently writes the given object to the given output stream.
	 * This is superior to using serializeJson, because that function builds and returns the entire serialized string; whereas this method streams it, resulting in a smaller memory footprint.
	 * This method closes the stream.
	 * @data An array, query, struct, or simple value.
	 * @outputStream An output stream to stream to. If omitted, the output stream for the response is used instead.
	 */
	public void function writeToStream(required any data, any outputStream = getPageContext().getResponse().getOutputStream()) {
		local.jsonGenerator = getJsonLib().createGenerator(arguments.outputStream);
		generateAny(arguments.data, local.jsonGenerator);
		local.jsonGenerator.close();
	}

	/**
	 *
	 */
	private void function generateAny(required any data, required any jsonGenerator, string name) {
		if (structKeyExists(arguments, "name")) {
			if (isArray(arguments.data)) {
				generateArray(arguments.data, arguments.jsonGenerator, arguments.name);
			} else if (isQuery(arguments.data)) {
				generateQuery(arguments.data, arguments.jsonGenerator, arguments.name);
			} else if (isStruct(arguments.data)) {
				generateStruct(arguments.data, arguments.jsonGenerator, arguments.name);
			} else {
				generateSimpleValue(arguments.data, arguments.jsonGenerator, arguments.name);
			}
		} else {
			if (isArray(arguments.data)) {
				generateArray(arguments.data, arguments.jsonGenerator);
			} else if (isQuery(arguments.data)) {
				generateQuery(arguments.data, arguments.jsonGenerator);
			} else if (isStruct(arguments.data)) {
				generateStruct(arguments.data, arguments.jsonGenerator);
			} else {
				generateSimpleValue(arguments.data, arguments.jsonGenerator);
			}
		}
	}

	/**
	 *
	 */
	private void function generateArray(required array data, required any jsonGenerator, string name) {
		if (structKeyExists(arguments, "name")) {
			arguments.jsonGenerator.writeStartArray(arguments.name);
		} else {
			arguments.jsonGenerator.writeStartArray();
		}
		for (local.item in arguments.data) {
			generateAny(local.item, arguments.jsonGenerator);
		}
		arguments.jsonGenerator.writeEnd();
	}

	/**
	 *
	 */
	private void function generateQuery(required query data, required any jsonGenerator, string name) {
		if (structKeyExists(arguments, "name")) {
			arguments.jsonGenerator.writeStartObject(arguments.name);
		} else {
			arguments.jsonGenerator.writeStartObject();
		}
		arguments.jsonGenerator.writeStartArray("COLUMNS");
		local.columnNames = arguments.data.getColumnNames();
		for (local.columnName in local.columnNames) {
			arguments.jsonGenerator.write(local.columnName);
		}
		arguments.jsonGenerator.writeEnd();
		arguments.jsonGenerator.writeStartArray("DATA");
		for (local.r = 1; local.r lte arguments.data.recordCount; local.r++) {
			arguments.jsonGenerator.writeStartArray();
			for (local.columnName in local.columnNames) {
				try {
					arguments.jsonGenerator.write(arguments.data[local.columnName][local.r]);
				} catch (any e) {
					arguments.jsonGenerator.write(javaCast("string", arguments.data[local.columnName][local.r]));
				}
			}
			arguments.jsonGenerator.writeEnd();
		}
		arguments.jsonGenerator.writeEnd();
		arguments.jsonGenerator.writeEnd();
	}

	/**
	 *
	 */
	private void function generateSimpleValue(required any data, required any jsonGenerator, string name) {
		if (isNumeric(arguments.data)) {
			arguments.data = javaCast("bigdecimal", arguments.data);
		} else if (isBoolean(arguments.data)) {
			arguments.data = javaCast("boolean", arguments.data);
		}
		if (structKeyExists(arguments, "name")) {
			arguments.jsonGenerator.write(arguments.name, arguments.data);
		} else {
			arguments.jsonGenerator.write(arguments.data);
		}
	}

	/**
	 *
	 */
	private void function generateStruct(required struct data, required any jsonGenerator, string name) {
		if (structKeyExists(arguments, "name")) {
			arguments.jsonGenerator.writeStartObject(arguments.name);
		} else {
			arguments.jsonGenerator.writeStartObject();
		}
		for (local.key in arguments.data) {
			generateAny(arguments.data[local.key], arguments.jsonGenerator, local.key);
		}
		arguments.jsonGenerator.writeEnd();
	}

	/**
	 *
	 */
	private any function getJsonLib() {
		if (not structKeyExists(variables, "jsonLib")) {
			variables.jsonLib = createObject("java", "javax.json.Json");
		}
		return variables.jsonLib;
	}

}