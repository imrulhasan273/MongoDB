# **MongoDB**

---

---


# **Basic Commands**

---

- Show all the db

```sql
> db
```

- Swith to another DB

```sql
> use foo
```

- Addministrative commands?

```sql
> help
```

- Get Server Address

```sql
> db.getMongo()
```

---

# **Replica Set**

---

- Config


```sql
> var demoConfig = {...}
```

```sql
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
```

```sql
> rs.initiate(demoConfig)
```

```sql
> db.foo.save({"_id": 1, "value":"Hello World"})
> db.foo.find()
```

- From Secondary slaves


```sql
> db.foo.find()     /* Could not find the data */
> db.setSlaveOk()
> db.foo.find()		/* Now ok*/
```

---

# **Saving Data**

---

1. Storage Engine
2. Saving Document
3. Update Document

> `BSON`

## Rule to save data

1. `Rule 1`: A doc must have an id (_id). If not put in then mongo will automatically assign an _id.
2. `Rule 2`: The size of doc in mongo is currently limited to 16MB. If want to extend then have to store it across multiple doc.

> MongoDB haven't any Table. It has collection.

- will show collection of that db

```sql
> use test_db		
> show collections  
```

```sql
> db.foo.save({_id: 1, x: 10})
```

> here **db**=>`test_db`, **foo**=> `collection`, **save**=> `saving the record`

- Fetch the record from foo collection

```sql
> db.foo.find()
```

```sql
> db.system.indexes.find()
```

- Type of `_id` in doc?

```sql
	_id: 1
	_id: 3.14
	_id: "Hello"
	_id: ISODate()
	_id: {a: 'X', b:'Y'}
```

> Only **Array type** `_id` is not valid in mongo. 

> `Sol?`: Convert the array to byte structure using bin data structure

## **Complex doc**

```sql
> db.users.save({ Name: 'Imrul' })
```

```sql
> db.users.find()
```

```sql
> ObjectId() 
```

> Generate using ob id serally wherever call this each of time. Object id generate with a timeStamps.

```sql
> ObjectId().getTimestamp()
```

> So we dont need to add extra column for creation time as timestamp contains inside ObjectId

- Insert on different doc with same id using `Save` method?

```sql
> db.foo.save({_id:1, name:'Imrul'})
```

```sql
> db.foo.save({_id:1, price:1.99})
```

```sql
> db.foo.find()
```

> only second doc was saved over the first one.

> `Solution?` Use Insert command instead of save command.

- Insert on different doc with same id using `insert` method?

```sql
> db.bar.insert({_id:1, name:'Imrul'})
```

```sql
> db.bar.insert({_id:1, price:1.99})
```

> Error [duplicate key error]

```sql
> db.bar.find()
```

> only second doc was saved over the first one.

> So save command will overwrite the doc. And insert command will insert data only if the id is `unique`

> In this case both doc will insert as mongo generate unique `_id` for both doc as we did not specify the `id`

```sql
> db.test.save({_id:1, address:{present:'savar', permanent:'dhamrai'}})
```

- Normal Output

```sql
> db.users.find()	
```

- Pretty Output

```sql
> db.users.find().pretty()
```

---

## **Save Danger**

---

- Below is very bad idea:

```sql
> db.a.save({_id:1, x:10})
> var doc = db.a.findOne({_id:1})
> doc.x = doc.x+1
> db.a.save(doc)
```

- Bad Idea:(Reasons)
    - doc conatains the some value exp: x:10. and after save it to a var and before save the data the value of x is increased by other thread so when i save the doc then interal value will be lost.
    - And in this interval period some new column y: 20 may be saved from other thread but when i save the doc then the y columns will be missing because I have preserve the doc inside a doc var.

- `Solution?` Updating Data

---

## **Updating Data**

---

> Atomic within a document: two update commands issued concurrently will be executed one after another.

> Syntax: `db.foo.update(query, update, options);`  Options=[One,Many, Upsert]


