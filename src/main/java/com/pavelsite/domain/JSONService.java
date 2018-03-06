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
		JSONService.curCol = db.getCollection(cols.first());
	}
	
	public String getCollectionNames() {
		JSONService.cols = new TreeSet<String>(JSONService.db.getCollectionNames());
		String res = "";
		for (String col:cols) {
			res += "<option value=\"" + col + "\">" + col + "</option>";
		}
		return res;
	}
	
	public static void addCollection(String name) {
		db.createCollection(name, new BasicDBObject());
	}
	
	public static void updCollection(String name) {
		curCol.rename(name);
	}
	
	public static void setCurCol(String name) {
		JSONService.curCol = JSONService.db.getCollection(name);
	}
	
	public static void removeCollection(String name) {
		db.getCollection(name).drop();
	}
	
	public String getJSONIds() {
		DBCursor cur = curCol.find();
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
	
	public String addJSON(LinkedHashMap<String, Object> json){
		BasicDBObject jsonForDB = new BasicDBObject(json);
		curCol.insert(jsonForDB);
		return jsonForDB.getID().toString();
	}
	
	public BasicDBObject getJSON(String id){
		return (BasicDBObject)curCol.findOne(new ObjectId(id));
	}
	
	public void updateJSON(String id, LinkedHashMap<String, Object> json){
		curCol.update(new BasicDBObject().append("_id", new ObjectId(id)), new BasicDBObject(json));
	}
	
	public void removeJSON(String id){
		curCol.remove(new BasicDBObject().append("_id", new ObjectId(id)));
	}
}
