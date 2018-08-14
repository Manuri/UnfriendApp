import ballerina/config;
import biruntha13/facebook;
import ballerina/io;
import ballerina/mysql;

public string userAccessToken = config:getAsString("USER_ACCESS_TOKEN");

public string userid = config:getAsString("USER_ID");

endpoint facebook:Client client {
    clientConfig: {
        auth: {
            accessToken: userAccessToken
        }
    }
};

endpoint mysql:Client testDB {
    host: config:getAsString("DB_HOST"),
    port: config:getAsInt("DB_PORT"),
    name: config:getAsString("DB_NAME"),
    username: config:getAsString("DB_USERNAME"),
    password: config:getAsString("DB_PASSWORD"),
    poolOptions: { maximumPoolSize: 5 },
    dbOptions: { useSSL: false }
};

function main(string... args) {
    facebook:Data[] unfriendedList = getUnfriendedList();

    foreach rec in unfriendedList {
        io:println(rec.id + ": " + rec.name);
    }
}

function getUnfriendedList() returns facebook:Data[] {
    var proxyRet = testDB->getProxyTable("Friends", facebook:Data);
    table<facebook:Data> tbProxy;
    match proxyRet {
        table tbReturned => tbProxy = tbReturned;
        error err => io:println("Proxy table retrieval failed: " + err.message);
    }

    var friendsResponse = client->getFriendListDetails(userid);
    facebook:Data[] friendList;
    facebook:Data[] unfriendedList;
    match friendsResponse {
        facebook:FriendList list => {
            facebook:Data[] ret = list.data;
            int i = 0;
            foreach rec in tbProxy {
                boolean unfriended = true;
                foreach entry in ret {
                    if (rec.id == entry.id) {
                        unfriended = false;
                        break;
                    }
                }
                if (unfriended) {
                    unfriendedList[i] = rec;
                    i++;
                }
                unfriended = true;
            }
        }
        facebook:FacebookError e => io:println(e.message);
    }

    return unfriendedList;
}