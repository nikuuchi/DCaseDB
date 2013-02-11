Import("Deos.DCaseCloud");
Import("Type.Json");

void main() {

	DCaseModel model = new DCaseModel("dcasedb","dcasedb");
	System.p(model.getNodeTree(11));
}

main();
