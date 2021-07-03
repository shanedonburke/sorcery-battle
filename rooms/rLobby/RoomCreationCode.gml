if (global.network_type == "SERVER") {
	global.server = instance_create_depth(0, 0, 0, oServer);
	global.server.persistent = true;
}