function loadFriendsToDB() {
    var ret1 = testDB->update("CREATE TABLE IF NOT EXISTS Friends (id BIGINT, name varchar(100))");
    match ret1 {
        int retInt => io:println("Friends table create status in DB: " + retInt);
        error err => io:println("Friends table create failed: " + err.message);
    }

    var ret2 = testDB->update("DELETE FROM Friends");
    match ret2 {
        int retInt => io:println("Friends table content delete status in DB: " + retInt);
        error err => io:println("Friends table content delete failed: " + err.message);
    }

    var proxyRet = testDB->getProxyTable("Friends", facebook:Data);
    table<facebook:Data> tbProxy;
    match proxyRet {
        table tbReturned => tbProxy = tbReturned;
        error err => io:println("Proxy table retrieval failed: " + err.message);
    }

    //Get Friends list details
    var friendsResponse = client->getFriendListDetails(userid);
    facebook:Data[] friendList;
    match friendsResponse {
        facebook:FriendList list => {
            facebook:Data[] ret = list.data;

            foreach rec in ret {
                var addRet = tbProxy.add(rec);
                match addRet {
                    () => io:println("Insertion to table successful");
                    error err => io:println("Insertion to table failed: " + err.message);
                }
            }
            io:print("Friends count: " + list.summary.totalCount);
        }
        facebook:FacebookError e => io:println(e.message);
    }
}
