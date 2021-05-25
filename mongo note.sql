
######################################################### MONGO DB ##################################################
--Show all the db
~$ show dbs

--Which DB you are you now?
~$ db

-- Swith to another DB
> use foo

-- Addministrative commands?
> help

--Get Server Address
> db.getMongo()


-------------------Replica Set
------------------------------

--Config

> var demoConfig = {...}

> demoConfig
	{
		"_id"	 :"demo",
		"members": [
			{
				"_id"	   :0,
				"host"	   : "localhost: 30000",
				"priority" : 10
			},
			{
				"_id"	   :1,
				"host"     : "localhost: 40000",
			},
			{
				"_id"	     :0,
				"host"	     : "localhost: 30000",
				"arbiterOnly":true
			}
		]
	}


> rs.initiate(demoConfig)

> db.foo.save({"_id": 1, "value":"Hello World"})
> db.foo.find()

--From Secondary slaves
> db.foo.find()   --Could not find the data
> db.setSlaveOk()
> db.foo.find()		--now ok


----------------------------------------------------------------Saving Data
----------------------------------------------------------------------------
--Storage Engine
--Saving Document
--Update Document

--BSON

---------Saving Data: Rule
--Rule 1: A doc must have an id (_id). If not put in then mongo will automatically assign an _id.

--the size of doc in mongo is currently limited to 16MB.
	--If want to extend--> have to store it across multiple doc.

-- MongoDB haven't any Table. It has collection.

> use test_db		
> show collections  --will show collection of that db

> db.foo.save({_id: 1, x: 10})	--here db=>test_db, foo=> collection name, save=> saving the record

> db.foo.find()	--fetch the record from foo collection

> db.system.indexes.find()

---> type of _id in doc?
	_id: 1
	_id: 3.14
	_id: "Hello"
	_id: ISODate()
	_id: {a: 'X', b:'Y'}
	-----Only Array type _id is not valid in mongo
	--> Sol? :convert the array to byte structure using bin data structure


--Complex doc

> db.users.save({ Name: 'Imrul' })

> db.users.find()

> ObjectId() --generate using ob id serally wherever call this each of time
--Object id generate with a timeStamps

> ObjectId().getTimestamp()
	-- So we dont need to add extra column for creation time as timestamp contains inside ObjectId



---Insert on different doc with same id?

> db.foo.save({_id:1, name:'Imrul'})
> db.foo.save({_id:1, price:1.99})

>db.foo.find()	--only second doc was saved over the first one.

---use Insert command instead of save command


> db.bar.insert({_id:1, name:'Imrul'})
> db.bar.insert({_id:1, price:1.99})	--Error [duplicate key error]

>db.bar.find()	--only second doc was saved over the first one.

---So save command will overwrite the doc. And insert command will insert data only if the id is unique

> db.bar.insert({ name:'Imrul'})
> db.bar.insert({price:1.99})	

--In this case both doc will insert as mongo generate unique _id for both doc as we did not specify the id

> db.test.save({_id:1, address:{present:'savar', permanent:'dhamrai'}})
> db.users.find()	--Normal Output
> db.users.find().pretty()	--Pretty Output with formated

----Save Danger 
---Below is very bad idea:
> db.a.save({_id:1, x:10})
> var doc = db.a.findOne({_id:1})
> doc.x = doc.x+1
> db.a.save(doc)
	--Bad Idea:(Reasons)
		--1. doc conatains the some value exp: x:10.
			and after save it to a var and before save the data the value of x is increased by other thread
			so when i save the doc then interal value will be lost.
		--2. And in this interval period some new column y: 20 may be saved from other thread
			but when i save the doc then the y columns will be missing because I have preserve the doc
			inside a doc var.



-------------------Updating Data
--------------------------------

--Atomic within a document: two update commands issued concurrently will be executed one after another

Syntax: db.foo.update(query, update, options); --Options=[One,Many, Upsert]