```sql
> db.b.save({_id:1, x:10})
> db.b.update({_id:1}, {$inc:{x:1}})
```

---

## **set Operator**

---


```sql
> db.b.find()	      /*{ "_id" : 1, "x" : 11 }*/
> db.b.update({_id:1}, {$set:{y:3}})
> db.b.update({_id:1}, {$inc:{x:1}})
> db.b.find()	     /*{ "_id" : 1, "x" : 12, "y" : 3 }*/
```

---

## **unset Operator**

---


```sql
> db.b.find()	/*{ "_id" : 1, "x" : 12, "y" : 3 }*/
> db.b.update({_id:1}, {$unset:{y:''}})
> db.b.find()	/*{ "_id" : 1, "x" : 12 }*/
```

---

## **Rename Operator**

---

```sql
> db.c.save({_id:1, Naem: 'Imrul'})
> db.c.find()	/*{ "_id" : 1, "Naem" : "Imrul" }*/
> db.c.update({_id:1}, {$rename:{'Naem':'Name'}})
> db.c.find()	/*{ "_id" : 1, "Name" : "Imrul" }*/
```

---

## **Push Operator**

---

```sql
> db.a.save({_id:1})
> db.a.find()	/*{ "_id" : 1 }*/

> db.a.update({_id:1}, {$push:{things: 'one'}})
> db.a.find()	/*{ "_id" : 1, "things" : [ "one" ] }*/

> db.a.update({_id:1}, {$push:{things: 'two'}})
> db.a.update({_id:1}, {$push:{things: 'three'}})
> db.a.find()	/*{ "_id" : 1, "things" : [ "one", "two", "three" ] }*/
> db.a.update({_id:1}, {$push:{things: 'three'}})
> db.a.find()	/*{ "_id" : 1, "things" : [ "one", "two", "three", "three" ] }*/
```

> `'three'` is pushed again although 'three' is already in the array.
-- How to prevent this?

```sql
> db.a.update({_id:1}, {$addToSet:{things: 'four'}})
> db.a.find()	/*{ "_id" : 1, "things" : [ "one", "two", "three", "three", "four" ] }*/
> db.a.update({_id:1}, {$addToSet:{things: 'four'}})
> db.a.find()	/*{ "_id" : 1, "things" : [ "one", "two", "three", "three", "four" ] }*/
```

---

## **Pull Operator**

---

```sql
> db.a.find() /*{ "_id" : 1, "things" : [ "one", "two", "three", "three", "fout", "four" ] }*/
```

> Here element 'fout' should be removed. one of the two `'three'` should be removed as it occurs twich.

- Removed all the element containing 'fout' from the array


```sql
> db.a.update({_id:1}, {$pull:{things: 'fout'}})
> db.a.find()	/*{ "_id" : 1, "things" : [ "one", "two", "three", "three", "four" ] }*/
```

---


---

## **Pop Operator**

---

```sql
> db.a.find()	/*{ "_id" : 1, "things" : [ "one", "two", "three", "three", "four" ] }*/

/*pop last element*/
> db.a.update({_id:1},{$pop:{things:1}})
> db.a.find()	/*{ "_id" : 1, "things" : [ "one", "two", "three", "three" ] }*/

/*pop first element*/
> db.a.update({_id:1},{$pop:{things:-1}})
> db.a.find()	/*{ "_id" : 1, "things" : [ "two", "three", "three" ] }*/

```

---


---

## **Array Type**

---

- Multiple Update

```sql
> db.m.find()
/*
	{ "_id" : 1, "things" : [ 1, 2, 3 ] }
	{ "_id" : 2, "things" : [ 2, 3 ] }
	{ "_id" : 3, "things" : [ 3 ] }
	{ "_id" : 4, "things" : [ 1, 3 ] }
*/
```

```sql
> db.m.update({},{$push:{things:4}})
> db.m.find()
/*
    { "_id" : 1, "things" : [ 1, 2, 3, 4 ] }
    { "_id" : 2, "things" : [ 2, 3 ] }
    { "_id" : 3, "things" : [ 3 ] }
    { "_id" : 4, "things" : [ 1, 3 ] }
*/
```

