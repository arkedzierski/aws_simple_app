from flask import Flask, abort, request
from flask.templating import render_template

import botocore
import boto3
import requests
import os

LB_ENDPOINT = os.environ.get('LB_ENDPOINT')
BUCKET_NAME = os.environ.get('BUCKET_NAME')


app = Flask(__name__)


def get_rds_record_number():
    """
    Get json with total number of rows from flask_aws_rds app.

    Arguments:
        None
    
    Keyword Arguments:
        None

    Return {int} value of keyword Total 
    
    """
    response = requests.get(f'http://{LB_ENDPOINT}/num').json()
    return response['Total']

def s3_client():
    """
    Create boto3 S3 client

    Arguments:
        None
    
    Keyword Arguments:
        None

    Return object {Client}
    """
    session = boto3.session.Session()
    client = session.client('s3')
    return client

def s3_create_presigned_url(bucket_name, object_name, expiration=3600):
    """
    Generate a presigned URL to share an S3 object

    Arguemnts:
        bucket_name -- {string} S3 bucket name
        object_name -- {string} name of object from S3 bucket

    Keyword Arguments:
        expiration -- {int} Time in seconds for the presigned URL to remain valid
    
    Return {str} Presigned URL as string. If error, returns {None}.
    """

    # Generate a presigned URL for the S3 object
    client = s3_client()
    try:
        response = client.generate_presigned_url('get_object',
                                                    Params={'Bucket': bucket_name,
                                                            'Key': object_name},
                                                    ExpiresIn=expiration)
        return response
    except botocore.exceptions.ClientError as e:
        print(e)
        return None

def s3_create_presigned_post(bucket_name, object_name,
                          fields=None, conditions=None, expiration=3600):
    """
    Generate a presigned URL S3 POST request to upload a file

    Arguemnts:
        bucket_name -- {string} S3 bucket name
        object_name -- {string} name of object from S3 bucket
    
    Keyword Arguments:
        fields -- {dict} Dictionary of prefilled form fields
        conditions -- {list} List of conditions to include in the policy
        expiration -- {int} Time in seconds for the presigned URL to remain valid

    Return {dict} Dictionary with the following keys:
        url: URL to post to
        fields: Dictionary of form fields and values to submit with the POST
        None if error.
    """

    # Generate a presigned S3 POST URL
    client = s3_client()
    try:
        response = client.generate_presigned_post(bucket_name,
                                                     object_name,
                                                     Fields=fields,
                                                     Conditions=conditions,
                                                     ExpiresIn=expiration)
    except botocore.exceptions.ClientError as e:
        print(e)
        return None

    # The response contains the presigned URL and required fields
    return response

def s3_list_files(s3_bucket_name):
    """
    Function to list files in a given S3 bucket

    Arguemnts:
        bucket_name -- {string} S3 bucket name

    Keyword Arguments:
        None
    
    Return {list} List of dictionaries including names and presigned URL of files in the bucket.
    """
    client = s3_client()
    contents = []
    try:
        for item in client.list_objects(Bucket=s3_bucket_name)['Contents']:
            contents.append(item)
    except KeyError as e:
        contents = []
    return contents

# Default 404 if page doesn't exists
@app.errorhandler(404)
def page_not_found(error):
    return "Aborted with 404", 404

# If / return 404
@app.route('/')
def root():
    abort(404)

# Show form to upload, last 10 files and number of rows in flask_aws_rds app
@app.route('/s3', methods=['GET'])
def upload_files_to_s3():
    s3files = s3_list_files(BUCKET_NAME)[:10]
    latest_files = []
    for file in s3files:
        latest_files.append({'Name': file['Key'], 'url': s3_create_presigned_url(BUCKET_NAME, file['Key'])})
    upload_data = s3_create_presigned_post(BUCKET_NAME, '${filename}')
    return render_template('main.html', latest_files=latest_files, rows=get_rds_record_number(), data=upload_data)

# Health check for Target Group
@app.route('/hc')
def healt_check():
    return "OK", 200

# Run app on all i/f and port 5000
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)