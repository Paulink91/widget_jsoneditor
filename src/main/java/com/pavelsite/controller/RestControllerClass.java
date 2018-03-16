package com.pavelsite.controller;

import java.util.*;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.pavelsite.domain.JSONService;

@RestController
public class RestControllerClass {
	
	private static JSONService service = JSONService.getService();
	
	@GetMapping(value="/col/names")
	public ResponseEntity<Object> getCollectionNamesMapping(){
		return new ResponseEntity<Object>(service.getCollectionNames(), HttpStatus.OK);
	}
	
	@GetMapping(value="/col/get/{id}")
	public ResponseEntity<Object> setCollectionMapping(@PathVariable("id") String colName){
		JSONService.setCurCol(colName);
		return this.getJSONIdsMapping();
	}
	
	@PostMapping(value="/col/add")
	public ResponseEntity<Object> addCollectionMapping(@RequestBody String name){
		JSONService.addCollection(name);
		return new ResponseEntity<Object>( HttpStatus.OK);
	}
	
	@PutMapping(value="/col/upd")
	public ResponseEntity<Object> updCollectionMapping(@RequestBody String name){
		JSONService.updCollection(name);
		return new ResponseEntity<Object>(HttpStatus.OK);
	}
	
	@DeleteMapping(value="/col/remove")
	public ResponseEntity<Object> removeCollectionMapping(@RequestBody String name){
		JSONService.removeCollection(name);
		return new ResponseEntity<Object>(HttpStatus.OK);
	}
	
	@GetMapping(value="/json/get/ids")
	public ResponseEntity<Object> getJSONIdsMapping(){
		return new ResponseEntity<Object>(service.getJSONIds(), HttpStatus.OK);
	}
	
	@GetMapping(value="/json/get/{id}")
	public ResponseEntity<Object> getJSONMapping(@PathVariable("id") String jsonId){
		return new ResponseEntity<Object>(service.getJSON(jsonId).toString(), HttpStatus.OK);
	}
	
	@PostMapping(value="/json/add")
	public ResponseEntity<String> addJSONMapping(@RequestBody LinkedHashMap<String, Object> obj){
		if (obj == null || obj.isEmpty())
			return new ResponseEntity<String>("Object is empty", HttpStatus.OK);
		return new ResponseEntity<String>(service.addJSON(obj), HttpStatus.OK);
	}
	
	@PostMapping(value="/json/stringify",produces = "text/html; charset=ISO-8859-1")
	public ResponseEntity<String> getStringifyMapping(@RequestBody String obj){
		if (obj == null || obj.isEmpty())
			return new ResponseEntity<String>("Object is empty", HttpStatus.OK);
		return new ResponseEntity<String>(HttpStatus.OK);
	}
	
	@PutMapping(value="/json/update")
	public ResponseEntity<String> updateJSONMapping(@RequestBody LinkedHashMap<String, Object> obj){
		String id = obj.get("_id_temp").toString();
		obj.remove("_id_temp");		
		service.updateJSON(id, obj);
		return new ResponseEntity<String>(id, HttpStatus.OK);
	}
	
	@DeleteMapping(value="/json/remove")
	public ResponseEntity<String> removeJSONMapping(@RequestBody String jsonId){
		service.removeJSON(jsonId);
		return new ResponseEntity<String>(jsonId, HttpStatus.OK);
	}
}
