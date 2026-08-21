terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "6.48.0"
        }
    } 
    backend "s3" {
        bucket = "s3-for-ingress-gatway"
        key= "sg.tfstate"
        region = "us-east-1"
        encrypt =true
        use_lockfile = true
    }   
}

provider "aws" {
    region = "us-east-1"
}