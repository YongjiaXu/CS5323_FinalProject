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
            score = entry['highest_score']
            game_goal = entry['game_goal']
            step = entry['step']
            step_goal = entry['step_goal']
            print('Score: {} Game_goal: {} Step: {} Step_goal: {}'.format(score, game_goal, step, step_goal))
            if score >= game_goal or step >= step_goal:
                self.write_json({'ret': 1}) # achieved
            else:
                self.write_json({'ret': 0}) # not achieved
        else:
            self.write_json({'ret': 2}) # not checked in

class UpdateScore(BaseHandler):
    def post(self):
        inputData = json.loads(self.request.body.decode("utf-8"))
        score = int(inputData['score'])
        year = datetime.now().year
        month = datetime.now().month
        day = datetime.now().day
        entry = self.db.calendar.find_one({'year': int(year), 'month': int(month), 'day': int(day)})
        if entry:
            # if the user already played today 
            if score > entry['highest_score']:
                # if the score is higher, update the score
                self.db.calendar.update_one({'year': int(year), 'month': int(month), 'day': int(day)}, {'$set': {'highest_score': score}})
        else:
            ret = self.db.user.find_one({'step_goal': {'$exists': True}, 'game_goal': {'$exists': True}})
            step_goal = ret['step_goal']
            game_goal = ret['game_goal']
            self.db.calendar.insert_one({'year': int(year), 'month': int(month), 'day': int(day), 'highest_score': score, 'step_goal': step_goal, 'game_goal': game_goal})
            entry = self.db.calendar.find_one({'year': int(year), 'month': int(month), 'day': int(day)})
            print('adding new score')
            print(entry)

class UpdateStep(BaseHandler):
    def post(self):
        inputData = json.loads(self.request.body.decode("utf-8"))
        step = int(inputData['step'])
        year = datetime.now().year
        month = datetime.now().month
        day = datetime.now().day
        entry = self.db.calendar.find_one({'year': int(year), 'month': int(month), 'day': int(day)})
        if entry:
            # steps only increase; read from pedometer
            self.db.calendar.update_one({'year': int(year), 'month': int(month), 'day': int(day)}, {'$set': {'step': step}})
        else:
            # insert new entry
            # get previous step_goal and game_goal
            # this is always called first
            ret = self.db.user.find_one({'step_goal': {'$exists': True}, 'game_goal': {'$exists': True}})
            step_goal = ret['step_goal']
            game_goal = ret['game_goal']
            self.db.calendar.insert_one({'year': int(year), 'month': int(month), 'day': int(day), 'step': step, 'step_goal': step_goal, 'highest_score': 0, 'game_goal': game_goal})
            entry = self.db.calendar.find_one({'year': int(year), 'month': int(month), 'day': int(day)})
            print('adding new step')
            print(entry)

class UpdateGameGoal(BaseHandler):
    def post(self):
        inputData = json.loads(self.request.body.decode("utf-8"))
        game_goal = int(inputData['game_goal'])
        year = datetime.now().year
        month = datetime.now().month
        day = datetime.now().day
        entry = self.db.calendar.find_one({'year': int(year), 'month': int(month), 'day': int(day)})
        if entry: 
            self.db.calendar.update_one({'year': int(year), 'month': int(month), 'day': int(day)}, {'$set': {'game_goal': game_goal}})
        else: 
            self.db.calendar.insert_one({'year': int(year), 'month': int(month), 'day': int(day), 'game_goal': game_goal})
            entry = self.db.calendar.find_one({'year': int(year), 'month': int(month), 'day': int(day)})
            print('updating new game_goal')
            print(entry)
        try:
            self.db.user.update_many({}, {'$set': {'game_goal': game_goal}})
        except:
            self.db.user.insert_one({'game_goal': game_goal, 'step_goal': 0})

class UpdateStepGoal(BaseHandler):
    def post(self):
        inputData = json.loads(self.request.body.decode("utf-8"))
        step_goal = int(inputData['step_goal'])
        year = datetime.now().year
        month = datetime.now().month
        day = datetime.now().day
        entry = self.db.calendar.find_one({'year': int(year), 'month': int(month), 'day': int(day)})
        if entry: 
            self.db.calendar.update_one({'year': int(year), 'month': int(month), 'day': int(day)}, {'$set': {'step_goal': step_goal}})
        else: 
            self.db.calendar.insert_one({'year': int(year), 'month': int(month), 'day': int(day), 'step_goal': step_goal})
            entry = self.db.calendar.find_one({'year': int(year), 'month': int(month), 'day': int(day)})
            print('updating new step_goal')
            print(entry)
        try:
            self.db.user.update_many({}, {'$set': {'step_goal': step_goal}})
        except:
            self.db.user.insert_one({'game_goal': 0, 'step_goal': step_goal})

class GetGameGoal(BaseHandler):
    def get(self):
        ret = self.db.user.find_one({'game_goal': {'$exists': True}})
        if ret:
            self.write_json({'ret': ret['game_goal']})

class GetStepGoal(BaseHandler):
    def get(self):
        ret = self.db.user.find_one({'step_goal': {'$exists': True}})
        if ret:
            self.write_json({'ret': ret['step_goal']})

class GetHighestScore(BaseHandler):
    def get(self):
        highest_score = 0
        for a in self.db.calendar.find():
            if a['highest_score'] > highest_score:
                highest_score = a['highest_score']
        self.write_json({'ret': highest_score})

class GetScoreOfTheDay(BaseHandler):
    def post(self):
        inputData = json.loads(self.request.body.decode("utf-8"))  
        print(inputData['year'], inputData['month'], inputData['day']) 
        year = inputData['year']
        month = inputData['month']
        day = inputData['day']
        entry = self.db.calendar.find_one({'year': int(year), 'month': int(month), 'day': int(day)})
        if entry:
            self.write_json({'ret': entry['highest_score']})
        else:
            self.write_json({'ret': 0})

class GetStepOfTheDay(BaseHandler):
    def post(self):
        inputData = json.loads(self.request.body.decode("utf-8"))  
        print(inputData['year'], inputData['month'], inputData['day']) 
        year = inputData['year']
        month = inputData['month']
        day = inputData['day']
        entry = self.db.calendar.find_one({'year': int(year), 'month': int(month), 'day': int(day)})
        if entry:
            self.write_json({'ret': entry['step']})
        else:
            self.write_json({'ret': 0})
