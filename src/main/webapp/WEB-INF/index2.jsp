<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
		<script type="text/javascript" src="./resources/js/bootstrap.js"></script>
		<script type="text/javascript" src="./resources/js/jsoneditor.js"></script>
		<link rel="stylesheet" type="text/css" href="./resources/css/jsoneditor.css"/>
		<link rel="stylesheet" type="text/css" href="./resources/css/service2.css"/>
		<link rel="stylesheet" type="text/css" href="./resources/css/bootstrap.css"/>
	</head>
	<body>
		<div id="jsoneditor_widget">
			<div id="dbInfoBlock" class="row">
				<div class="col-md-6">
					<select id="chooseCollection" size="5"></select>
					<button id="addCol" onclick="createNewCol()">New</button>
					<button id="delCol" onclick="removeCol()">Remove</button>
				</div>
				<div class="col-md-6">
					<select id="chooseId" size="5"></select>
					<button id="addJSON" onclick="createJSON()">New</button>
					<button id="delJSON" onclick="removeJSONById()">Remove</button>
				</div>
			</div>
			<div id="colNameBlock" class="row">
				<div class="col-md-8">
					<input id="colName" disabled="disabled"/>
				</div>
				<div class="col-md-4">
					<button id="editColName" onclick="editColName(true)">Edit collection name</button>
					<button id="updColName" onclick="saveCol()">Save</button>
					<button id="backColName" onclick="editColName(false)">Cancel</button>
				</div>
			</div>
			<div id="newObjectTypeBlock" class="row">
				<div id="insertTypeRadio" class="col-md-12">
					<div class="col-md-4"></div>
					<div class="col-md-2">
						<input type="radio" name="insertType" value="json" checked="checked"> JSON
					</div>
					<div class="col-md-2">
						<input type="radio" name="insertType" value="string"> String
					</div>
					<div class="col-md-4"></div>
				</div>
			</div>
			<div id="jsonblock" class="row">
				<div id="jsoneditor"></div>
				<textarea id="string_to_json"></textarea>
				<div id="jsonButtons">
					<button id="updJSON" onclick="saveJSON()">Save</button>
					<button id="backJSON" onclick="returnJSON()">Cancel</button>
				</div>
			</div>
		</div>
		<script type="text/javascript">
		
var container = document.getElementById("jsoneditor");
var editor = new JSONEditor(container);
var no_elem_msg = "There is no element in the DB with this id";
var jsonFromDb={};

$("document").ready(function(){
	getCols();
	keepSize();
});

$(window).resize(keepSize);

function keepSize(){
	$("#jsoneditor, #string_to_json").height($("#jsoneditor_widget").height() - ($("#dbInfoBlock").height() + $("#colNameBlock").height() + $("#newObjectTypeBlock").height() + 55));
}

$("#chooseCollection").on("change", getColByName);
$("#chooseId").on("change", getJSONById);
$("input[name=insertType]").on("click",setInsertType)

function editColName(flag){
	if (flag){
		$("#editColName").hide();
		$("#updColName").show();
		$("#backColName").show();
		$("#colName").prop("disabled","");
	} else {
		if (!(typeof $('#chooseCollection option:selected').text() === 'undefined' || $('#chooseCollection option:selected').text()==="")){
			$("#colName").val($("#chooseCollection").val());
		} else {
			$("#colName").val("");
			$("#editColName").prop("disabled","disabled");
		}
		$("#editColName").show();
		$("#updColName").hide();
		$("#backColName").hide();
		$("#colName").prop("disabled","disabled");
	}
}

function setInsertType(){
	var val = $("input[name=insertType]:checked").val();
	if (val === "json"){
		$("#jsoneditor").show();
		$("#string_to_json").hide();
	} else if (val === "string") {
		$("#jsoneditor").hide();
		$("#string_to_json").show();
	}
}

function createNewCol(){
	editColName(true);
	$("#chooseCollection > option").prop("selected","");
	$("#colName").val("");
}

function getCols(){
	$("#editColName, #delCol, #addJSON, #delJSON").prop("disabled","disabled");
	$("#jsonblock").hide();
	$("#chooseId").html("");
	var options = {
		url: "./col/get/names",
		datatype : 'text',
		type : "GET",
		success : function(data) {
			$("#chooseCollection").html(data);
			editColName(false);
		}
	};
	$.ajax(options);
};

