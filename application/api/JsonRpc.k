Import("Type.Json");
Import("MiniKonoha.NameSpace");
Import("MiniKonoha.Map");
Import("JavaScript.Array");
Import("Syntax.JavaStyleClass");
Import("Syntax.JavaNewArray");
Import("Syntax.CStyleWhile");
Load("Http.k");

class JsonRPC {
    String version;
    JsonRPC() {
        version = "2.0";
    }
    Json createMessage() {
        Json json = new Json();
        json.setString("jsonrpc", "2.0");
        json.setString("version", "0.0");
        return json;
    }
}

class JsonRPCClient extends JsonRPC {
    String URL;
    HttpClient http;
    JsonRPCClient(String URL) {
        this.URL = URL;
        this.http = new CurlHttpClient(URL);
    }
    Json createMessage(String method, Json[] params) {
        Json json = createMessage();
        Json jsonParam = new Json(Array);
        int i = 0;
        while (i < params.getlength()) {
            jsonParam.add(params[i]);
            i = i + 1;
        }
        json.setString("method", method);
        json.set("params", jsonParam);
        return json;
    }
    Json emitRequest(Json request) {
        Map[String] map = new Map[String]();
        map.set("request", request.toString());
        String res = http.post(map);
        Json json = Json.parse(res);
        return json;
    }
}

class JsonRPCServer extends JsonRPC {
    Map[Func[void, Json]] functions;
    JsonRPCServer() {
        functions = new Map[Func[Json, Json]]();
    }
    void dispatch(Json request);
    void registerFunction(String key, Func[void, Json] func) {
        functions[key] = func;
    }
    Json createMessage(String result) {
        Json json = createMessage();
        json.set("result", result);
        return json;
    }
    Json emitResponse(Json req) {
        assert(false);
        return "";
    }
}
