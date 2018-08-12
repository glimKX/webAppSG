// Load saved down users and password
system "l ", getenv `USERS_HDB;

// Bring it into memory and key the users like .pm.users
.perm.users: 1!@[select from users; exec c from meta[users] where t="s"; value];
.perm.Apermissions: 1!@[select from Apermissions; exec c from meta[Apermissions] where t="s"; value];

// Delete the users from the namespace
delete users, Apermissions from `.;

// The standard permissioning functions
.perm.toString: {[x] $[10h = abs type x; x; string x]};
.perm.encrypt: {[u;p] md5 raze .perm.toString p,u};

// Modification to the .perm.add to add to the QHDB on disk
.perm.add: {[u;c;p]	if[u in key[.perm.users]; -1 "### User (", string[u], ") already exists. ###"; :()]; 
			list: (u; c; .perm.encrypt[u;p]); 
			`.perm.users upsert list;
			(hsym `$ getenv[`USERS_HDB], "users/") upsert .Q.en[`:.] enlist cols[.perm.users]!list;};

// Introduce the various classes when using .perm.add
/ Two layers: 1) user; 2) superuser
.perm.addUser: {[u;p] .perm.add[u;`user;p]};
.perm.addSuperuser: {[u;p] .perm.add[u;`superuser;p]};

// Additional functions to get class and check if they are of the appropriate class
.perm.getClass: {[u] .perm.users[u; `class]};
.perm.isSU: {[u] `superuser ~ .perm.getClass[u]};

// Modify the .z.pw for the IPC access restrictions
.z.pw: {[user;pwd] $[.perm.encrypt[user;pwd] ~ .perm.users[user;`password]; 1b; 0b]};

// Copy from https://code.kx.com/q/wp/permissions_with_kdb.pdf
/ Check that .z.pg is not being used by other processes, else it would be overwritten
/ When we need to introduce additional users, we need to modify the if-else condition in the .z.pg below
/ Not sure if we have to do the same for async queries, but doubt thats needed since q doesnt return "an argument" back if its asynchronous, and we wont have any async callback functions
/ What is passed into .z.pg is actually string format
.z.pg: {[query] user: .z.u;
		class: .perm.getClass[user];
		$[class ~ `superuser; value query; .perm.pg.user[user;query]]};

// Need to introduce the additional set of permissioning functions as shown in the whitepaper
.perm.parse: {[x] if[-10h = type x; x: enlist x]; $[10h = type x; parse x; x]}; 

// .perm.parse query would let us obtain the function name to be called at the server point
/ Get the analytic being called
/ Need to check if its a symbol or not, else it might trigger an error, given that they do not know what analytics are used to change the process, we will be safe to assume
/ That if its not in symbol format, they are safe to run their query and exit .perm.pg.users
.perm.pg.user: {[user;query]	analyticN: first .perm.parse query;
				$[-11h <> type analyticN; 
						value query; 
					not user in .perm.Apermissions[analyticN; `user]; 
						'string[user], " has no permissions to run ", .perm.toString[analyticN], ".";
					value query]};

// These are the analytics for one to process the addition of analytic permissions
/ It has to be in string format
.perm.ApermAdd: {[analytic;user]	.[`.perm.Apermissions; (analytic; `user); union; user];
					check: (hsym `$ getenv[`USERS_HDB], "Apermissions/") set .Q.en[`:.] 0!.perm.Apermissions;
					if[11h = abs type check; neg[.z.w] (show;  "### ", string[analytic], " added successfully. ###")]};

.perm.ApermRemove: {[analytic;user] 	.[`.perm.Apermissions; (analytic; `user); except; user];
					check: (hsym `$ getenv[`USERS_HDB], "Apermissions/") set .Q.en[`:.] 0!.perm.Apermissions;
					if[11h = abs type check; neg[.z.w] (show; "### ", string[analytic], " removed successfully. ###")]};

