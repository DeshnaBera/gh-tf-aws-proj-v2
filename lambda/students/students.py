import json
import boto3

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('students')

    if event['httpMethod'] == 'POST':
        student = json.loads(event['body'])
        table.put_item(Item=student)        
        return {
            'statusCode': 200,
            'body': json.dumps('Student added successfully')
        }    elif event['httpMethod'] == 'GET':
        response = table.scan()        return {
            'statusCode': 200,
            'body': json.dumps(response['Items'])
        }
    else:
        return {
            'statusCode': 405,
            'body': json.dumps('Invalid HTTP method')
        }