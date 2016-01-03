
var replStatus = rs.status();

if(replStatus && replStatus.ok === 1){
	print(" ### Replication OK");
	printjson(replStatus);
} else {
	print(" ### Starting replication...");
	printjson(rs.initiate(rs_cluster));
	sleep(5000);
	print(" ");
	print(" ### Replica Set status");
	printjson(rs.status());
}

var sleep = function (milliseconds) {
  var start = new Date().getTime();
  for (var i = 0; i < 1e7; i++) {
    if ((new Date().getTime() - start) > milliseconds){
      break;
    }
  }
};