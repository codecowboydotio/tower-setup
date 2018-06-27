# create projects
tower-cli project create --name codecowboy --scm-type git --scm-url http://github.com/codecowboydotio/ansible --organization Default
tower-cli project create --name devopsday --scm-type git --scm-url http://github.com/codecowboydotio/devops-day --organization Default

# Create credentials
#tower-cli credential create --name root-ssh --organization Default --credential-type Machine --inputs \{"username":"root"\}
tower-cli credential create --name root-ssh --organization Default --credential-type Machine 
tower-cli credential create --name aws-ssh --organization Default --credential-type Machine 
tower-cli credential create --name "aws-account" --organization Default --credential-type "Amazon Web Services" --inputs='{"username":"aaa","password":"AAA"}'
tower-cli credential create --name "etg-aws" --organization Default --credential-type "Amazon Web Services" --inputs='{"username":"aaa","password":"AAA"}'

# create inventories
tower-cli inventory create --name linux-boxes --organization Default
tower-cli host create --name fedora --inventory linux-boxes
tower-cli inventory create --name AWS --organization Default
tower-cli inventory_source create --name "aws-source" --inventory "AWS" --source ec2 --credential "aws-account" --update-on-launch "true" --overwrite "true"
tower-cli inventory create --name localhost --organization Default
tower-cli host create --name localhost --inventory localhost

# create job templates
tower-cli job_template create --name figlet-1 --job-type run --inventory linux-boxes --project devopsday --playbook figlet-1.yml --credential root-ssh --extra-vars target_hosts=all
tower-cli job_template create --name figlet-2 --job-type run --inventory linux-boxes --project devopsday --playbook figlet-2.yml --credential root-ssh --extra-vars target_hosts=all
tower-cli job_template create --name figlet-3 --job-type run --inventory linux-boxes --project devopsday --playbook figlet-3.yml --credential root-ssh --extra-vars "target_hosts=all pkg_name=figlet"
tower-cli job_template create --name figlet-4 --job-type run --inventory linux-boxes --project devopsday --playbook figlet-4.yml --credential root-ssh --extra-vars "target_hosts=all pkg_name=figlet pkg_state=present"
tower-cli job_template create --name Deploy-helloworld --job-type run --inventory AWS --project codecowboy --playbook deploy_helloworld.yml --credential aws-ssh --extra-vars "target_hosts=all" --use-fact-cache True

tower-cli job_template create --name "AWS-instance" --job-type run --inventory localhost --project codecowboy --playbook test-ec2.yml --credential root-ssh --ask-variables-on-launch "true" --extra-vars "instance_count=1"
tower-cli job_template create --name "etg-AWS-instance" --job-type run --inventory localhost --project codecowboy --playbook test-ec2.yml --credential root-ssh --ask-variables-on-launch "true" --extra-vars "instance_count=1"
tower-cli job_template associate_credential --job-template "etg-AWS-instance" --credential etg-aws
tower-cli job_template create --name "Terminate EC2" --job-type run --inventory AWS --project codecowboy --playbook terminate-ec2.yml --credential root-ssh --extra-vars "target_hosts: all"

tower-cli job_template create --name AWS-figlet --job-type run --inventory AWS --project devopsday --playbook figlet-1.yml --credential aws-ssh --extra-vars target_hosts=all

tower-cli job_template create --name Install-python --job-type run --inventory AWS --project codecowboy --playbook python.yml --credential aws-ssh --extra-vars target_hosts=all
tower-cli job_template create --name Tomcat-install --job-type run --inventory AWS --project codecowboy --playbook tomcat.yml --credential aws-ssh --extra-vars target_hosts=all --use-fact-cache True

# create a workflow
tower-cli workflow create --name "figlet_workflow"
tower-cli workflow schema figlet_workflow @schema.yml

# delete default stuff
tower-cli job_template delete --name "Demo Job Template"
tower-cli project delete --name "Demo Project"
tower-cli credential delete --name "Demo Credential"
tower-cli inventory delete --name "Demo Inventory"
