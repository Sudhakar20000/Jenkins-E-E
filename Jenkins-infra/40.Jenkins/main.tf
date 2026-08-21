
# Jenkins Master
resource "aws_instance" "jenkins_master" {
  ami           = local.ami
  instance_type = "t3.small"
  subnet_id = local.public_subnet_id
  vpc_security_group_ids = [ 
    local.jenkins_sg_id
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
  subnet_id = local.public_subnet_id
  vpc_security_group_ids = [
    local.jenkins_agent_sg_id
  ]
  iam_instance_profile = aws_iam_instance_profile.jenkins_agent.name
  user_data = templatefile("${path.module}/jenkins-worker.sh.tftpl", {
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
      Name = "Jenkins-worker"
      Role = "jenkins-worker"
    }
  )
}
