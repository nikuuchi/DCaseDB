Import("MiniKonoha.NameSpace");
Import("JavaScript.Array");
Import("JavaStyle.Object");
Import("Syntax.JavaStyleClass");
Load("JsonRpc.k");

const IntList=Array[int];
@Public IntList ConvertToIntList(Json json) {
	IntList a = [];
	int i, length = json.getSize();
	while(i < length) {
		a.add(json.getInt(i));
		i = i + 1;
	}
	return a;
}

class Api extends JsonRPCServer {
	void CreateTopGoal (Json request) {
		String Justification = request.getString("Justification");
		String description = request.getString("description");
		String commiter = request.getString("commiter");
		int processType = request.getInt("processType");
		Json request = createMessage("FIXME");
		emitResponse(request);
	}

	void DeleteLink (Json request) {
		int ParentNodeId = request.getInt("ParentNodeId");
		Json TargetNode = request.get("TargetNode");
		Json request = createMessage("FIXME");
		emitResponse(request);
	}

	void NewLink (Json request) {
		int ParentNodeId = request.getInt("ParentNodeId");
		int TargetNodeId = request.getInt("TargetNodeId");
		Json request = createMessage("FIXME");
		emitResponse(request);
	}

	void CreateNode (Json request) {
		int BelongedArgumentId = request.getInt("BelongedArgumentId");
		Json json = request.get("json");
		Json request = createMessage("FIXME");
		emitResponse(request);
	}

	void UpdateNode (Json request) {
		int BelongedArgumentId = request.getInt("BelongedArgumentId");
		Json json = request.get("json");
		Json request = createMessage("FIXME");
		emitResponse(request);
	}

	void DeleteNode (Json request) {
		int BelongedArgumentId = request.getInt("BelongedArgumentId");
		Json json = request.get("json");
		Json request = createMessage("FIXME");
		emitResponse(request);
	}

	void FindNodeFrom (Json request) {
		String NodeType = request.getString("NodeType");
		int NodeIdSearchFrom = request.getInt("NodeIdSearchFrom");
		Json request = createMessage("FIXME");
		emitResponse(request);
	}

	void FindNodeByDescription (Json request) {
		String SearchText = request.getString("SearchText");
		Json request = createMessage("FIXME");
		emitResponse(request);
	}

	void FindContextByProperty (Json request) {
		String SearchText = request.getString("SearchText");
		Json request = createMessage("FIXME");
		emitResponse(request);
	}

	void Commit (Json request) {
		int BelongedArgumentId = request.getInt("BelongedArgumentId");
		Json args = request.get("args");
		Json request = createMessage("FIXME");
		emitResponse(request);
	}

	void getNode (Json request) {
		int node_id = request.getInt("node_id");
		Json request = createMessage("FIXME");
		emitResponse(request);
	}

	void getArgumentList (Json request) {
		Json request = createMessage("FIXME");
		emitResponse(request);
	}

	void getNodeTree (Json request) {
		int BelongedArgumentId = request.getInt("BelongedArgumentId");
		Json request = createMessage("FIXME");
		emitResponse(request);
	}

	void getNodeTree (Json request) {
		int BelongedArgumentId = request.getInt("BelongedArgumentId");
		int SnapshotId = request.getInt("SnapshotId");
		Json request = createMessage("FIXME");
		emitResponse(request);
	}

	void getNodeTree (Json request) {
		int BelongedArgumentId = request.getInt("BelongedArgumentId");
		int snapshot_start_id = request.getInt("snapshot_start_id");
		int snapshot_end_id = request.getInt("snapshot_end_id");
		Json request = createMessage("FIXME");
		emitResponse(request);
	}

	void OpenProcessContext (Json request) {
		String Justification = request.getString("Justification");
		int process_type = request.getInt("process_type");
		int BelongedArgumentId = request.getInt("BelongedArgumentId");
		String commiter_name = request.getString("commiter_name");
		Json request = createMessage("FIXME");
		emitResponse(request);
	}

	void CloseProcessContext (Json request) {
		int BelongedArgumentId = request.getInt("BelongedArgumentId");
		int process_id = request.getInt("process_id");
		String Justification = request.getString("Justification");
		Json request = createMessage("FIXME");
		emitResponse(request);
	}

	void getProcessContextIds (Json request) {
		int BelongedArgumentId = request.getInt("BelongedArgumentId");
		Json request = createMessage("FIXME");
		emitResponse(request);
	}

	void getSnapshotList (Json request) {
		int BelongedArgumentId = request.getInt("BelongedArgumentId");
		Json request = createMessage("FIXME");
		emitResponse(request);
	}

	void getContext (Json request) {
		int NodeId = request.getInt("NodeId");
		Json request = createMessage("FIXME");
		emitResponse(request);
	}

	void Support (Json request) {
		int EvidenceNodeId = request.getInt("EvidenceNodeId");
		int ProcessId = request.getInt("ProcessId");
		Json request = createMessage("FIXME");
		emitResponse(request);
	}

	void Rebuttal (Json request) {
		int EvidenceNodeId = request.getInt("EvidenceNodeId");
		int ProcessId = request.getInt("ProcessId");
		String Diagnosis = request.getString("Diagnosis");
		Json request = createMessage("FIXME");
		emitResponse(request);
	}
}
