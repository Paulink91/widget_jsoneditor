package com.pavelsite.domain;

import java.util.*;
import com.ibm.nosql.bson.types.ObjectId;
import com.ibm.nosql.json.api.*;


public class JSONService{
	
	private static JSONService service;
	private static DB db;
	private static TreeSet<String> cols;
	private static DBCollection curCol;
	
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
	
	public Map<String,Object> getJSON(String id){
		DBCursor cur = curCol.find();
		Map<String,Object> resObj;
		while (cur.hasNext()) {
			BasicDBObject obj = (BasicDBObject)cur.next();
			ObjectId objId = (ObjectId)obj.getID();
			if (objId.toString().equals(id)) {
				resObj = obj.toMap();
				resObj.replace("_id", id);
				return resObj;
			}
		}
		BasicDBObject json = new BasicDBObject ();
		return json;
	}
	
	public String addJSON(LinkedHashMap<String, Object> json){
		BasicDBObject jsonForDB = new BasicDBObject(json);
		curCol.insert(jsonForDB);
		return jsonForDB.getID().toString();
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
		curCol.remove(jsonFromDb);		
		keys = json.keySet();
		for (String key:keys) {
			if (!key.equals("tempId"))
				jsonFromDb.append(key, json.get(key));
		}
		curCol.insert(jsonFromDb);
		return jsonFromDb.getID().toString();
	}
	
	public String removeJSON(String id){
		DBCursor cur = curCol.find();
		while (cur.hasNext()) {
			BasicDBObject obj = (BasicDBObject)cur.next();
			ObjectId objId = (ObjectId)obj.getID();
			if (objId.toString().equals(id)) {
				BasicDBObject toRem = new BasicDBObject();
				toRem.replace("_id", objId);
				curCol.remove(toRem);
				return id;
			}
		}
		return "";
	}
	
	public String getJSONIds() {
		DBCursor cur = curCol.find();
		BasicDBObject obj;
		TreeSet<String> list = new TreeSet<String>();
		String res = "<option value=\"new_record\"> - New record - </option>", temp;
		res += "<option value=\"new_record_string\"> - New record from string - </option>";
		while (cur.hasNext()) {
			obj = (BasicDBObject)cur.next();
			list.add("<option value=\"" + obj.getID() + "\">" + obj.getID() + "</option>");
		}
		Iterator<String> it = list.iterator();
		while (it.hasNext()) {
			temp = it.next();
			res += temp;
		}
		return res;
	}
}
