# aws_tf
upon push to main into github repo the workflow creates in an organisational sub account an aws setup using terraform:
vpc with subnet, igw, route table 
ec2 instance with basic web server


requires initial_setup to be completed (ie aws organisation with mgmt account, github account with repo, actions and secrets....)

