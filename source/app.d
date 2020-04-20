/+ dub.sdl:
	name "test"
	description "Tests vibe.d's std.concurrency integration"
	dependency "vibe-core" path="../"
+/
module test;

import vibe.core.core;
import vibe.core.log;
import vibe.http.router;
import vibe.http.server;
import vibe.web.rest;

import std.concurrency;
import core.atomic;
import core.time;


import vibe.core.core;
import vibe.core.log;
import vibe.http.router;
import vibe.http.server;
import vibe.web.rest;

interface API1
{
	int getValue1();
}

interface API2 : API1
{
    int getValue2();
}

class Node1 : API1
{
	public int getValue1()
	{
		return 1;
	}
}

class Node2 : Node1, API2
{
	public int getValue2()
	{
		return 2;
	}
}


void main()
{
	auto router2 = new URLRouter;
	router2.registerRestInterface(new Node2);
	auto settings2 = new HTTPServerSettings;
	settings2.port = 8002;
	settings2.bindAddresses = ["::1", "127.0.0.1"];
	listenHTTP(settings2, router2);

	runTask({
		auto client2 = new RestInterfaceClient!API2("http://127.0.0.1:8002/");
		logInfo("value1: %s", client2.getValue1());
		logInfo("value2: %s", client2.getValue2());
	});

	runApplication();
}
