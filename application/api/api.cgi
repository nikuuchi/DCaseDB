#! /usr/local/bin/minikonoha

Import("Type.Json");
Import("Syntax.CStyleWhile");
Import("Syntax.Null");
Import("Java.Class");
Import("posix.process");
Import("Type.File");

String getMsg() {
	String mtd_type = System.getenv("REQUEST_METHOD");
	if (mtd_type != "POST") {
		// ERROR Handling: only POST Method is available
	}
	String query;
	String ln;
	FILE f = stdin;
	while ((ln = f.readLine()) != null) {
		query = query + ln;
	}
	return query;
}

void main() {
	Json j = Json.parse(getMsg());
	WebAPI api = new WebAPI();
	API_Method method = api.api[j.getString("method")];
	if (!method.paramCheck(j.get("params"))) {
		// error handling
	}
	String result = method.run(j.get("params"));
	flush(result);
}

main();
