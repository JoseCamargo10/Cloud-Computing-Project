resource "aws_internet_gateway" "this" {
    vpc_id = var.vpc_id
    tags = {
    Name = var.name
    }
}

resource "aws_internet_gateway_attachment" "this" {
    internet_gateway_id = aws_internet_gateway.this.id
    vpc_id              = var.vpc_id
}