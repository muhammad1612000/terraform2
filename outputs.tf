output "public_ip"{

    value = aws_instance.apache["public_subnet"].public_ip


}

output "private_ip"{

    value = aws_instance.apache["private_subnet"].private_ip


}

