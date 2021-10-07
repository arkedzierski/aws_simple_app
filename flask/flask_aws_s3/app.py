from flask import Flask, abort, request, flash, redirect
import boto3
from flask.templating import render_template
from werkzeug.utils import secure_filename


app = Flask(__name__)
BUCKET_NAME = "akedzierski-s3"

def s3_client():
    """
        Function: get s3 client
         Purpose: get s3 client
        :returns: s3
    """
    session = boto3.session.Session()
    client = session.client('s3')
    """ :type : pyboto3.s3 """
    return client

def s3_list_files(s3_bucket_name):
    """
    Function to list files in a given S3 bucket
    """
    client = s3_client()
    contents = []
    for item in client.list_objects(Bucket=s3_bucket_name)['Contents']:
        contents.append(item)

    return contents

def s3_upload_files(inp_file_name, s3_bucket_name, content_type):
    client = s3_client()
    upload_file_response = client.put_object(Body=inp_file_name,
                                             Bucket=s3_bucket_name,
                                             ContentType=content_type)
    print(f" ** Response - {upload_file_response}")


@app.errorhandler(404)
def page_not_found(error):
    return "Aborted with 404", 404

@app.route('/')
def root():
    abort(404)

@app.route('/s3', methods=['GET', 'POST'])
def upload_files_to_s3():
    if request.method == 'POST':
 
        # No file selected
        if 'upload' not in request.files:
            flash('No file part')
            return redirect(request.url)
        upload = request.files['upload']
        content_type = request.mimetype
 
        # if empty files
        if upload.filename == '':
            flash(f' *** No files Selected', 'danger')
 
        # file uploaded and check
        if upload:
 
 
            file_name = secure_filename(upload.filename)
 
            print(f" *** The file name to upload is {file_name}")
            print(f" *** The file full path  is {upload}")
 
            
 
            s3_upload_files(upload, BUCKET_NAME, file_name,content_type )
            flash(f'Success - {upload} Is uploaded to {BUCKET_NAME}', 'success')
 
        else:
            flash(f'Something goes wrong', 'danger')
 
    return render_template('main.html', latest_files=s3_list_files(BUCKET_NAME)[:10])


