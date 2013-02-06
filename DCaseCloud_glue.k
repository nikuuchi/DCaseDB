Import("Type.Json");
Import("Syntax.CStyleWhile");
Import("Syntax.Null");
Import("Syntax.GlobalVariable");
Import("Syntax.StringInterpolation");
Import("Java.Class");
Import("MiniKonoha.NameSpace");
Import("MiniKonoha.Map");
Import("MiniKonoha.Sql");
Import("JavaStyle.Object");
Import("JavaScript.Array");
Import("JavaScript.Date");

//TODO Array.splice()
int[] ArrayInt_insert(int[] a,int index, int[] i) {
	int[] a_end = a.slice(index);
	int[] a_start = a.slice(0,index);
	int[] aa = a_start.concat(i);
	return aa.concat(a_end);
}

class PreparedStatement {
	Connection con;
	String[] queue;

	//TODO Array.join()
	String join() {
		if(this.queue.getSize() == 0) {
			return "";
		}
		int i = 0;
		String ret = " USING ";
		while(i < this.queue.getSize()-1) {
			ret = ret + this.queue[i] + ",";
			i = i + 1;
		}
		ret = ret + this.queue[this.queue.getSize()-1];
		return ret;
	}

	PreparedStatement(Connection con, String sql) {
		this.con = con;
		this.queue = [];
		this.con.query("PREPARE stmt1 FROM '${sql}'");
	}

	void setString(String param, String value) {
		this.con.query("SET ${param} = '${value}'");
		this.queue.add(param);
	}

	void setInt(String param, int value) {
		this.con.query("SET ${param} = ${value}");
		this.queue.add(param);
	}

	void setBoolean(String param, boolean value) {
		if(value) {
			this.con.query("SET ${param} = TRUE");
		}else {
			this.con.query("SET ${param} = FALSE");
		}
		this.queue.add(param);
	}

	ResultSet execute() {
		ResultSet r = this.con.query("EXECUTE stmt1 "+this.join());
		this.con.query("DEALLOCATE PREPARE stmt1");
		return r;
	}

	int getInsertId(){
		return this.con.getInsertId();
	}
}

class DataBase {
	Connection con;

	DataBase(String userName, String password) {
		this.con = new Connection("mysql://${userName}:${password}@localhost:3306");
		this.con.query("USE dcasecloud;");
	}

	PreparedStatement newPreparedStatement(String q) {
		return new PreparedStatement(this.con, q);
	}

}

class API {
	DataBase db;
	@Public API(String userName, String password) {
		this.db = new DataBase(userName, password);
	}

	@Public DBNode GetRootArgument() {
	}

	@Public DBNode GetNode(int NodeId) {
	}

	@Public DBNode[]  GetNodeTree(int NodeId) {
	}

	//Return NodeId
	@Public int GetNodeId(TopGoal ArgumentId) {
	}

	@Public GetNodeTree(int NodeId,int timeStart/*TimeLineId*/, int timeEnd/*TimeLineId*/) {
	}

	//Return newNodeId
	@Public int Replace(int OldNodeId, DBNode NewNodeTree) {
	}

	//Return newNodeId
	@Public int Add(int ParentNodeId,Json ChildNodeTree) {
	}

	int InsertTimeLineId(int processContextId){
	}

	@Public Json CreateTopGoal(String Description) {
	}

	//Return newNodeId
	@Public int DeleteLink(int ParentNodeId,DBNode TargetNode/*FIXME*/) {
	}

	//Return NodeId TODO AwayGoal
	@Public int NewLink(int ParentNodeId,int TargetNodeId) {
	}

	int GetNodeTypeId(String NodeType) {
	}

	@Public int CreateNode(String NodeType, String Description, int TimeLineId) {
	}

	//Return Array[NodeId]
	@Public int[] FindNodeFrom(String NodeType, String NodeIdSearchFrom) {
	}

	//Return Array[NodeId]
	@Public int[] FindNodeByDescription(String SearchText) {
	}

	//Return Array[NodeId]
	@Public int[] FindContextByProperty(String SearchText) {
	}

// ProcessContext
	//return ProcessId
	@Public int OpenProcessContext(int ArgumentId, int ProcessType, String CommiterName) {
	}

	@Public int CloseProcessContext(int ArgumentId, int ProcessId, String Justification) {
	}

	@Public int[] GetProcessContextIds(int ArgumentId) {
	}

//### D-Script
	//return ContextJson
	@Public Json GetContext(int NodeId) {
	}

	@Public void Support(int EvidenceNodeId, int ProcessId) {
	}

	@Public void Rebuttal(int EvidenceNodeId, int ProcessId, String Diagnosis) {
	}
}
