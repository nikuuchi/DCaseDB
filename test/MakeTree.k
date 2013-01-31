Import("Deos.DCaseCloud");
Import("JavaStyle.Object");
Import("Type.Json");

Strategy makeStrategy(API repo, String description) {
	Json json = new Json();
	json.setString("description",description);
	json.setString("type","Strategy");
	return repo.CreateDBNode(json) as Strategy;
}

Goal makeGoal(API repo, String description) {
	Json json = new Json();
	json.setString("description",description);
	json.setString("type","Goal");
	return repo.CreateDBNode(json) as Goal;
}

Evidence makeEvidence(API repo, String description) {
	Json json = new Json();
	json.setString("description",description);
	json.setString("type","Evidence");
	return repo.CreateDBNode(json) as Evidence;
}

Context makeContext(API repo, String description) {
	Json json = new Json();
	json.setString("description",description);
	json.setString("type","Context");
	return repo.CreateDBNode(json) as Context;
}

void main() {
	API repo = new API("dcasedb","dcasedb");

	DCaseArgument argument = repo.CreateArgument("Basic Syntax");
	int id = argument.argument_id;

	DBNode root = repo.GetArgument(id).GetRoot();

	Strategy s1 = makeStrategy(repo, "Separated by Syntax");
	repo.InsertLink(id, root, s1);

	Goal g2_1 = makeGoal(repo, "Function Decralation");
	repo.InsertLink(id, s1 , g2_1);

	Goal g2_2 = makeGoal(repo, "Return Statement");
	repo.InsertLink(id, s1 , g2_2);

	System.p(repo.GetArgument(id).toJson());
	System.p(repo.GetArgumentIds());
}

main();
