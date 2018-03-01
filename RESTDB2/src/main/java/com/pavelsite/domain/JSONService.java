package com.pavelsite.domain;

import java.util.*;
import com.ibm.nosql.bson.types.ObjectId;
import com.ibm.nosql.json.api.*;


public class JSONService{
	
	private static JSONService service;
	private static DB db;
	private static TreeSet<String> cols;
	private static DBCollection curCol;
	private static String unnamed = "anonymous";
	private static String unnamedId = "anonymousId";
	
	private JSONService(){
			String databaseHost = "localhost";
		    int port = 50000;
		    String databaseName = "dbjson1";
		    String user = "yurchykp";
			String password = "PSink-1024";
		 
		    String databaseUrl = "jdbc:db2://" + databaseHost + ":" + port + "/" + databaseName;
		    
		    JSONService.db = NoSQLClient.getDB (databaseUrl, user, password);
		    JSONService.cols = new TreeSet<String>(JSONService.db.getCollectionNames());
		    JSONService.curCol = db.getCollection(cols.first());
		    
		    JSONService.service = this;
	}
	
	public static JSONService getService(){
		if (JSONService.service==null)
			return new JSONService();
		else
			return JSONService.service;
	}
	
	public String getCollectionNames() {
		JSONService.cols = new TreeSet<String>(JSONService.db.getCollectionNames());
		String res = "<option value=\"new_record\"> - New collection - </option>";
		for (String col:cols) {
			res += "<option value=\"" + col + "\">" + col + "</option>";
		}
		return res;
	}
	
	public static void setCurCol(String name) {
		JSONService.curCol = JSONService.db.getCollection(name);
	}
	 
	public static void addCollection(String name) {
		DBCollection newCol = JSONService.db.getCollection(name);
		BasicDBObject json = new BasicDBObject ();
		newCol.insert(json);
		newCol.remove(json);
	}
	
	public static void removeCollection(String name) {
		if (curCol.getName().equals(name)) {
			db.getCollection(name).drop();
			cols.remove(name);
			curCol = db.getCollection(cols.first());
		} else {
			db.getCollection(name).drop();
		}		
	}
	
	private LinkedHashMap<String, Object> checkName(LinkedHashMap<String, Object> json) {
		if (!json.containsKey("name")) {
			BasicDBObject anonymous = new BasicDBObject();
			int anonymousId = 1;
			anonymous.append("name", JSONService.unnamed);
			DBCursor cur = curCol.find(anonymous);
			TreeSet<Integer> ids = new TreeSet<Integer>();
			while (cur.hasNext()) {
				ids.add((Integer)cur.next().get(JSONService.unnamedId));
			}
			while (ids.contains(anonymousId)) {
				anonymousId++;
			}
			json.put("name", JSONService.unnamed);
			json.put(JSONService.unnamedId, anonymousId);
		}
		return json;
	}
	
	
	public Map<String,Object> getJSON(String id){
		DBCursor cur = curCol.find();
		Map<String,Object> resObj;
		while (cur.hasNext()) {
			BasicDBObject obj = (BasicDBObject)cur.next();
			ObjectId objId = (ObjectId)obj.getID();
			if (objId.toString().equals(id)) {
				resObj = obj.toMap();
				resObj.replace("_id", id);
				if (obj.containsKey(JSONService.unnamedId)) {
					resObj.remove("name");
					resObj.remove(JSONService.unnamedId);
				}
				return resObj;
			}
		}
		BasicDBObject json = new BasicDBObject ();
		return json;
	}
	
	public String addJSON(LinkedHashMap<String, Object> json){
		BasicDBObject jsonForDB = new BasicDBObject(this.checkName(json));
		curCol.insert(jsonForDB);
		if (jsonForDB.get("name").equals(JSONService.unnamed))
			return JSONService.unnamed + jsonForDB.get(JSONService.unnamedId);
		return jsonForDB.get("name").toString();
	}
	
	
	public String updateJSON(LinkedHashMap<String, Object> json){
		DBCursor cur = curCol.find();
		BasicDBObject jsonFromDb = null;
		while (cur.hasNext()) {
			BasicDBObject obj = (BasicDBObject)cur.next();
			ObjectId objId = (ObjectId)obj.getID();
			if (objId.toString().equals(json.get("tempId"))) {
				jsonFromDb = obj;
				break;
			}
		}
		if (jsonFromDb == null)
			return "";
		
		BasicDBObject copy = (BasicDBObject) jsonFromDb.copy();
		Set<String> keys = copy.keySet();
		for (String key:keys) {
			if (!key.equals("_id"))
				jsonFromDb.removeField(key);
		}
		keys = json.keySet();
		for (String key:keys) {
			if (!key.equals("tempId"))
				jsonFromDb.append(key, json.get(key));
		}
		if (!jsonFromDb.containsKey("name")) {
			if (copy.containsKey(JSONService.unnamedId)) {
				jsonFromDb.append("name", JSONService.unnamed);
				jsonFromDb.append(JSONService.unnamedId, copy.get(JSONService.unnamedId));
			} else {
				jsonFromDb = new BasicDBObject(this.checkName(jsonFromDb));
			}
		}
		curCol.remove(copy);
		curCol.insert(jsonFromDb);
		if (jsonFromDb.get("name").equals(JSONService.unnamed))
			return JSONService.unnamed + jsonFromDb.get(JSONService.unnamedId);
		return jsonFromDb.get("name").toString();
	}
	
	public String removeJSON(String id){
		String res;
		DBCursor cur = curCol.find();
		while (cur.hasNext()) {
			BasicDBObject obj = (BasicDBObject)cur.next();
			ObjectId objId = (ObjectId)obj.getID();
			if (objId.toString().equals(id)) {
				if (obj.get("name").equals(JSONService.unnamed))
					res = JSONService.unnamed + obj.get(JSONService.unnamedId);
				res = obj.get("name").toString();
				curCol.remove(obj);
				return res;
			}
		}
		return "";
	}
	
	public String getJSONIds() {
		DBCursor cur = curCol.find();
		BasicDBObject obj;
		TreeSet<String> list = new TreeSet<String>();
		String res = "<option value=\"new_record\"> - New record - </option>", temp;
		while (cur.hasNext()) {
			obj = (BasicDBObject)cur.next();
			if (!obj.containsField("name")) {
				list.add(JSONService.unnamed + "<option value=\"" + obj.getID() + "\">" + JSONService.unnamed + "</option>");
			} else if (obj.get("name").equals(JSONService.unnamed)) {
				list.add("" + obj.get("name") + obj.get(JSONService.unnamedId) + "<option value=\"" + obj.getID() + "\">" + obj.get("name") + obj.get(JSONService.unnamedId) + "</option>");
			} else {
				list.add("" + obj.get("name") + "<option value=\"" + obj.getID() + "\">" + obj.get("name") + "</option>");
			}
		}
		Iterator<String> it = list.iterator();
		while (it.hasNext()) {
			temp = it.next();
			res += temp.substring(temp.indexOf("<"));
		}
		return res;
	}
}