> Update only one record[first]. Becaseu default options for an update is to effect only one record.

> `Solution?`:: Add option as `{nulti:true}`

```sql
> db.m.update({},{$push:{things:4}}, {multi:true})
> db.m.find()
/*
    { "_id" : 1, "things" : [ 1, 2, 3, 4, 4 ] }
    { "_id" : 2, "things" : [ 2, 3, 4 ] }
    { "_id" : 3, "things" : [ 3, 4 ] }
    { "_id" : 4, "things" : [ 1, 3, 4 ] }
*/
```

- Update where things contains element '2'

```sql
> db.m.update({things:1},{$push:{things:78}}, {multi:true})
> db.m.find()
/*
    { "_id" : 1, "things" : [ 1, 2, 3, 4, 4, 78 ] }
    { "_id" : 2, "things" : [ 2, 3, 4 ] }
    { "_id" : 3, "things" : [ 3, 4 ] }
    { "_id" : 4, "things" : [ 1, 3, 4, 78 ] }
*/
```

---

---

## **Find and Modify**

---

---


# **Finding Documents**

---

## 3 Criteria
- Query Criteria
- Field Selection
- Cursor Operations

## Find

```sql
db.foo.find(query, projection)	
/***
	query: wich doc?
	projections: which fields should we return?
***/

> db.animals.find({_id:1})			//return whole doc.

> db.animals.find({_id:1}, {_id:1})	

> db.animals.find({_id:{$gt:5}}, {_id:1})	//get id of all all rows where id>5

> db.animals.find({_id:{$lt:5}}, {_id:1})	//lt:less than

> db.animals.find({_id:{$lte:5}}, {_id:1})	//less than equal:lte

> db.animals.find({_id:{$gt:2, $lt:4}}, {_id:1})	//greater than and less than

> db.animals.find({_id:{$not: {$gt:2}}}, {_id:1})	//not greater than 

> db.animals.find({_id: {$in: [1,3]} }, {_id:1})	//id in [1,3]

> db.animals.find({_id: {$nin: [1,3]} }, {_id:1})	//not in [1,3]
```

## Array

```sql
> db.animals.find({_id:1}).pretty()
```

```cmd
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
```


```sql
> db.animals.find({tags: 'cute'}, {name:1})		//case sensitive

> db.animals.find({tags: {$in: ['cute', 'ocean']} }, {name:1})

> db.animals.find({tags: {$all: ['cute', 'ocean']} }, {name:1})	///get data where tags are both 'cute' and 'ocean'

> db.animals.find({tags: {$nin: ['cute']} }, {name:1})	//get who are not cute as tags
```


## Dot Notation

- `"info"` contains sub document.


```sql
> db.animals.find({"info.canFly":true}).pretty()	//info is attr of doc and canFly is attr of info.


> db.animals.find({"info": {type:'bird', canFly:true}}, {name:1})//get the rows

> db.animals.find({"info": {canFly:true, type:'bird'}}, {name:1})//may not get the rows if unordered
	
> db.animals.find({"info.canFly":true, "info.type":'bird'},{name:1})//Safe Zone | Using dot notation.

```

## Null and $exists


```sql

> db.animals.find({"info.canFly": null},{name:1})	//return both where canFly == null or canFly field is not exists

//If I want to be strict on that
> db.animals.find({"info.canFly": {$exists: true} },{name:1})
```

## And


```sql
> db.animals.find({"info.type":'bird', tags:'ocean'}, {name:1}) ///here `,` performs like an AND
```

## More Projection

```sql
> db.animals.find({_id:1}, {_id:1, name:1})	//Return included id and name


> db.animals.find({_id:1}, {_id:0, name:0})	//Return excluding id and name

> db.animals.find({_id:1}, {name:1})	//will return id and name. id is special field if not mentioned then id will be returned by default
```


## Cursor


