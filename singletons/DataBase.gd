extends Node

var db : SQLite = null
var dbName = "res://dataStore/database"




func _ready():
	db = SQLite.new()
	db.path = dbName

func commit2DB(dict):
	var tableDict : Dictionary = Dictionary()
	tableDict["Data"] = {"data_type": "blob"}
	db.open_db()
#
#	db.drop_table("LeaderBoard")
#
#	db.create_table("LeaderBoard", tableDict)
	
	var tableName = "LeaderBoard"
	
	
	db.insert_row(tableName, dict)

func readFromDB():
	db.open_db()
	var tableName = "LeaderBoard"
	db.query("select * from " + tableName + ";")
	for i in range(0, db.query_result.size()):
		print(" Query results ", db.query_result[i]["Name"], db.query_result[i]["Score"])
	return db.query_result
