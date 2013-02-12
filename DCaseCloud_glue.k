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
		this.con.query("SET ${param} = '${value}'"); //FIXME
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

class DCaseModel {
	DataBase db;

	@Public DCaseModel(String userName, String password) {
		this.db = new DataBase(userName, password);
	}

	@Public int[] GetArgumentList() {
		PreparedStatement q = this.db.newPreparedStatement("SELECT `id` FROM `argument`");
		ResultSet r = q.execute();
		int[] ret = [];
		while(r.next()) {
			ret.add(r.getInt("id"));
		}
		return ret;
	}

	Json CreateJsonNode(ResultSet r) {
		Json json = new Json();
		json.setInt("node_id", r.getInt("node_identity_id"));
		json.setString("url", r.getString("url"));
		json.setString("description", r.getString("description"));
		json.setBoolean("delete_flag", r.getBoolean("delete_flag"));
		json.setString("type", r.getString("type_name"));
		return json;
	}

	//Return Node
	@Public Json GetNode(int node_id) {
		PreparedStatement q = this.db.newPreparedStatement("SELECT node_identity_id, url, description, delete_flag,type_name FROM node_identity INNER JOIN node_data ON current_node_id=node_data.id INNER JOIN node_type ON node_type_id=node_type.id WHERE node_identity.id=?");
		q.setInt("@a",node_id);
		ResultSet r = q.execute();
		r.next();
		return this.CreateJsonNode(r);
	}

	Json GetNodeList(int snapshot_id) {
			PreparedStatement q = this.db.newPreparedStatement("SELECT node_identity_id, url, description, delete_flag,type_name FROM node_data INNER JOIN snapshot_has_node_data ON node_data_id=node_data.id  INNER JOIN node_type ON node_type_id=node_type.id WHERE snapshot_id=?");
		q.setInt("@a", snapshot_id);
		ResultSet r = q.execute();
		Json json_array = new Json([]);
		while(r.next()) {
			Json json = this.CreateJsonNode(r);
			json_array.add(json);
		}
		return json_array;
	}

	Json GetLinkList(int snapshot_id) {
			PreparedStatement q = this.db.newPreparedStatement("SELECT parent_node_id,child_node_id FROM node_link_has_snapshot INNER JOIN node_link ON node_link_id=node_link.id WHERE snapshot_id=?");
		q.setInt("@a", snapshot_id);
		ResultSet r = q.execute();
		Json json_array = new Json([]);
		while(r.next()) {
			//FIXME
			Json json = new Json();
			json.setInt("parent_node_id", r.getInt("parent_node_id"));
			json.setInt("child_node_id", r.getInt("child_node_id"));
			json_array.add(json);
		}
		return json_array;
	}

	int getTopGoalId(int snapshot_id) {
		PreparedStatement p = this.db.newPreparedStatement("SELECT `root_node_id` FROM `snapshot` WHERE `id`=?");
		p.setInt("@a", snapshot_id);
		ResultSet r = p.execute();
		r.next();
		return r.getInt("root_node_id");
	}

	Json _GetNodeTree(int argument_id, int top_goal_id, int snapshot_id) {
		Json tree = new Json();
		tree.setInt("argument_id",argument_id);
		tree.setInt("snapshot_id",snapshot_id);
		tree.setInt("top_goal_id",top_goal_id);
		Json nodeList = this.GetNodeList(snapshot_id);
		tree.set("nodes", nodeList);
		Json linkList = this.GetLinkList(snapshot_id);
		tree.set("links", linkList);
		return tree;
	}

	//Return NodeTree
	@Public Json  GetNodeTree(int argument_id) {
		int current_snapshot_id = this.getCurrentSnapShot(argument_id);
		int top_goal_id = this.getTopGoalId(current_snapshot_id);
		return this._GetNodeTree(argument_id,top_goal_id,current_snapshot_id);
	}

	//Return NodeId
//	@Public int GetNodeId(TopGoal ArgumentId) {
//	}

