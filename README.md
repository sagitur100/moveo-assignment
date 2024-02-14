Instructions:
    - clone git repository
		git clone https://github.com/sagitur100/moveo-assignment.git
		cd moveo-assignment 
	- create least permissions policy to tf user by iamlive open-source tool.
    - Create user-group, assign the user to the group and assign the policy mentioned above.
    - Generate access key and mention the key ID and the secret in the variables.tf file
    - Create variables.tf file according to the documentation and put values as you need.
    - Initialize terraform.
		terraform init
    - terraform plan
    - terraform apply
    - terraform output will return the LB DNS name.
    - Access this DNS name.