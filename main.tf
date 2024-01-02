provider "aws" {
  region = "us-west-2"
}

resource "aws_lambda_function" "students" {
  filename      = "students.zip"
  function_name = "students"
  role          = aws_iam_role.students.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  timeout       = 10
}

resource "aws_iam_role" "students" {
  name = "students"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "students" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.students.name
}

resource "aws_apigatewayv2_api" "students" {
  name          = "students"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "students" {
  api_id = aws_apigatewayv2_api.students.id
  integration_type = "AWS_PROXY"
  integration_uri = aws_lambda_function.students.invoke_arn
}

resource "aws_apigatewayv2_route" "students" {
  api_id = aws_apigatewayv2_api.students.id
  route_key = "ANY /{proxy+}"
  target = "integrations/${aws_apigatewayv2_integration.students.id}"
}

resource "aws_apigatewayv2_stage" "students" {
  api_id = aws_apigatewayv2_api.students.id
  name = "prod"
  auto_deploy = true
}