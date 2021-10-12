from types import SimpleNamespace
from flask import Flask, abort, request, flash, redirect
from flask.templating import render_template
from werkzeug.utils import secure_filename

import botocore
import boto3
import requests
import string
import random


app = Flask(__name__)
BUCKET_NAME = "akedzierski-s3"

def get_rds_record_number():
    response = requests.get('http://akedzierski-lb-app-145495019.us-east-2.elb.amazonaws.com/num').json()
    return response['Total']

def s3_client():
    """
        Function: get s3 client
         Purpose: get s3 client
        :returns: s3
    """
    sts_client = boto3.client('sts')
    assumed_role_object = sts_client.assume_role( RoleArn='arn:aws:iam::890769921003:role/akedzierski-iam_r-access-snet-prv-to-s3', RoleSessionName="AssumeRoleSession1" )
    credentials = assumed_role_object['Credentials']

    session = boto3.session.Session()
    client = session.client('s3', aws_access_key_id=credentials['AccessKeyId'], aws_secret_access_key=credentials['SecretAccessKey'], aws_session_token=credentials['SessionToken'])
    """ :type : pyboto3.s3 """
    return client

def s3_create_presigned_url(bucket_name, object_name, expiration=3600):
    """Generate a presigned URL to share an S3 object

    :param bucket_name: string
    :param object_name: string
    :param expiration: Time in seconds for the presigned URL to remain valid
    :return: Presigned URL as string. If error, returns None.
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
    """Generate a presigned URL S3 POST request to upload a file

    :param bucket_name: string
    :param object_name: string
    :param fields: Dictionary of prefilled form fields
    :param conditions: List of conditions to include in the policy
    :param expiration: Time in seconds for the presigned URL to remain valid
    :return: Dictionary with the following keys:
        url: URL to post to
        fields: Dictionary of form fields and values to submit with the POST
    :return: None if error.
    """

    # Generate a presigned S3 POST URL
    client = s3_client()
    try:
        response = client.generate_presigned_post(bucket_name,
                                                     object_name,
                                                     Fields=fields,
                                                     Conditions=conditions,
                                                     ExpiresIn=expiration)
    except ClientError as e:
        logging.error(e)
        return None

    # The response contains the presigned URL and required fields
    return response

def s3_list_files(s3_bucket_name):
    """
    Function to list files in a given S3 bucket
    """
    client = s3_client()
    contents = []
    for item in client.list_objects(Bucket=s3_bucket_name)['Contents']:
        contents.append(item)

    return contents

def s3_upload_files(file_data, s3_bucket_name, content_type, filename):
    client = s3_client()
    upload_file_response = client.put_object(Body=file_data,
                                             Bucket=s3_bucket_name,
                                             ContentType=content_type,
                                             Key=filename)
    print(f" ** Response - {upload_file_response}")


@app.errorhandler(404)
def page_not_found(error):
    return "Aborted with 404", 404

@app.route('/')
def root():
    abort(404)

@app.route('/s3', methods=['GET', 'POST'])
def upload_files_to_s3():
    # if request.method == 'POST':
 
    #     # No file selected
    #     if 'upload' not in request.files:
    #         flash('No file part')
    #         return redirect(request.url)
    #     upload = request.files['upload']
    #     content_type = request.mimetype
 
    #     # if empty files
    #     if upload.filename == '':
    #         flash(f' *** No files Selected', 'danger')
 
    #     # file uploaded and check
    #     if upload:
 
 
    #         file_name = secure_filename(upload.filename)
 
    #         print(f" *** The file name to upload is {file_name}")
    #         print(f" *** The file full path  is {upload}")
 
            
 
    #         s3_upload_files(upload, BUCKET_NAME, content_type, file_name )
 
    #     else:
    #         flash(f'Something goes wrong', 'danger')
    s3files = s3_list_files(BUCKET_NAME)[:10]
    latest_files = []
    for file in s3files:
        latest_files.append({'Name': file['Key'], 'url': s3_create_presigned_url(BUCKET_NAME, file['Key'])})
    key = ''.join(random.choice(string.ascii_lowercase) for i in range(8))
    upload_data = s3_create_presigned_post(BUCKET_NAME, key, conditions=[["starts-with", "$key", key]])
    return render_template('main.html', latest_files=latest_files, rows=get_rds_record_number(), data=upload_data)


