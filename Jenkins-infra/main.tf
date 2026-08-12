resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow Jenkins and SSH traffic"
  vpc_id      = local.vpc_id
  # Jenkins UI
  ingress {
    description = "Jenkins HTTP traffic"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # SSH
  # Restrict this to your IP/CIDR in production
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.common_tags
}
# Jenkins Master
resource "aws_instance" "jenkins_master" {
  ami           = local.ami
  instance_type = "t3.small"
  vpc_security_group_ids = [
    aws_security_group.jenkins_sg.id
  ]
  user_data = templatefile("${path.module}/jenkins-master.sh.tftpl", {
    partition_number = 4
    extend_size      = 10
  })
  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }
  tags = merge(
    local.common_tags,
    {
      Name = "Jenkins-master"
      Role = "jenkins-master"
    }
  )
}
# Jenkins Worker / Agent
resource "aws_instance" "jenkins_worker" {
  ami           = local.ami
  instance_type = "t3.small"
  vpc_security_group_ids = [
    aws_security_group.jenkins_sg.id
  ]
  user_data = templatefile("${path.module}/jenkins-worker.sh.tftpl", {
    partition_number = 4
    extend_size      = 30
  })
  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }
  tags = merge(
    local.common_tags,
    {
      Name = "Jenkins-worker"
      Role = "jenkins-worker"
    }
  )
}