> db.b.save({_id:1, x:10})
> db.b.update({_id:1}, {$inc:{x:1}})

----set Operator
---------------
> db.b.find()	--{ "_id" : 1, "x" : 11 }
> db.b.update({_id:1}, {$set:{y:3}})
> db.b.update({_id:1}, {$inc:{x:1}})
> db.b.find()	--{ "_id" : 1, "x" : 12, "y" : 3 }


----unset Operator
-------------------
> db.b.find()	--{ "_id" : 1, "x" : 12, "y" : 3 }
> db.b.update({_id:1}, {$unset:{y:''}})
> db.b.find()	--{ "_id" : 1, "x" : 12 }


----Rename Operator
-------------------
> db.c.save({_id:1, Naem: 'Imrul'})
> db.c.find()	--{ "_id" : 1, "Naem" : "Imrul" }

> db.c.update({_id:1}, {$rename:{'Naem':'Name'}})
> db.c.find()	--{ "_id" : 1, "Name" : "Imrul" }

----Push Operator
-----------------
> db.a.save({_id:1})
> db.a.find()	--{ "_id" : 1 }

> db.a.update({_id:1}, {$push:{things: 'one'}})
> db.a.find()	--{ "_id" : 1, "things" : [ "one" ] }

> db.a.update({_id:1}, {$push:{things: 'two'}})
> db.a.update({_id:1}, {$push:{things: 'three'}})
> db.a.find()	--{ "_id" : 1, "things" : [ "one", "two", "three" ] }
> db.a.update({_id:1}, {$push:{things: 'three'}})
> db.a.find()	--{ "_id" : 1, "things" : [ "one", "two", "three", "three" ] }

-- 'three' is pushed again although 'three' is already in the array.
-- How to prevent this?

> db.a.update({_id:1}, {$addToSet:{things: 'four'}})
> db.a.find()	--{ "_id" : 1, "things" : [ "one", "two", "three", "three", "four" ] }
> db.a.update({_id:1}, {$addToSet:{things: 'four'}})
> db.a.find()	--{ "_id" : 1, "things" : [ "one", "two", "three", "three", "four" ] }


----Pull Operator
-----------------

> db.a.find()
{ "_id" : 1, "things" : [ "one", "two", "three", "three", "fout", "four" ] }

-- here element 'fout' should be removed
-- one of the two 'three' should be removed as it occurs twich.

--Removed all the element containing 'fout' from the array
> db.a.update({_id:1}, {$pull:{things: 'fout'}})
> db.a.find()	--{ "_id" : 1, "things" : [ "one", "two", "three", "three", "four" ] }


----Pop Operator
-----------------

> db.a.find()	--{ "_id" : 1, "things" : [ "one", "two", "three", "three", "four" ] }

--pop last element
> db.a.update({_id:1},{$pop:{things:1}})
> db.a.find()	--{ "_id" : 1, "things" : [ "one", "two", "three", "three" ] }

--pop first element
> db.a.update({_id:1},{$pop:{things:-1}})
> db.a.find()	--{ "_id" : 1, "things" : [ "two", "three", "three" ] }


----Array Type
-----------------


----Multiple Update
-------------------

> db.m.find()
	{ "_id" : 1, "things" : [ 1, 2, 3 ] }
	{ "_id" : 2, "things" : [ 2, 3 ] }
	{ "_id" : 3, "things" : [ 3 ] }
	{ "_id" : 4, "things" : [ 1, 3 ] }

