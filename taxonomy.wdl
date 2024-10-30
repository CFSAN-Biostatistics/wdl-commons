# FDA-HFP DSDI taxonomy WDL Library
# Author: You <you@youremail.com>
# 
version 1.2
# 
task hello {
command {
echo "Hello, world!"
}
output {
String salutation = read_string(stdout())
}
runtime {
docker: "ubuntu:latest"
}
}
