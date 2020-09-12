#include <sourcemod>
#include <sqlchain>

#define PROFILER
#if defined PROFILER
#include <profiler>
#endif

#pragma semicolon 1
#pragma newdecls required

Database Connect() {
	char error[255];
	Database db = SQL_DefConnect(error, sizeof(error));
	
	if (db == null) {
		LogError("Could not connect to database: %s", error);
	}
	
	return db;
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_test1", TEST1);
}

public Action TEST1(int client, int args)
{
#if defined PROFILER
	Handle p = CreateProfiler();
	StartProfiling(p);
#endif
	// Example with result
	SQLChain chain = new SQLChain();
	DBResultSet res = chain.Select("*")
		.From("%s", "bandatabase")
		.Where("clientid = %d", args).RQuery(db);

	char str[255];
	if(res.FetchRow()) {
		res.FetchString(0, str, sizeof(str));
	}
	
	PrintToServer("Result: %s", str);
	
	
	// Example wihtout result
	chain.Clear();
	char id[22] = "STEAM_0:0:62618404";
	char name[22] = "Scag";
	char ip[22] = "0.0.0.0";
	int time = 10080;

	chain.Insert()
		.Into("%s (steamid, name, ip_address, ban_time)", "bandatabase")
		.Values("(%s, %s, %s, %d)", id, name, ip, time).FQuery(db);

#if defined PROFILER
	StopProfiling(p);
	PrintToServer("%0.10f", GetProfilerTime(p));
	delete p;
#endif
	delete chain;
	return Plugin_Handled;
}