> db.m.update({},{$push:{things:4}})
> db.m.find()
{ "_id" : 1, "things" : [ 1, 2, 3, 4 ] }
{ "_id" : 2, "things" : [ 2, 3 ] }
{ "_id" : 3, "things" : [ 3 ] }
{ "_id" : 4, "things" : [ 1, 3 ] }
--Update only one record[first]. Becaseu default options for an update is to effect only one record
--Solution? :: Add option as {nulti:true}
> db.m.update({},{$push:{things:4}}, {multi:true})
> db.m.find()
{ "_id" : 1, "things" : [ 1, 2, 3, 4, 4 ] }
{ "_id" : 2, "things" : [ 2, 3, 4 ] }
{ "_id" : 3, "things" : [ 3, 4 ] }
{ "_id" : 4, "things" : [ 1, 3, 4 ] }

--Update where things contains element '2'
> db.m.update({things:1},{$push:{things:78}}, {multi:true})
> db.m.find()
{ "_id" : 1, "things" : [ 1, 2, 3, 4, 4, 78 ] }
{ "_id" : 2, "things" : [ 2, 3, 4 ] }
{ "_id" : 3, "things" : [ 3, 4 ] }
{ "_id" : 4, "things" : [ 1, 3, 4, 78 ] }



----Find and Modify
-------------------




----------------------------------------------------------------Finding Documents
---------------------------------------------------------------------------------
--Query Criteria
--Field Selection
--Cursor Operations

---Find
-------

db.foo.find(query, projection)	--query: wich doc? | projections: which fields should we return?

> db.animals.find({_id:1})	--return whole doc.

> db.animals.find({_id:1}, {_id:1})	


> db.animals.find({_id:{$gt:5}}, {_id:1})	--get id of all all rows where id>5

> db.animals.find({_id:{$lt:5}}, {_id:1})	--lt:less than

> db.animals.find({_id:{$lte:5}}, {_id:1})	--les than equal:lte


> db.animals.find({_id:{$gt:2, $lt:4}}, {_id:1})	--greater than and less than

> db.animals.find({_id:{$not: {$gt:2}}}, {_id:1})	-- not greater than 

> db.animals.find({_id: {$in: [1,3]} }, {_id:1})	-- id in [1,3]


> db.animals.find({_id: {$nin: [1,3]} }, {_id:1})	-- not in [1,3]


---Array
--------

> db.animals.find({_id:1}).pretty()

{
	"_id"	: 1,
	"name"	: "cat",
	"tags"	: [
		"land",
		"cute"
	],
	"info"	: {
		"type"	:"mammal",
		"color"	:"red"
	}
}

> db.animals.find({tags: 'cute'}, {name:1})	--case sensitive

> db.animals.find({tags: {$in: ['cute', 'ocean']} }, {name:1})

> db.animals.find({tags: {$all: ['cute', 'ocean']} }, {name:1})	--get data where tags are both 'cute' and 'ocean'

> db.animals.find({tags: {$nin: ['cute']} }, {name:1})	--get who are not cute as tags


----Dot Notation
----------------

--"info" contains sub document.


> db.animals.find({"info.canFly":true}).pretty()	--info is attr of doc and canFly is attr of info.


> db.animals.find({"info": {type:'bird', canFly:true}}, {name:1})	--get the rows

> db.animals.find({"info": {canFly:true, type:'bird'}}, {name:1})	--may not get the rows if unordered
	
> db.animals.find({"info.canFly":true, "info.type":'bird'},{name:1})	--Safe Zone | Using dot notation.

-----Null and $exists
---------------------

> db.animals.find({"info.canFly": null},{name:1})	--return both where canFly == null or canFly field is not exists

--If I want to be strict on that

> db.animals.find({"info.canFly": {$exists: true} },{name:1})


-------And
----------

> db.animals.find({"info.type":'bird', tags:'ocean'}, {name:1}) --here `,` performs like an AND



-----More Projection
-------------------


> db.animals.find({_id:1}, {_id:1, name:1})	--Return included id and name


> db.animals.find({_id:1}, {_id:0, name:0})	-Return excluding id and name

> db.animals.find({_id:1}, {name:1})		--will return id and name. id is special field if not mentioned then id will be returned by default


------Cursor
------------

> var c  = db.animals.find({},{name:1})

