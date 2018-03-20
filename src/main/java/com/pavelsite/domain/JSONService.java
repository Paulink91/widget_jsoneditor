package com.pavelsite.domain;

import java.util.*;

import com.ibm.nosql.bson.types.ObjectId;
import com.ibm.nosql.json.api.*;

public class JSONService{
	
	private static JSONService service;
	private static DB db;
	private static TreeSet<String> cols;
	
	private JSONService(){
		JSONService.service = this;
	}
	
	public static JSONService getService(){
		if (JSONService.service==null)
			return new JSONService();
		else
			return JSONService.service;
	}
	
	public static boolean checkDatabase() {
		if (JSONService.db == null) return false;
		return true;
	}
	
	public static void setDatabase(String host, String port, String database, String user, String pass) {
		
		String databaseUrl = "jdbc:db2://" + host + ":" + port + "/" + database;		 
		JSONService.db = NoSQLClient.getDB (databaseUrl, user, pass);
		JSONService.cols = new TreeSet<String>(JSONService.db.getCollectionNames());
	}
	
	public String getCollectionNames() {
		JSONService.cols = new TreeSet<String>(JSONService.db.getCollectionNames());
		String res = "";
		for (String col:cols) {
			res += "<option value=\"" + col + "\">" + col + "</option>";
		}
		return res;
	}
	
	public static void addCollection(String colName) {
		db.createCollection(colName, new BasicDBObject());
	}
	
	public static void updCollection(String oldName, String newName) {
		db.getCollection(oldName).rename(newName);
	}
	
	public static void removeCollection(String colName) {
		db.getCollection(colName).drop();
	}
	
	public String getJSONIds(String colName) {
		DBCursor cur = db.getCollection(colName).find();
		BasicDBObject obj;
		TreeSet<String> list = new TreeSet<String>();
		String res = "", temp;
		res += "";
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
	
	public String addJSON(String colName, LinkedHashMap<String, Object> json){
		BasicDBObject jsonForDB = new BasicDBObject(json);
		db.getCollection(colName).save(jsonForDB);
		return jsonForDB.getID().toString();
	}
	
	public BasicDBObject getJSON(String colName, String jsonId){
		return (BasicDBObject)db.getCollection(colName).findOne(new ObjectId(jsonId));
	}
	
	public void updateJSON(String colName, String jsonId, LinkedHashMap<String, Object> json){
		BasicDBObject jsonForDB = new BasicDBObject(json);
		jsonForDB.put("_id", new ObjectId(jsonId));
		db.getCollection(colName).save(jsonForDB);
	}
	
	public void removeJSON(String colName, String jsonId){
		db.getCollection(colName).remove(new BasicDBObject().append("_id", new ObjectId(jsonId)));
	}
}
