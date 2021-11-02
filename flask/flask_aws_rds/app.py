from flask import Flask, render_template, abort, jsonify, request, url_for, redirect
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate

import urllib
import datetime
import boto3
import os

import sqlalchemy

RDS_ENDPOINT = os.environ.get('RDS_ENDPOINT')
RDS_USR = os.environ.get('RDS_USER')
RDS_DBNAME = os.environ.get('RDS_DBNAME')

app = Flask(__name__)

#Boto RDS client
client = boto3.client('rds')
token = client.generate_db_auth_token(
    DBHostname=RDS_ENDPOINT,
    Port=5432,
    DBUsername=RDS_USR
)

# Connection string for SQLAlchemy
passwd = urllib.parse.quote(token)
app.config['SQLALCHEMY_DATABASE_URI'] = f'postgresql://{RDS_USR}:{passwd}@{RDS_ENDPOINT}/{RDS_DBNAME}?sslmode=require'

# app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:postgres@localhost/ec'
# app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

#SQLAlchemy db model
db = SQLAlchemy(app)
migrate = Migrate(app, db)

class Rds_images(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(200))
    pub_date = db.Column(db.Time, default=datetime.datetime.now())

# Default 404 if page doesn't exists
@app.errorhandler(404)
def page_not_found(error):
    return "Aborted with 404", 404

# If / return 404
@app.route('/')
def root():
    abort(404)

# Show db rows
@app.route('/db')
def index():
    try:
        images = db.session.execute('SELECT * FROM rds_images LIMIT 10;')
    except sqlalchemy.exc.ProgrammingError as e:
        print(e)
        db.create_all()
        images = False
    try:
        images = [row[1] for row in images]
    except Exception as e:
        print(e)
        images = False
    return render_template('index.html', latest_images=images)

# Prepare form to add
@app.route("/add", methods=['GET'])
def add():
    return render_template("images_form.html")

# Add text to database
@app.route("/add", methods=['POST'])
def imageadd():
    pname = request.form["name"]
    entry = Rds_images(name=pname)
    db.session.add(entry)
    db.session.commit()
    return redirect(url_for('index'))

# Return number of rows as json
@app.route('/num')
def db_entry_number():
    try:
        images_num = db.session.execute('SELECT COUNT(*) FROM rds_images;').first().count
    except sqlalchemy.exc.ProgrammingError as e:
        print(e)
        db.create_all()
        images_num = 0
    return jsonify({'Total': images_num})

# Health check for Target Group
@app.route('/hc')
def healt_check():
    return "OK", 200

# Run app on all i/f and port 5000
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)