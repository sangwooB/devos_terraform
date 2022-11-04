variable "region" {
  description = "region"
  default = "ap-northeast-3"
}

variable "ec2_name" {
  description = "ec2 instance tag Name"
  default = "default-ec2-name"
}

variable "subnet_id" {
  description = "subnet identity"
  default = "subnet-1234abcd"
}

variable "security_groups" {
  description = "security group ids"
  type = list(string)
  default = ["sg-1235abcd"]
}

variable "key_pair" {
  description = "pem key pair name"
  default = "ec2-pemkey"
}

variable "instance_type" {
  description = "ec2 instance type"
  default = "t2.micro"
}

variable "assign_ip" {
  description = "use assign ip"
  type = bool
  default = true
}
