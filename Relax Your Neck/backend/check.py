from pprint import pprint
from pymongo import MongoClient, database
from pymongo import MongoClient
import urllib.parse
import uuid
import re
from datetime import datetime

client = MongoClient(
    host='mongodb+srv://db-mongodb-nyc3-54008-9ecc7afd.mongo.ondigitalocean.com/admin',
    port=27017,
    username='doadmin',
    password='gdjnE4928637IOZ5',
    tlsCAFile='ca-certificate.crt',
)
db = client.admin
print(db.list_collection_names())
print(type(datetime.now().year))
# db.test.insert_one({'id': 3, 'data': {'$currentDate'}})
# a = db.test.find_one({'id': 2})
for a in db.test.find():
    print(a)

entry = db.calendar.find_one({'year': 2021, 'month': 12, 'day': 7})
print(entry)
db.calendar.update_one({'year': 2021, 'month': 12, 'day': 7}, {'$set': {'highest_score': 0}})
db.calendar.update_one({'year': 2021, 'month': 12, 'day': 7}, {'$set': {'achieved': False}})
entry = db.calendar.find_one({'year': 2021, 'month': 12, 'day': 7})
print(entry)
for a in db.calendar.find():
    print(a)