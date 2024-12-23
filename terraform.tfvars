cidr_block         = "10.20.0.0/16"
vpc_name           = "dev"
cidr_block_subnets = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
azs                = ["us-east-1a", "us-east-1b", "us-east-1c"]
instance_type = "t2.micro"
key_name = "Giridhar"
ami = "ami-0ca9fb66e076a6e32"
private_ip = ["10.20.1.5","10.20.2.5","10.20.3.5"]