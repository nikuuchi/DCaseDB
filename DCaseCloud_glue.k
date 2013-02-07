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

class PreparedStatement {
	Connection con;
	String[] queue;
	int id;

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
		this.id = this.con.getInsertId();
		this.con.query("DEALLOCATE PREPARE stmt1");
		return r;
	}

	int getInsertId(){
		return this.id;
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
/* //FIXME type DBNode
	@Public DBNode GetRootArgument() {}

	@Public DBNode GetNode(int NodeId) {
	}

	@Public DBNode[]  GetNodeTree(int NodeId) {
	}

	//Return NodeId
	@Public int GetNodeId(TopGoal ArgumentId) {
	}

	@Public GetNodeTree(int NodeId, int timeStart, int timeEnd) {
	}
*/

	//Return newNodeId
	@Public int Replace(int OldNodeId, Json /*DBNode*/ NewNodeTree) {
	}

	//Return newNodeId
	@Public int Add(int ParentNodeId, Json /*DBNode*/ ChildNodeTree) {
	}

	int InsertTimeLineId(int processContextId){
	}

	int initSnapshot() {
		String sql = "INSERT INTO `snapshot`(`prev_snapshot_id`,`unix_time`) VALUES(?,?)";
		PreparedStatement q = this.db.newPreparedStatement(sql);
		q.setInt("@a", 0);
		q.setInt("@b", new Date().getTime());
		q.execute();
		return q.getInsertId();
	}

	int initProcessContext(int snapshot_id, int processType, String justification, String commiter) {
		String sql = "INSERT INTO `process_context`(`current_snapshot_id`,`process_type`,`justification`,`commiter`) VALUES(?,?,?,?)";
		PreparedStatement q = this.db.newPreparedStatement(sql);
		q.setInt("@a",    snapshot_id);
		q.setInt("@b",    processType);
		q.setString("@c", justification);
		q.setString("@d", commiter);
		q.execute();
		return q.getInsertId();
	}

	int initArgument(int process_id) {
		PreparedStatement p = this.db.newPreparedStatement("INSERT INTO `argument`(`current_process_id`) VALUES(?)");
		p.setInt("@a", process_id);
		p.execute();
		return p.getInsertId();
	}

	int initTopGoal(int argument_id) {
		PreparedStatement p = this.db.newPreparedStatement("INSERT INTO `node_identity`(`argument_id`) VALUES(?)");
		p.setInt("@a", argument_id);
		p.execute();
		return p.getInsertId();
	}

	int getNodeType(String type_name) {
		PreparedStatement p = this.db.newPreparedStatement("SELECT `id` FROM `node_type` WHERE `type_name`=?");
		p.setString("@a", type_name);
		ResultSet r = p.execute();
		r.next();
		return r.getInt("id");
	}

	int createNodeData(int type_id, int node_id) {
		PreparedStatement p = this.db.newPreparedStatement("INSERT INTO `node_data`(`node_type_id`,`node_identity_id`) VALUES(?,?)");
		p.setInt("@a", type_id);
		p.setInt("@b", node_id);
		p.execute();
		return p.getInsertId();
	}

	void updateSnapshot(int node_id, int snapshot_id) {
		PreparedStatement p = this.db.newPreparedStatement("UPDATE `snapshot` SET `root_node_id`=? WHERE `id`=?");
		p.setInt("@a", node_id);
		p.setInt("@b", snapshot_id);
		p.execute();
	}

	void updateNodeIdentity(int node_identity_id, int node_data_id) {
		PreparedStatement p = this.db.newPreparedStatement("UPDATE `node_identity` SET `current_node_id`=? WHERE `id`=?");
		p.setInt("@a", node_data_id);
		p.setInt("@b", node_identity_id);
		p.execute();
	}

	void insertSnapshotNodeData(int snapshot_id, int argument_id) {
		PreparedStatement p = this.db.newPreparedStatement("INSERT INTO `snapshot_has_node_data`(snapshot_id,node_data_id) SELECT ? AS snapshot_id,current_node_id FROM node_identity WHERE argument_id=?");
		p.setInt("@a", snapshot_id);
		p.setInt("@b", argument_id);
		p.execute();
	}

	void insertSnapshotNodeLink(int snapshot_id, int argument_id) {
		PreparedStatement p = this.db.newPreparedStatement("INSERT INTO `node_link_has_snapshot`(node_link_id,snapshot_id) SELECT ? AS snapshot_id,current_node_link_id FROM link_identity WHERE argument_id=?");
		p.setInt("@a", snapshot_id);
		p.setInt("@b", argument_id);
		p.execute();
	}

	void insertProcessContextHasSnapshot(int process_id, int snapshot_id) {
		PreparedStatement p = this.db.newPreparedStatement("INSERT INTO `process_context_has_snapshot` (`process_context_id`,`snapshot_id`) VALUES(?,?)");
		p.setInt("@a", process_id);
		p.setInt("@b", snapshot_id);
		p.execute();
	}

	void insertArgumentHasProcessContext(int process_id, int argument_id) {
		PreparedStatement p = this.db.newPreparedStatement("INSERT INTO `argument_has_process_context` (`argument_id`,`process_context_id`) VALUES(?,?)");
		p.setInt("@a", argument_id);
		p.setInt("@b", process_id);
		p.execute();
	}

	@Public int CreateTopGoal(String description, int processType, String justification, String commiter) {
		int snapshot_id = this.initSnapshot();
		System.p(snapshot_id);
		int process_id  = this.initProcessContext(snapshot_id,processType,justification,commiter);
		System.p(process_id);
		int argument_id = this.initArgument(process_id);
		System.p(argument_id);
		int top_goal_id = this.initTopGoal(argument_id);
		System.p(top_goal_id);
		int node_type_id = this.getNodeType("Goal");
		System.p(node_type_id);
		int node_data_id = this.createNodeData(node_type_id,top_goal_id);
		System.p(node_data_id);
		this.updateNodeIdentity(top_goal_id,node_data_id);
		this.updateSnapshot(top_goal_id,snapshot_id); //FIXME
		this.insertSnapshotNodeData(snapshot_id,argument_id);
		this.insertProcessContextHasSnapshot(process_id,snapshot_id);
		this.insertArgumentHasProcessContext(process_id,argument_id);

		return argument_id;
	}

	//Return newNodeId
	@Public int DeleteLink(int ParentNodeId, Json /*DBNode*/ TargetNode/*FIXME*/) {
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
