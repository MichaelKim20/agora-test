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

interface FullNodeAPI
{
	int getValue1();
}

interface ValidatorAPI : FullNodeAPI
{
    int getValue2();
}

class FullNode : FullNodeAPI
{
	public int getValue1()
	{
		return 1;
	}
}

class ValidatorNode : FullNode, ValidatorAPI
{
	public int getValue2()
	{
		return 2;
	}
}


void main()
{
	auto router2 = new URLRouter;
	router2.registerRestInterface(new ValidatorNode);
	auto settings2 = new HTTPServerSettings;
	settings2.port = 8002;
	settings2.bindAddresses = ["::1", "127.0.0.1"];
	listenHTTP(settings2, router2);

	runTask({
		auto client2 = new RestInterfaceClient!ValidatorAPI("http://127.0.0.1:8002/");
		logInfo("value1: %s", client2.getValue1());
		logInfo("value2: %s", client2.getValue2());
	});

	runApplication();
}
