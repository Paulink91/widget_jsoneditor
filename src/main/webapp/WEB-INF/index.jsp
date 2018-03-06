<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
		<script type="text/javascript" src="./resources/js/jsoneditor.js"></script>
		<link rel="stylesheet" type="text/css" href="./resources/css/jsoneditor.css"/>
		<link rel="stylesheet" type="text/css" href="./resources/css/service.css"/>
	</head>
	<body>
		<div id="jsoneditor_widget">
			<p id="paragraph"> </p>
			<select id="chooseCollection" size="5"></select>
			<div id="addCollection">
				<input id="newCollection"/>
				<br/>
				<button id="addCol" onclick="addCol()">Add collection</button>
			</div>
			<div id="jsonblock">
				<button id="delCollection" onclick="removeCol()">Remove collection</button>
				<br/>
				<select id="chooseId"></select>
				<br/>
				<div id="serviceButtons">
					<button id="updJSON" onclick="updateJSONById()">Update</button>	
					<button id="addJSON" onclick="addJSON()">Add to DB</button>
					<button id="delJSON" onclick="removeJSONById()">Remove</button>
					<button id="strJSON" onclick="getStringifyJSONById()">Get Stringify</button>
				</div>
				<div id="jsoneditor"></div>
				<textarea id="string_to_json"></textarea>
			</div>
		</div>
		<script type="text/javascript">
		
var container = document.getElementById("jsoneditor");
var editor = new JSONEditor(container);
var no_elem_msg = "There is no element in the DB with this id";

$("document").ready(function(){
	getCols();
	$("#addCollection input").width($("#chooseCollection").width()-4);
	$("div#serviceButtons button, #delCollection, #addCol").width(($("div#jsoneditor_widget").width()-79)/3);
	$("#jsoneditor").height($("#jsoneditor_widget").height() - ($("#paragraph").height() + $("#chooseCollection").height() + $("#jsonblock > button").height() + $("#chooseId").height() + $("#serviceButtons").height()+55));
	$("#string_to_json").height($("#jsoneditor_widget").height() - ($("#paragraph").height() + $("#chooseCollection").height() + $("#jsonblock > button").height() + $("#chooseId").height() + $("#serviceButtons").height()+55));
	
});
$("#chooseId").on("change", getJSONById);
$("#chooseCollection").on("change", getColByName);

$(window).resize(function(){
	$("#addCollection input").width($("#chooseCollection").width()-4);
	$("div#serviceButtons button, #delCollection, #addCol").width(($("div#jsoneditor_widget").width()-79)/3);
	$("#jsoneditor").height($("#jsoneditor_widget").height() - ($("#paragraph").height() + $("#chooseCollection").height() + $("#jsonblock > button").height() + $("#chooseId").height() + $("#serviceButtons").height()+55));
	$("#string_to_json").height($("#jsoneditor_widget").height() - ($("#paragraph").height() + $("#chooseCollection").height() + $("#jsonblock > button").height() + $("#chooseId").height() + $("#serviceButtons").height()+55));
});

function getCols(){
	var options = {
		url: "./col/get/names",
		datatype : 'text',
		type : "GET",
		success : function(data) {
			$("#chooseCollection").html(data);
			$("#chooseCollection")[0].value = "new_record";
			$("#addCollection").show();
			$("#jsonblock").hide();
		}
	};
	$.ajax(options);
};

function getColByName(){
	$("#paragraph").text("");
	var val = $("#chooseCollection").val();
	if (val === "new_record"){
		$("#chooseId").html("");
		$("#addCollection").show();
		$("#jsonblock").hide();
	}  else {
		$("#addCollection").hide();
		$("#jsonblock").show();
		var options = { 
			url: "./col/get/"+val,
			type : "GET",
			datatype : 'text',
			success : function(data) {
				setIds(data);
			}
		};
		$.ajax(options);
	}
};

function addCol(){
	var val = $("#newCollection").val();
	var exist = false;
	$("#chooseCollection option").each(function(){
		if ($(this).val() === val){
			exist = true;
		}
	});
	
	if (exist){
		$("#paragraph").text("Collection with this name is already exist");
	} else {
		var options = { 
			url: "./col/add",
			type : "POST",
			contentType: "text/plain",
			data: val,
			success : function() {
				$("#newCollection").val("");
				$("#paragraph").text("Collection \"" + val + "\" have been created");
				getCols();
				$("#chooseId")[0].value = "new_record";
			}
		};
		$.ajax(options);
	}
}

function removeCol(){
	var options = {
		url: "./col/remove",
		type : "DELETE",
		contentType : "text/plain",
		data: $("#chooseCollection").val(),
		datatype : 'text',
		success : function(data) {
			$("#paragraph").text("Collection \""+data+"\" has been removed");
			getCols();
			editor.set({});
		}
	};
	$.ajax(options);
}