	int[] _GetSnapshotList(int start_id, int end_id) {
		int[] ret = [];
		ret.add(end_id);
		int it = end_id;
		while(it !=start_id) {
			PreparedStatement p = this.db.newPreparedStatement("SELECT `prev_snapshot_id` FROM `snapshot` WHERE `id`=?");
			p.setInt("@a", it);
			ResultSet r = p.execute();
			r.next();
			it = r.getInt("prev_snapshot_id");
			if(it == 0) {
				break;
			}
			ret.add(it);
		}
		int[] reverse = [];
		int i = ret.getSize()-1;
		while(i>0) {
			reverse.add(ret[i]);
			i = i - 1;
		}
		return reverse;
	}

	@Public Json GetNodeTree(int argument_id, int snapshot_start_id, int snapshot_end_id) {
		Json array_json = new Json([]);
		int i = 0;
		int[] ids = this._GetSnapshotList(snapshot_start_id,snapshot_end_id);//TODO get snapshot_id[]
		while(i < ids.getSize()) {
			int top_goal_id = this.getTopGoalId(ids[i]);
			array_json.add(this._GetNodeTree(argument_id,top_goal_id,ids[i]));
			i = i + 1;
		}
		return array_json;
	}

	//Return newNodeId
	@Public int Replace(int OldNodeId, Json /*DBNode*/ NewNodeTree) {
	}

	//Return newNodeId
	@Public int Add(int ParentNodeId, Json /*DBNode*/ ChildNodeTree) {
	}