function getColByName(){
	editColName(false);
	$("#editColName, #delCol, #addJSON").prop("disabled","");
	var val = $("#chooseCollection").val();
	$("#colName").val(val);
	var options = { 
		url: "./col/get/"+val,
		type : "GET",
		datatype : 'text',
		success : function(data) {
			setIds(data);
		}
	};
	$.ajax(options);
};

function saveCol(){
	if (typeof $('#chooseCollection option:selected').text() === 'undefined' || $('#chooseCollection option:selected').text()===""){
		modifyCol("add");
	} else {
		modifyCol("upd");
	}
}

function modifyCol(url){
	
	var type, msg;
	if (url === "add"){
		type = "POST";
		msg = "created"; 
	} else if (url === "upd") {
		type = "PUT";
		msg = "updated";
	}
	
	var val = $("#colName").val();
	var exist = false;
	$("#chooseCollection option").each(function(){
		if ($(this).val() === val){
			exist = true;
		}
	});
	
	if (exist){
		alert("Collection with this name is already exist");
	} else {
		var options = { 
			url: "./col/" + url,
			type : type,
			contentType: "text/plain",
			data: val,
			success : function() {
				$("#colName").val("");
				alert("Collection \"" + val + "\" have been " + msg);
				getCols();
			}
		};
		$.ajax(options);
	}
}

function removeCol(){
	var val = $("#chooseCollection").val();
	var options = {
		url: "./col/remove",
		type : "DELETE",
		contentType : "text/plain",
		data: val,
		success : function() {
			alert("Collection \""+val+"\" has been removed");
			getCols();
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
			$("#delJSON").prop("disabled","disabled");
			setIds(data);
		}
	};
	$.ajax(options);
};

function setIds(data){
	$("#chooseId").html(data);
	$("#newObjectTypeBlock, #jsonblock").hide();
	editor.set({});
	$("#string_to_json").html("");
	jsonFromDb = {};
};

function getJSONById(){	
	$("#jsonblock, #jsoneditor").show();
	$("#delJSON").prop("disabled","");
	$("#string_to_json, #newObjectTypeBlock").hide();
	var options = {
		url: "./json/get/"+$("#chooseId").val(),
		type : "GET",
		datatype : 'json',
		success : function(data) {
			if (Object.keys(data).length === 0){
				alert(no_elem_msg)
			} else {
				jsonFromDb = data;
				editor.set(jsonFromDb);
			}
		}
	};
	$.ajax(options);
};

function createJSON(){
	$("#newObjectTypeBlock, #jsonblock, #jsoneditor").show();
	$("#string_to_json").hide();
	jsonFromDb = {};
	editor.set({});
	$("#chooseId > option").prop("selected","");
	$("input:radio[name=insertType]").prop("checked",false);
	$("input:radio[name=insertType]")[0].checked=true;
}

function saveJSON(){
	if (typeof $('#chooseId option:selected').text() === 'undefined' || $('#chooseId option:selected').text()===""){
		addJSON();
	} else {
		updateJSON();
	}
}
	        
function addJSON(){
	var type = $("input[name=insertType]:checked").val();
	if ((type === "string" && $("#string_to_json").val() === "") || (type === "json" && JSON.stringify(editor.get())==="{}")){
		alert("Can't add empty object");
		return;
	}
	var json = editor.get();
	delete json._id;
	var data_json;
	if (type === "string"){
		data_json = JSON.stringify($("#string_to_json").val()).split("\\\"").join("\"").split("\\\\").join("\\\\\\").replace("\"","").replace("\"$","");
	} else if (type === "json") {
		data_json = JSON.stringify(json);
	}
	var options = {
		url: "./json/add",
		type : "POST",
		contentType : "application/json",
		data : data_json,
		datatype : 'text',
		success : function(data) {
			alert("Element (id=\""+data+"\") has been added");
			getIds();
		}
	};
	$.ajax(options);	
};

function updateJSON(){	
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
				alert(no_elem_msg);
			} else {
				alert("Element (id=\""+data+"\") has been updated");
				getIds();
			}
		}
	};
	$.ajax(options);
};

function removeJSONById(){	
	var options = {
		url: "./json/remove",
		type : "DELETE",
		contentType : "text/plain",
		data: $("#chooseId").val(),
		datatype : 'text',
		success : function(data) {
			alert("Element (id=\""+data+"\") has been removed");
			getIds();
		}
	};
	$.ajax(options);
};

function returnJSON(){
	editor.set(jsonFromDb);
	$("#newObjectTypeBlock").hide();
	if (JSON.stringify(jsonFromDb) === "{}"){
		$("#jsonblock").hide();
	}
}
		</script>
	</body>
</html>