Load("testClient.k");

void test() {
	HttpClient client = new CurlHttpClient("http://localhost/DCaseDB/application/api/api.cgi");
	Map[String] map = new Map[String]();
	map.set("JSON", "{\"jsonrpc\":\"2.0\",\"version\":\"1.0\",\"method\" :\"OpenProcessContext\",\"params\" :{\"Justification\" : \"Sample Justification\",\"ProcessType\"    : 2,\"BelongedArgumentId\" : 26,\"Commiter\" : \"uchida\"}}");
	System.p(client.post(map));
}

test();