	int initSnapshot(int prev_snapshot_id, int root_node_id) {
		String sql = "INSERT INTO `snapshot`(`prev_snapshot_id`,`unix_time`, `root_node_id`) VALUES(?,?,?)";
		PreparedStatement q = this.db.newPreparedStatement(sql);
		q.setInt("@a", prev_snapshot_id);
		q.setInt("@b", new Date().getTime());
		q.setInt("@c", root_node_id);
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

	int initNode_identity(int argument_id) {
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

	int createNodeData(int type_id, int node_id, String description, String url) {
		PreparedStatement p = this.db.newPreparedStatement("INSERT INTO `node_data`(`node_type_id`,`node_identity_id`,`description`, `url`) VALUES(?,?,?,?)");
		p.setInt("@a", type_id);
		p.setInt("@b", node_id);
		p.setString("@c", description);
		p.setString("@d", url);
		p.execute();
		return p.getInsertId();
	}

	void updateSnapshot(int node_id, int snapshot_id) {
		PreparedStatement p = this.db.newPreparedStatement("UPDATE `snapshot` SET `root_node_id`=? WHERE `id`=?");
		p.setInt("@a", node_id);
		p.setInt("@b", snapshot_id);
		p.execute();
	}

	void updateProcessContext(int process_id, int current_snapshot_id) {
		PreparedStatement p = this.db.newPreparedStatement("UPDATE process_context SET current_snapshot_id=? WHERE id=?");
		p.setInt("@a", current_snapshot_id);
		p.setInt("@b", process_id);
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
		PreparedStatement p = this.db.newPreparedStatement("INSERT INTO `node_link_has_snapshot`(node_link_id,snapshot_id) SELECT current_node_link_id,? AS snapshot_id FROM link_identity WHERE argument_id=?");
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
		int snapshot_id = this.initSnapshot(0,0);
		int process_id  = this.initProcessContext(snapshot_id,processType,justification,commiter);
		int argument_id = this.initArgument(process_id);
		int top_goal_id = this.initNode_identity(argument_id);
		int node_type_id = this.getNodeType("Goal");
		int node_data_id = this.createNodeData(node_type_id,top_goal_id,description,"");
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

	@Public int CreateNode(int argument_id, Json json) {
		int node_id = this.initNode_identity(argument_id);
		int type_id = this.getNodeType(json.getString("type"));
		int node_data_id = this.createNodeData(type_id,node_id,json.getString("description"),json.getString("url"));
		this.updateNodeIdentity(node_id,node_data_id);
		return node_id;
	}

	@Public void UpdateNode(int argument_id, Json json) {
		int node_id = json.getString("node_id").toint;
		int type_id = this.getNodeType(json.getString("type"));
		int node_data_id = this.createNodeData(type_id,node_id,json.getString("description"),json.getString("url"));
		this.updateNodeIdentity(node_id,node_data_id);
	}

	@Public void DeleteNode(int argument_id, Json json) {
		/* //TODO
		int node_id = json.getString("node_id").toint;
		int type_id = this.getNodeType(json.getString("type"));
		int node_data_id = this.createNodeData(type_id,node_id,json.getString("description"),json.getString("url"));
		this.updateNodeIdentity(node_id,node_data_id);
		*/
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

	void updatelinkIdentity(int identity_id,int link_id){
		PreparedStatement p = this.db.newPreparedStatement("UPDATE `link_identity` SET current_node_link_id=? WHERE `id`=?");
		p.setInt("@a",link_id);
		p.setInt("@b",identity_id);
		p.execute();
	}

	void CreateLink(int argument_id, Map[int] node_ids, Json json) {
		int parent_id;
		int child_id;
		if(json.hasKey("parent")) {
			parent_id = node_ids.get(json.getString("parent_node_id"));
		} else {
			parent_id = json.getInt("parent_node_id");
		}
		if(json.hasKey("child")) {
			child_id = node_ids.get(json.getString("child_node_id"));
		} else {
			child_id = json.getInt("child_node_id");
		}
		PreparedStatement p = this.db.newPreparedStatement("INSERT INTO `link_identity`(`argument_id`) VALUES(?)");
		p.setInt("@a",argument_id);
		p.execute();
		int link_id = p.getInsertId();

		PreparedStatement p_node_link = this.db.newPreparedStatement("INSERT INTO `node_link`(`parent_node_id`,`child_node_id`,`link_identity_id`) VALUES(?,?,?)");
		p_node_link.setInt("@a",parent_id);
		p_node_link.setInt("@b",child_id);
		p_node_link.setInt("@c",link_id);
		p_node_link.execute();
		int l_id = p_node_link.getInsertId();
		this.updatelinkIdentity(link_id,l_id);
	}

	int getCurrentSnapShot(int argument_id) {
		PreparedStatement p = this.db.newPreparedStatement("SELECT current_snapshot_id FROM argument INNER JOIN process_context ON current_process_id=process_context.id WHERE argument.id=?");
		p.setInt("@a", argument_id);
		ResultSet r = p.execute();
		r.next();
		return r.getInt("current_snapshot_id");
	}

	int getCurrentProcessContext(int argument_id) {
		PreparedStatement p = this.db.newPreparedStatement("SELECT current_process_id FROM argument WHERE id=?");
		p.setInt("@a", argument_id);
		ResultSet r = p.execute();
		r.next();
		return r.getInt("current_process_id");
	}

	@Public Json Commit(int argument_id, Json args) {
		int prev_snapshot_id = this.getCurrentSnapShot(argument_id);
		int process_id  = this.getCurrentProcessContext(argument_id);
		int top_goal_id = this.getTopGoalId(prev_snapshot_id);
		int snapshot_id = this.initSnapshot(prev_snapshot_id,top_goal_id); //FIXME
		System.p(prev_snapshot_id);
		this.updateProcessContext(process_id,snapshot_id);

		Json nodes = args.get("nodes");
		Map[int] node_ids = new Map[int];
		int i = 0;
		System.p(nodes);
		while(i < nodes.getSize()) {
			System.p("hoge");
			String method = nodes[i].getString("method");
			if(method == "Create") { //FIXME
				node_ids.set(nodes[i].getString("node_id"),this.CreateNode(argument_id,nodes[i]));
			}else if(method == "Update") {
				this.UpdateNode(argument_id,nodes[i]);
			}else if(method == "Delete") {
				this.DeleteNode(argument_id,nodes[i]);
			}//TODO Error Handling
			i = i + 1;
		}

		Json links = args.get("links");
		i = 0;
		while(i < links.getSize()) {
			String method = links[i].getString("method");
			if(method == "Create") { //FIXME
				this.CreateLink(argument_id,node_ids,links[i]);
			}else if(method == "Delete") {
				//FIXME
			}
			i = i + 1;
		}

		this.insertSnapshotNodeData(snapshot_id,argument_id);
		this.insertSnapshotNodeLink(snapshot_id,argument_id);
	}

// ProcessContext
	//return ProcessId
	@Public int OpenProcessContext(int argument_id, int process_type, String justification, String commiter_name) {
		int current_snapshot_id = this.getCurrentSnapShot(argument_id);
		return this.initProcessContext(current_snapshot_id, process_type, justification, commiter_name);
	}

	@Public int CloseProcessContext(int argument_id, int process_id, String justification) {
		//TODO
	}

	@Public int[] GetProcessContextIds(int argument_id) {
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
