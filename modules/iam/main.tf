# Rol IAM para EC2
resource "aws_iam_role" "ec2_role" {
    name = "ec2-role-acpprr"

    assume_role_policy = jsonencode({
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    })
}

# Instance Profile para asociar este rol a EC2
resource "aws_iam_instance_profile" "ec2_instance_profile" {
    name = "ec2-instance-profile-acpprr"
    role = aws_iam_role.ec2_role.name
}

# Política AmazonSSMManagedInstanceCore
resource "aws_iam_role_policy_attachment" "ssm_core" {
    role = aws_iam_role.ec2_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Política AmazonS3ReadOnlyAccess
resource "aws_iam_role_policy_attachment" "s3_readonly" {
    role = aws_iam_role.ec2_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}