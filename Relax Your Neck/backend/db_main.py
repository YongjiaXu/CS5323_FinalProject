from pprint import pprint
from pymongo import MongoClient, database
from pymongo import MongoClient
import urllib.parse
import uuid
import re
# client = MongoClient(
#     host='mongodb+srv://db-mongodb-nyc3-09239-f09d6973.mongo.ondigitalocean.com/admin',
#     port=27017,
#     username='doadmin',
#     password='I3qJ52G1cO0H87g4',
#     tlsCAFile='ca-certificate.crt',
# )
# db = client.admin
# print(db.list_collection_names())

#!/usr/bin/python
'''Starts and runs the scikit learn server'''

# For this to run properly, MongoDB must be running
#    Navigate to where mongo db is installed and run
#    something like $./mongod --dbpath "/data/db"
#    might need to use sudo (yikes!)

# database imports
from pymongo import MongoClient
from pymongo.errors import ServerSelectionTimeoutError


# tornado imports
import tornado.web
from tornado.web import HTTPError
from tornado.httpserver import HTTPServer
from tornado.ioloop import IOLoop
from tornado.options import define, options

# custom imports
from basehandler import BaseHandler
import myhandler as mh

# Setup information for tornado class
define("port", default=8000, help="run on the given port", type=int)

# Utility to be used when creating the Tornado server
# Contains the handlers and the database connection
class Application(tornado.web.Application):
    def __init__(self):
        '''Store necessary handlers,
           connect to database
        '''

        handlers = [(r"/[/]?", BaseHandler),
                    (r"/Handlers[/]?",          mh.PrintHandlers),
                    (r"/CheckDatabase[/]?",     mh.DatabaseChecker),
                    (r"/CheckAchievement[/]?",  mh.CheckAchievement),
                    (r"/UpdateScore[/]?",       mh.UpdateScore),
                    (r"/UpdateStep[/]?",       mh.UpdateStep),
                    (r"/UpdateGameGoal[/]?",    mh.UpdateGameGoal),
                    (r"/UpdateStepGoal[/]?",    mh.UpdateStepGoal),
                    (r"/GetGameGoal[/]?",       mh.GetGameGoal),
                    (r"/GetStepGoal[/]?",       mh.GetStepGoal),
                    ]

        self.handlers_string = str(handlers)

        try:
            self.client  = MongoClient(
                    host='mongodb+srv://db-mongodb-nyc3-54008-9ecc7afd.mongo.ondigitalocean.com/admin',
                    port=27017,
                    username='doadmin',
                    password='gdjnE4928637IOZ5',
                    tlsCAFile='ca-certificate.crt',
                ) 
            print(self.client.server_info()) # force pymongo to look for possible running servers, error if none running
            # if we get here, at least one instance of pymongo is running
            self.db = self.client.admin # database with labeledinstances, models
            
        except ServerSelectionTimeoutError as inst:
            print('Could not initialize database connection, stopping execution')
            print('Are you running a valid local-hosted instance of mongodb?')
            print('   Navigate to where mongo db is installed and run')
            print('   something like $./mongod --dbpath "/data/db"')
            #raise inst
        
        self.clf = {}    #  make clf an empty dictionary instead of a list

        settings = {'debug':True}
        tornado.web.Application.__init__(self, handlers, **settings)

    def __exit__(self):
        self.client.close() # just in case


def main():
    '''Create server, begin IOLoop 
    '''
    tornado.options.parse_command_line()
    http_server = HTTPServer(Application(), xheaders=True)
    http_server.listen(options.port)
    IOLoop.instance().start()

if __name__ == "__main__":
    main()
