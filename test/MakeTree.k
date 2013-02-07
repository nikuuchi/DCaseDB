Import("Deos.DCaseCloud");

void main() {
	API api = new API("dcasedb","dcasedb");
	api.CreateTopGoal("description test",1,"this is the test justification","foo commiter");
}

main();
