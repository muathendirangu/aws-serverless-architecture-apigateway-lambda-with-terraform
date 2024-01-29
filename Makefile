build:
	GOOS=linux GOARCH=amd64 go build -o build/bin/app .

init:
	terraform init

plan:
	terraform plan

apply:
	terraform apply --auto-approve

destroy:
	terraform destroy --auto-approve
