#! /usr/local/bin/konoha

Import("Type.Json");
Import("Syntax.CStyleWhile");
Import("Syntax.Null");
Import("Java.Class");
Import("posix.process");
Import("Type.File");

Load("methods.k");

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
	JsonRPCServer api = new JsonRPCServer();
	api.registerFunctions();
	//if (!method.paramCheck(j.get("params"))) {
		// error handling
	//}
	api.dispatch(j.getString("method",j.get("params")));
}

main();
