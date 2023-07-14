output "ssh_command" {
  value = "ssh -i ${local_sensitive_file.ssh_private_key_pem.filename} ${local.ec2_username}@${aws_instance.sample.public_ip}"
}
