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

# entry = db.calendar.find_one({'year': 2021, 'month': 12, 'day': 7})
# print(entry)
# db.calendar.update_one({'year': 2021, 'month': 12, 'day': 7}, {'$set': {'highest_score': 0}})
# db.calendar.update_one({'year': 2021, 'month': 12, 'day': 7}, {'$set': {'achieved': False}})
# entry = db.calendar.find_one({'year': 2021, 'month': 12, 'day': 7})
# print(entry)
# for a in db.calendar.find():
#     print(a)

# # db.user.insert_one({'game_goal': 5, 'step_goal': 1000})
# for a in db.user.find():
#     print(a)
# # db.user.update_many({}, {'$set': {'game_goal': 10}})
# for a in db.user.find():
#     print(a)

# a = db.user.find_one({'game_goal': {'$exists': True}})
# print(a)
year = datetime.now().year
month = datetime.now().month
day = datetime.now().day
# db.calendar.insert_one({'year': int(year), 'month': int(month), 'day': int(day)})
# db.calendar.update_one({'year': 2021, 'month': 12, 'day': 8}, {'$set': {'highest_score': 0}})
# year, month, day, highest_score, steps, game_goal, step_goal
# db.calendar.insert_one({'year': 2021, 'month': 12, 'day': 7, 'step': 50, 'step_goal': 25, 'highest_score': 0, 'game_goal': 0})
# db.calendar.insert_one({'year': 2021, 'month': 12, 'day': 7, 'step': 50, 'step_goal': 25, 'highest_score': 0, 'game_goal': 0})

db.calendar.delete_one({'year': 2021, 'month': 12, 'day': 7})
for a in db.calendar.find():
    print(a)
