// Load saved down users and password
system "l ",getenv `USERS_HDB;

// Bring it into memory and key the users like .pm.users
.perm.users: 1!@[select from users; exec c from meta[users] where t = "s"; value];

// Delete the users from the namespace
delete users from `.;

// The standard permissioning functions
.perm.toString: {[x] $[10h=abs type x; x; string x]};
.perm.encrypt: {[u;p] md5 raze .perm.toString p,u};

// Modification to the .perm.add to add to the QHDB on disk
.perm.add: {[u;p]	if[u in key[.perm.users]; -1 "### User (", string[u], ") already exists. ###"; :()]; 
			list: (u; .perm.encrypt[u;p]); 
			`.perm.users upsert list;
			(hsym `$getenv[`USERS_HDB],"users/") upsert .Q.en[`:.] enlist cols[.perm.users]!list;};

// Modify the .z.pw for the IPC access restrictions
.z.pw: {[user;pwd] $[.perm.encrypt[user;pwd] ~ .perm.users[user;`password]; 1b; 0b]};
