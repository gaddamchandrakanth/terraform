variable "multiple" {
  default = [
    {name="one",ami="ami-0945610b37068d87a",type="t2.micro" },
    {name="two",ami="ami-00271c85bf8a52b84",type="t2.micro" },
    {name="three",ami="ami-0f7153f6999a5ef60",type="t2.micro"}
  ]
}

locals {
  servers_map={for inst in var.multiple:inst.name=>inst}
}
resource "aws_instance" "multi" {
  for_each = local.servers_map
  ami = each.value.ami
  instance_type = each.value.type
  tags = {
    Name=each.key
  }
}