```sql
> var c  = db.animals.find({},{name:1})

> c.size()	//6

> c.hasNext()	//true

> c.forEach( function(d) { print(d.name) } )
```


## Sort

```sql
> db.animals.find({},{name:1}).sort({name:1}) //ASC:1 | DESC:-1

//Can sort in sub doc too.
> db.animals.find({},{name:1, "info.type":1}).sort({"info.type":1,"name":1})	
```


## Limit

```sql
> db.animals.find({},{name:1}).sort({name:1}).limit(3)	//top 2 rows will be returned
```

## skip


```sql
-- {1,2,3,4,5,6}
> db.animals.find({},{name:1}).sort({_id:-1}).skip(1).limit(3)	//results: 5,4,3 [_id=6 is skipped]
```


## findOne

```sql
> db.animals.findOne({_id:1})	//returns only 1 row
```


---

---

# **Indexing**

---

- Mongo Indexes
- Indexing a collection
- Usage by queries


## Problem

```sql
> db.foo.find({x:10})
```

```js
//Server Does: 
 for each doc d in 'foo'{
	if (d.x==10){
		return d
	}
 }
```


## Indexes in Mongo

1. Regular (B-Tree)
	- single field or multiple field or multiple values as well.
2. Geo Index	
	- for GEO queries. Doesn't have to be geography. This supports proximity of points to a center
3. Text Index
	- things like search engine.
4. Hash Index
	- Sharding
5. TTL		
	- Time To Live. Date time field(expiration date). Removed this when it expires.


# Create Index

```sql
> db.foo.ensureIndex(keys, options)	
```

- `keys`: which fields? in what order? geo/text?
- `options`: Name? Build now? Unique, Sparse?, TTL?, Language?


## system.indexes collection

- Finding indexes in the animals collection


```sql
> db.system.indexes.find({ns:'test.animals'}, {key:1})	
/***
{ "key" : {"_id": 1} }
	so id is indexed only
	--ns: Namespace
	--db: test
	--collection: anmimals
***/
```


## Explain()

```sql
> db.animals.find({name:'cat'}).explain()
/***
	cursor: BasicCursor ; when no index
	cursor: index ; when indexed :Index: BtreeCursor name_1, etc
	nscanned:1 ; before indexing it was the size of the doc
***/
```


## Create an index

```sql
> db.animals.ensureIndex({name:1})	//1:index in ASC order, -1:index in DESC order

```


## Scanned vs Return




## drop Index

```sql
> db.animals.dropIndex("name_1") //"name_1" is the name of the index. indexing on "_id" is always. _id can not be dropped.
```

## Nested Fields

```sql
> db.animals.ensureIndex({"info.color":1})	//info is the field of doc. color is field of info.
```


## Array Field


```sql
> db.animals.ensureIndex({tags:1})	//tags is an array
```


## Sort

```sql
> db.animals.find({tags:'ocean'}).sort({name:1}).explain()	//scanAndOrder: false
```

## Unique

```sql
> db.animals.ensureIndex({name:1}, {unique:true})	//So name should be unique. Duplicate entry will cause an error
```

## Sparse

- For very large doc --> index will create an entry for every doc. It will save null if the key doesnt exists.

- Sparce: --> only create an entry for the doc where the field exists.

```sql
> db.animals.ensureIndex({"info.color":1}, {sparse:true})	//sparse index on color field
```


## Compound


```sql
> db.animals.ensureIndex({tags:1, name:1})	//index on tags and name
```


## Sort Direction


## Dead Weight

## Background Build

```sql
> db.animals.ensureIndex({tags:1}, {background: true})	
//So indexing will execute in Background... So read and write operation can be execute while indexing
```

> `disadvantage`: much longer time than of foreground


## Index Name

- Index name: field_name + sorting_direction

- `disad`: index name might be very long if a key have many nested fields


- Solution?

```sql
> db.animals.ensureIndex(keys, {name: 'small'})
> db.system.indexes.find({ns: 'test.animals'}).pretty()
```







