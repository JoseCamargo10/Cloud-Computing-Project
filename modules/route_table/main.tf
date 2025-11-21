resource "aws_route_table" "this" {
    vpc_id = aws_vpc.test.id

    dynamic "route" {
        for_each = var.routes

        content {
            cidr_block = route.value.cidr_block
            # Si route.value.nat_gateway_id es null (porque no se pasó), 
            # Terraform simplemente omite este atributo en la API.
            nat_gateway_id = route.value.nat_gateway_id
            # Si route.value.gateway_id es null, también se omite.
            # Solo se envía a AWS el atributo que NO sea nulo.
            gateway_id     = route.value.gateway_id
        }
    }
}

resource "aws_route_table_association" "this" {
    subnet_id      = var.subnet_id
    route_table_id = aws_route_table.this.id
}