> c.size()	--6

> c.hasNext()	--true

> c.forEach( function(d) { print(d.name) } )


-----Sort
---------
> db.animals.find({},{name:1}).sort({name:1})	--ASC:1 | DESC:-1

--Can sort in sub doc too.

> db.animals.find({},{name:1, "info.type":1}).sort({"info.type":1,"name":1})	


-----Limit
----------
> db.animals.find({},{name:1}).sort({name:1}).limit(3)	--top 2 rows will be returned


----skip
--------

-- {1,2,3,4,5,6}
> db.animals.find({},{name:1}).sort({_id:-1}).skip(1).limit(3)	-- results: 5,4,3 [_id=6 is skipped]


----findOne
----------
> db.animals.findOne({_id:1})	--returns only 1 row





----------------------------------------------------------------Indexing
------------------------------------------------------------------------

--Mongo Indexes
--Indexing a collection
--Usage by queries

--problem

> db.foo.find({x:10})

--Server Does: 
 for each doc d in 'foo'{
	if (d.x==10){
		return d
	}
 }


-------Indexes in Mongo
-----------------------

1. Regular (B-Tree)	--single field or multiple field or multiple values as well.
2. Geo Index		--for GEO queries. Doesn't have to be geography. This supports proximity of points to a center
3. Text Index		--things like search engine.
4. Hash Index		--Sharding
5. TTL			--Time To Live. Date time field(expiration date). Removed this when it expires.

---Create Index
---------------


> db.foo.ensureIndex(keys, options)	
	--keys: which fields? in what order? geo/text?
	--options: Name? Build now? Unique, Sparse?, TTL?, Language?


---system.indexes collection
----------------------------

--Finding indexes in the animals collection

> db.system.indexes.find({ns:'test.animals'}, {key:1})	
{ "key" : {"_id": 1} }	--so id is indexed only
	--ns: Namespace
	--db: test
	--collection: anmimals

----Explain()
-------------

> db.animals.find({name:'cat'}).explain()
	--cursor: BasicCursor 	; when no index
	--cursor: index		; when indexed :Index: BtreeCursor name_1, etc
	--nscanned:1		--before indexing it was the size of the doc


---Create an index
> db.animals.ensureIndex({name:1})	--1:index in ASC order, -1:index in DESC order




----Scanned vs Return
---------------------

----drop Index
--------------

> db.animals.dropIndex("name_1")	--"name_1" is the name of the index
	--indexing on "_id" is always. _id can not be dropped.

-----Nested Fields
------------------

> db.animals.ensureIndex({"info.color":1})	--info is the field of doc. color is field of info.

----Array Field
----------------

> db.animals.ensureIndex({tags:1})		--tags is an array

-----Sort
---------

> db.animals.find({tags:'ocean'}).sort({name:1}).explain()	--scanAndOrder: false

----Unique
----------
> db.animals.ensureIndex({name:1}, {unique:true})	--So name should be unique. Duplicate entry will cause an error


---Sparse
---------

--For very large doc--> index will create an entry for every doc. It will save null if the key doesnt exists.

--Sparce: --> only create an entry for the doc where the field exists.

> db.animals.ensureIndex({"info.color":1}, {sparse:true})	--sparse index on color field


----Compound
------------

> db.animals.ensureIndex({tags:1, name:1})	--index on tags and name



----Sort Direction
------------------



----Dead Weight
---------------



---Background Build
---------------------
> db.animals.ensureIndex({tags:1}, {background: true})	--So indexing will execute in Background... So read and write operation can be execute while indexing

	--disad: much longer time than of foreground


-----Index Name
---------------

Index name: field_name + sorting_direction

	---disad: index name might be very long if a key have many nested fields
	
--sol:
> db.animals.ensureIndex(keys, {name: 'small'})

> db.system.indexes.find({ns: 'test.animals'}).pretty()
























		













