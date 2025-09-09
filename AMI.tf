  Q/A : HOW WILL YOU GET THE LATEST AMI AND IMPLEMENT?
             AS WE USE THE DATASOURCE PROCESS GET THE LATEST AMI using the FILTERS[filters & values & owner &name]
                    I always get the newest AMI matching my criteria, which avoids hardcoding IDs and helps maintain consistency and security

------------------------------------------------------------------

# Ubuntu
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-20.04-amd64-server-*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

--------------------------------------------------------------------------------------------------------------------------------

# Amazon Linux
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

------------------------------------------------------------------------------------------------------------------------------------------
# Red Hat (RHEL)
data "aws_ami" "rhel" {
  most_recent = true
  owners      = ["309956199498"]
  filter {
    name   = "name"
    values = ["RHEL-9.*_HVM-*x86_64-*"]
  }
}

----------------------------------------------------------------------------------------------------------------------------------------------
# Windows Server
data "aws_ami" "windows" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2022-*-English-Full-*"]
  }
  filter {
    name   = "platform"
    values = ["windows"]
  }
}

---------------------------------------------------------------------------------------------------------------------------------------------------
# SUSE (BYOS example)
data "aws_ami" "suse" {
  most_recent = true
  owners      = ["013907871322"]
  filter {
    name   = "name"
    values = ["suse-sles-*-hvm-ssd-x86_64"]
  }
}


----------------------------------------------------------------------------------------------------------------------------------------------------
# Debian
data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"]
  filter {
    name   = "name"
    values = ["debian-*-*-*-amd64-*"]
  }
}

---------------------------------------------------------------------------------------------------------------------------------------------------------
#IF NEEDED CAN USE 
optional
locals {
  selected_ami = {
    ubuntu       = data.aws_ami.ubuntu.id
    amazon       = data.aws_ami.amazon_linux.id
    rhel         = data.aws_ami.rhel.id
    windows      = data.aws_ami.windows.id
    suse         = data.aws_ami.suse.id
    debian       = data.aws_ami.debian.id
  }[var.os_type]
}









