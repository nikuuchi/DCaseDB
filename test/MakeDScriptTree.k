Import("dcasecloud");
Import("JavaStyle.Object");
Import("Type.Json");
//Import("konoha.object");

Strategy makeStrategy(API repo, int argumentId, String description) {
	Json json = new Json();
	json.setString("description",description);
	json.setString("type","Strategy");
	return repo.CreateDBNode(argumentId,json) as Strategy;
}

Goal makeGoal(API repo, int argumentId, String description) {
	Json json = new Json();
	json.setString("description",description);
	json.setString("type","Goal");
	return repo.CreateDBNode(argumentId, json) as Goal;
}

Evidence makeEvidence(API repo, int argumentId, String description) {
	Json json = new Json();
	json.setString("description",description);
	json.setString("type","Evidence");
	return repo.CreateDBNode(argumentId, json) as Evidence;
}

Context makeContext(API repo, int argumentId, String description) {
	Json json = new Json();
	json.setString("description",description);
	json.setString("type","Context");
	return repo.CreateDBNode(argumentId, json) as Context;
}

void GenerateTree1(API repo) {
	DCaseArgument argument = repo.CreateArgument("サービスが正常に運用できる");
	int id = argument.argument_id;

	DBNode root = repo.GetArgument(id).GetRoot();

	Json json = new Json();
	json.setString("IP","192.168.0.1");
	json.setString("PORT","1234");
	repo.AddContext(id, root.node_id, json);

	Strategy s1 = makeStrategy(repo, id, "各種スクリプトで議論する");
	repo.InsertLink(id, root, s1);

	Goal g2_1 = makeGoal(repo, id, "サービスに関わるスクリプトが正常に動作する");
	repo.InsertLink(id, s1 , g2_1);

	Goal g2_2 = makeGoal(repo, id, "障害対応に関わるスクリプトが正常に動作する");
	repo.InsertLink(id, s1 , g2_2);

	Strategy s3 = makeStrategy(repo, id, "モニタリング／診断／対応のそれぞれについて議論する");
	repo.InsertLink(id, g2_2 , s3);

	Goal g4_1 = makeGoal(repo, id, "モニタリングスクリプトが正常に動作する");
	repo.InsertLink(id, s3, g4_1);

	Goal g4_2 = makeGoal(repo, id, "診断スクリプトが正常に動作する");
	repo.InsertLink(id, s3, g4_2);

	Goal g4_3 = makeGoal(repo, id, "対応スクリプトが正常に動作する");
	repo.InsertLink(id, s3, g4_3);

	Evidence e5_1 = makeEvidence(repo, id, "reboot.ds");
	repo.InsertLink(id, g4_3, e5_1);

	System.p(repo.GetArgument(id).toJson());
	System.p(repo.GetArgumentIds());
}

void GenerateTree2(API repo) {
	DCaseArgument argument = repo.CreateArgument("D-Scriptが正常に動作する");
	int id = argument.argument_id;

	DBNode root = repo.GetArgument(id).GetRoot();

	Json json = new Json();
	json.setString("Name","reboot.ds");
	json.setString("Script","System.p(\"exec: sudo shutdown -r now\");");
	repo.AddContext(id, root.node_id, json);

	Strategy s1 = makeStrategy(repo, id, "事前状態／事後状態で議論する");
	repo.InsertLink(id, root, s1);

	Goal g2_1 = makeGoal(repo, id, "事前にWebサーバが正常に動作している");
	repo.InsertLink(id, s1, g2_1);

	Goal g2_2 = makeGoal(repo, id, "事後にWebサーバが正常に動作している");
	repo.InsertLink(id, s1, g2_2);

	Evidence e3_1 = makeEvidence(repo, id, "check_server.ds");
	repo.InsertLink(id, g2_1, e3_1);
	repo.InsertLink(id, g2_2, e3_1);

	System.p(repo.GetArgument(id).toJson());
	System.p(repo.GetArgumentIds());
}

void main() {
	API repo = new API("dcasedb","dcasedb");
	GenerateTree1(repo);
	GenerateTree2(repo);
}

main();
