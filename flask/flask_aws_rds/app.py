from flask import Flask, render_template, abort, jsonify, request
from flask.wrappers import Response
from flask_sqlalchemy import SQLAlchemy

import urllib
import datetime
import boto3

app = Flask(__name__)
RDS_ENDPOINT = 'akedzierski-db.c6nhgfuujgle.us-east-2.rds.amazonaws.com'
RDS_USR = 'ken'
RDS_DBNAME = 'ec2'
client = boto3.client('rds')
token = client.generate_db_auth_token(
    DBHostname=RDS_ENDPOINT,
    Port=5432,
    DBUsername=RDS_USR
)
passwd = urllib.parse.quote(token)
app.config['SQLALCHEMY_DATABASE_URI'] = f'postgresql://{RDS_USR}:{passwd}@{RDS_ENDPOINT}/{RDS_DBNAME}?sslmode=require'

# app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:postgres@localhost/ec'
# app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db = SQLAlchemy(app)

class Rds_images(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(200))
    pub_date = db.Column(db.Time, default=datetime.datetime.now())

@app.errorhandler(404)
def page_not_found(error):
    return "Aborted with 404", 404

@app.route('/')
def root():
    abort(404)

@app.route('/db')
def index():
    images = db.session.execute('SELECT * FROM rds_images LIMIT 10;')
    try:
        images = [row[1] for row in images]
    except Exception as e:
        print(e)
        images = False
    return render_template('index.html', latest_images=images)

@app.route("/add", methods=['GET'])
def add():
    return render_template("images_form.html")

@app.route("/add", methods=['POST'])
def imageadd():
    pname = request.form["name"]
    entry = Rds_images(name=pname)
    db.session.add(entry)
    db.session.commit()
    return render_template("index.html")

@app.route('/num')
def db_entry_number():
    images_num = db.session.execute('SELECT COUNT(*) FROM rds_images;').first().count
    return jsonify({'Total': images_num})

