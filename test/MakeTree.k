Import("Deos.DCaseCloud");

void main() {
	API api = new API("dcasedb","dcasedb");
	int id = api.CreateTopGoal("description test",1,"this is the test justification","foo commiter");
	System.p(api.GetArgumentList());
	System.p(api.GetNodeTree(id));
	System.p(api.GetNode(id));
}

main();
