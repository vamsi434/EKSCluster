/*****************************************************************
   Key Pair for connecting to all EC2s (including Bastion Host)
******************************************************************/

resource "tls_private_key" "algorithm" {
  algorithm             = "RSA"
  rsa_bits              = 4096
}

resource "aws_key_pair" "admin_ssh_key" {
  key_name              = local.ssh_key_name
  public_key            = tls_private_key.algorithm.public_key_openssh
}

resource "local_file" "admin_public_key" {
  filename              = "./keys/${aws_key_pair.admin_ssh_key.key_name}.pem"
  content               = tls_private_key.algorithm.private_key_pem
}
