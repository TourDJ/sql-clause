
## connect monogdb
from pymongo import MongoClient

#client = MongoClient('localhost', 27017)
#client = MongoClient('mongodb://localhost:27017/')
client = MongoClient('mongodb://tang:123456@127.0.0.1:27017/?authSource=tangdb&authMechanism=SCRAM-SHA-256')
db = client.test_database
collection = db.test_collection