function getIds(){
	var options = {
		url: "./json/get/ids",
		type : "GET",
		datatype : 'text',
		success : function(data) {
			setIds(data);
		}
	};
	$.ajax(options);
};

function setIds(data){
	$("#updJSON, #delJSON").hide();
	$("#chooseId").html(data);
	$("#chooseId")[0].value = "new_record";
	editor.set({});
	
};
	        
function addJSON(){
	if (($("#chooseId").val() === "new_record_string" && $("#string_to_json").val() === "") || ($("#chooseId").val() !== "new_record_string" && JSON.stringify(editor.get())==="{}")){
		$("#paragraph").text("Can't add empty object");
		return;
	}
	var json = editor.get();
	$("#paragraph").text("");
	delete json._id;
	var data_json;
	if ($("#chooseId").val() === "new_record_string"){
		data_json = JSON.stringify($("#string_to_json").val()).split("\\\"").join("\"").split("\\\\").join("\\\\\\").replace("\"","").replace("\"$","");
	} else {
		data_json = JSON.stringify(json);
	}
	var options = {
		url: "./json/add",
		type : "POST",
		contentType : "application/json",
		data : data_json,
		datatype : 'text',
		success : function(data) {
			$("#paragraph").text("Element (id=\""+data+"\") has been added");
			$("#jsoneditor").show();
			$("#string_to_json").hide();
			$("#string_to_json").val("");
			getIds();
		}
	};
	$.ajax(options);	
};

function getJSONById(){	
	$("#paragraph").text("");
	if ($("#chooseId").val() === "new_record"){
		editor.set({});	
		$("#jsoneditor").show();
		$("#string_to_json").hide();
		$("#updJSON, #delJSON").hide();
	} else if ($("#chooseId").val() === "new_record_string") {
		$("#jsoneditor").hide();
		$("#string_to_json").show();
		$("#updJSON, #delJSON").hide();
	} else {
		$("#jsoneditor").show();
		$("#string_to_json").hide();
		$("#updJSON, #delJSON").show();
		var options = {
			url: "./json/get/"+$("#chooseId").val(),
			type : "GET",
			datatype : 'json',
			success : function(data) {
				if (Object.keys(data).length === 0){
					$("#paragraph").text(no_elem_msg);
				} else {
					editor.set(data);
				}
			}
		};
		$.ajax(options);
	}
};

function updateJSONById(){	
	if ($("#chooseId").val() === "new_record" || $("#chooseId").val() === "new_record_string"){
		$("#paragraph").text("Please choose a record to update");
	} else {
		var json = editor.get();
		delete json._id;
		json._id_temp =  $("#chooseId").val();
		var options = {
			url: "./json/update",
			type : "PUT",
			contentType : "application/json",
			data: JSON.stringify(json),
			datatype : 'text',
			success : function(data) {
				if (data===""){
					$("#paragraph").text(no_elem_msg);
				} else {
					$("#paragraph").text("Element (id=\""+data+"\") has been updated");
					getIds();
					editor.set({});
				}
			}
		};
		$.ajax(options);
	}
};

function removeJSONById(){	
	if ($("#chooseId").val() === "new_record" || $("#chooseId").val() === "new_record_string"){
		$("#paragraph").text("Please choose a record to remove");
	} else {
		var options = {
			url: "./json/remove",
			type : "DELETE",
			contentType : "text/plain",
			data: $("#chooseId").val(),
			datatype : 'text',
			success : function(data) {
				console.log(data);
				$("#paragraph").text("Element (id=\""+data+"\") has been removed");
				getIds();
				editor.set({});
			}
		};
		$.ajax(options);
	}
};

function getStringifyJSONById(){
	if (($("#chooseId").val() === "new_record_string" && $("#string_to_json").val() === "") || ($("#chooseId").val() !== "new_record_string" && JSON.stringify(editor.get())==="{}")){
		$("#paragraph").text("Can't add empty object");
		return;
	}
	var json = editor.get();
	$("#paragraph").text("");
	delete json._id;
	var data_json;
	if ($("#chooseId").val() === "new_record_string"){
		data_json = JSON.stringify($("#string_to_json").val()).split("\\\"").join("\"").split("\\\\\"").join("\\\\\\\"").replace("\"","").replace("\"$","");
	} else {
		data_json = JSON.stringify(json);
	}
	var options = {
		url: "./json/stringify",
		type : "POST",
		contentType : "text/plain",
		data : data_json,
		datatype : 'text',
		success : function(data) {
			$("#jsoneditor").show();
			$("#string_to_json").hide();
			$("#string_to_json").val("");
			getIds();
		}
	};
	$.ajax(options);	
};
		</script>
	</body>
</html>