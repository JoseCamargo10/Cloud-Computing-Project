# Rol IAM genérico
resource "aws_iam_role" "this" {
    name               = var.role_name
    # Se toma el JSON de la política de asunción directamente de la variable
    assume_role_policy = var.assume_role_policy_json 

    tags = {
        Name = var.role_name
    }
}

# Instance Profile (Condicional: solo se crea si instance_profile_name tiene un valor)
resource "aws_iam_instance_profile" "this" {
# count es 1 si el nombre existe (longitud > 0), 0 si está vacío.
    
    name = var.instance_profile_name
    role = aws_iam_role.this.name
}

# Adjuntar políticas (usa for_each para la lista de ARNs)
resource "aws_iam_role_policy_attachment" "this" {
    for_each = toset(var.attached_policies)

    role       = aws_iam_role.this.name
    policy_arn = each.value
}