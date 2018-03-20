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
	
	@GetMapping(value="/col/get/{name}")
	public ResponseEntity<Object> setCollectionMapping(@PathVariable("name") String colName){
		//JSONService.setCurCol(colName);
		return this.getJSONIdsMapping(colName);
	}
	
	@PostMapping(value="/col/add")
	public ResponseEntity<Object> addCollectionMapping(@RequestBody String name){
		JSONService.addCollection(name);
		return new ResponseEntity<Object>( HttpStatus.OK);
	}
	
	@PutMapping(value="/col/upd/{name}")
	public ResponseEntity<Object> updCollectionMapping(@PathVariable("name") String colName, @RequestBody String newName){
		JSONService.updCollection(colName, newName);
		return new ResponseEntity<Object>(HttpStatus.OK);
	}
	
	@DeleteMapping(value="/col/remove/{name}")
	public ResponseEntity<Object> removeCollectionMapping(@PathVariable("name") String colName){
		JSONService.removeCollection(colName);
		return new ResponseEntity<Object>(HttpStatus.OK);
	}
	
	@GetMapping(value="/json/get/{name}/ids")
	public ResponseEntity<Object> getJSONIdsMapping(@PathVariable("name") String colName){
		return new ResponseEntity<Object>(service.getJSONIds(colName), HttpStatus.OK);
	}
	
	@GetMapping(value="/json/get/{name}/{id}")
	public ResponseEntity<Object> getJSONMapping(@PathVariable("name") String colName, @PathVariable("id") String jsonId){
		return new ResponseEntity<Object>(service.getJSON(colName, jsonId).toString(), HttpStatus.OK);
	}
	
	@PostMapping(value="/json/add")
	public ResponseEntity<String> addJSONMapping(@RequestParam("colName") String colName, @RequestBody LinkedHashMap<String, Object> obj){
		return new ResponseEntity<String>(service.addJSON(colName, obj), HttpStatus.OK);
	}
	
	@PutMapping(value="/json/update/{name}/{id}")
	public ResponseEntity<String> updateJSONMapping(@PathVariable("name") String colName, @PathVariable("id") String jsonId, @RequestBody LinkedHashMap<String, Object> obj){
		service.updateJSON(colName, jsonId, obj);
		return new ResponseEntity<String>(jsonId, HttpStatus.OK);
	}
	
	@DeleteMapping(value="/json/remove/{name}/{id}")
	public ResponseEntity<String> removeJSONMapping(@PathVariable("name") String colName, @PathVariable("id") String jsonId){
		service.removeJSON(colName, jsonId);
		return new ResponseEntity<String>(jsonId, HttpStatus.OK);
	}
}
