resource "aws_instance" "sample" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3a.medium"
  key_name      = aws_key_pair.ssh.key_name

  subnet_id              = aws_subnet.sample.id
  vpc_security_group_ids = [aws_security_group.allow_all_https.id]

  tags = {
    Name = "${var.aws_prefix}-ec2"
  }

  user_data = templatefile(
    "${path.module}/ec2_init.template.sh",
    {
      username = local.ec2_username
    }
  )

  root_block_device {
    volume_size = 30 # GB
    volume_type = "gp3"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "cloud-init status --wait > /dev/null",
      "echo 'Completed cloud-init!'",
    ]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = local.ec2_username
      private_key = tls_private_key.global_key.private_key_pem
    }
  }

  depends_on = [ aws_internet_gateway.sample ]
}
