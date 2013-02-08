Import("Deos.DCaseCloud");
Import("Type.Json");
Import("JavaScript.Array");

void main() {
	API api = new API("dcasedb","dcasedb");
	int id = api.CreateTopGoal("description test",1,"this is the test justification","foo commiter");
	Json nodeTree = api.GetNodeTree(id);
	int top_id = nodeTree.getInt("top_goal_id");
	System.p(api.GetNode(top_id));

	Json tree = new Json();
	Json nodes = new Json([]);
	tree.set("nodes",nodes);
	Json strategy = new Json();
	strategy.setString("method","Create");
	strategy.setString("node_id","hoge1");
	strategy.setString("description","test description");
	strategy.setString("type","Strategy");
	strategy.setString("url","www.sample");
	nodes.add(strategy);

	Json links = new Json([]);
	tree.set("links",links);
	Json l = new Json();
	l.setString("method","Create");
	l.setString("child","new");
	l.setInt("parent_node_id",top_id);
	l.setString("child_node_id","hoge1");
	links.add(l);

	api.Commit(id,tree);
	System.p(api.GetNodeTree(id));

}

main();
