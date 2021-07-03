window_set_size(1920, 1080);
window_set_fullscreen(true);
global.client = instance_create_depth(0, 0, 0, oClient);
global.client.persistent = true;
global.packet_handler = instance_create_depth(0, 0, 0, oPacketHandler);
global.packet_handler.persistent = true;
