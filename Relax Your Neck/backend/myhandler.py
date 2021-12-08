#!/usr/bin/python

from pymongo import MongoClient
import tornado.web

from tornado.web import HTTPError
from tornado.httpserver import HTTPServer
from tornado.ioloop import IOLoop
from tornado.options import define, options

from basehandler import BaseHandler

import turicreate as tc
import pickle
from bson.binary import Binary
import json
import numpy as np
from datetime import datetime

class PrintHandlers(BaseHandler):
    def get(self):
        '''Write out to screen the handlers used
        This is a nice debugging example!
        '''
        self.set_header("Content-Type", "application/json")
        self.write(self.application.handlers_string.replace('),','),\n'))

class DatabaseChecker(BaseHandler):
    def get(self):
        data = self.db.test.find_one({'id':1})
        if data:
            print(data)
            self.write_json({'ret': data['data']})

class CheckAchievement(BaseHandler):
    def post(self):
        inputData = json.loads(self.request.body.decode("utf-8"))  
        print(inputData['year'], inputData['month'], inputData['day']) 
        year = inputData['year']
        month = inputData['month']
        day = inputData['day']
        entry = self.db.calendar.find_one({'year': int(year), 'month': int(month), 'day': int(day)})
        if entry:
            ret = [entry['achieved'], entry['highest_score']]
            self.write_json({'ret': ret})
        else:
            ret = [False, 0]
            self.write_json({'ret': ret})

class UpdateScore(BaseHandler):
    def post(self):
        inputData = json.loads(self.request.body.decode("utf-8"))
        score = int(inputData['score'])
        achieved = True if inputData['achieved'] == '1' else False
        year = datetime.now().year
        month = datetime.now().month
        day = datetime.now().day
        entry = self.db.calendar.find_one({'year': int(year), 'month': int(month), 'day': int(day)})
        if entry:
            # if the user already played today 
            if entry['achieved'] == False and achieved == True:
                # check if achieve needs to be updated
                self.db.calendar.update_one({'year': int(year), 'month': int(month), 'day': int(day)}, {'$set': {'achieved': True}})
            if score > entry['highest_score']:
                # if the score is higher, update the score
                self.db.calendar.update_one({'year': int(year), 'month': int(month), 'day': int(day)}, {'$set': {'highest_score': score}})
        else:
            self.db.calendar.insert_one({'year': int(year), 'month': int(month), 'day': int(day), 'highest_score': score, 'achieved': achieved})
            entry = self.db.calendar.find_one({'year': int(year), 'month': int(month), 'day': int(day)})
            print('adding new score')
            print(entry)

