resource "aws_vpc" "vpc-1" {
    cidr_block = var.cidr
    tags = {name= var.tags
    }

  
}