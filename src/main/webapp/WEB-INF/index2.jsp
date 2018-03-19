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
				<div id="collectionBlock" class="col-md-6">
					<select id="chooseCollection" size="5"></select>
					<button id="addCol" class="btn-primary col-md-12" onclick="createNewCol()">New</button>
					<button id="delCol" class="btn-danger" onclick="removeCol()" style="display: none;">Remove</button>
				</div>
				<div id="jsonBlock" class="col-md-6">
					<input id="jsonIdSearcher" class="col-md-10"/><button class="col-md-2 btn-primary" onclick="setJSONId()">Get</button>
					<select id="chooseId" size="4"></select>
					<button id="addJSON" class="btn-primary col-md-6" onclick="createJSON()">New</button><button id="delJSON" class="btn-danger col-md-6" onclick="removeJSONById()">Remove</button>
				</div>
			</div>
			<div id="colNameBlock" class="row">
				<div class="col-md-8">
					<input id="colName" disabled="disabled"/>
				</div>
				<div class="col-md-4">
					<button id="editColName" class="btn-primary col-md-12" onclick="editColName(true)">Edit collection name</button>
					<button id="updColName" class="btn-success col-md-6" onclick="saveCol()">Save</button><button id="backColName" class="btn-danger col-md-6" onclick="editColName(false)">Cancel</button>
				</div>
			</div>
			<div id="newObjectTypeBlock" class="row">
				<div id="insertTypeRadio" class="col-md-12">
					<div class="col-md-4"></div>
					<div class="col-md-2">
						<input type="radio" name="insertType" value="json" checked="checked"><span> JSON </span>
					</div>
					<div class="col-md-2">
						<input type="radio" name="insertType" value="string"><span> String </span>
					</div>
					<div class="col-md-4"></div>
				</div>
			</div>
			<div id="jsonblock" class="row">
				<div id="jsoneditor" class="row">
					<div id="jsonTemplateBlock" class="col-md-12 row">
						<div class="col-md-2">
							<label>Choose template:</label>
						</div>
						<div class="col-md-10">
							<select id="jsonTemplate">
								<option value="0">Empty</option>
								<option value="1">Template 1</option>
							</select>
						</div>
					</div>
					<div id="json_to_json"></div>
				</div>
				<div id="stringeditor" class="row">
					<div id="StringTemplateBlock" class="col-md-12 row">
						<div class="col-md-2">
							<label>Choose template:</label>
						</div>
						<div class="col-md-10">
							<select id="stringTemplate">
								<option value="0">Empty</option>
								<option value="1">Checklist</option>
							</select>
						</div>
					</div>
					<div id="string_to_json_name" class="col-md-12 row">
						<div class="col-md-2">
							<label>Choose name for new element:</label>
						</div>
						<div class="col-md-10">
							<select id="nameForString">
								<option value="test">test</option>
							</select>
						</div>
					</div>
					<textarea id="string_to_json"></textarea>
				</div>
				<div id="jsonButtons">
					<button id="updJSON" class="btn-success col-md-6" onclick="saveJSON()">Save</button><button id="backJSON" class="btn-danger col-md-6" onclick="returnJSON()">Cancel</button>
				</div>
			</div>
		</div>
		<script type="text/javascript">
		
var container = document.getElementById("json_to_json");
var editor = new JSONEditor(container);
var no_elem_msg = "There is no element in the DB with this id";
var jsonFromDb={};
var templates=[{}, {"templateVersion":1,"array":["test"]}];
var startSize;
var height;

$("document").ready(function(){
	getCols("");
	deselectCol();
	keepSize();
});

$(window).resize(keepSize);

function keepSize(){
	height = $("#jsoneditor_widget").height() - ($("#dbInfoBlock").height() + $("#colNameBlock").height() + $("#newObjectTypeBlock").height() + 55);
	$("#jsoneditor, #stringeditor").height(height);
	startSize = $("#stringeditor").height() - $("#stringTemplate").height() - 15;
	$("#string_to_json").height(startSize);
	if ($("#jsonTemplateBlock").css("display") == "none" ) {
		$("#json_to_json").height(startSize);
	} else {
		$("#json_to_json").height(startSize - $("#jsonTemplateBlock").height());
	}
	if ($("#string_to_json_name").css("display") == "none" ) {
		$("#string_to_json").height(startSize);
	} else {
		$("#string_to_json").height(startSize - $("#string_to_json_name").height());
	}
}

$("#chooseCollection").on("change", getColByName);
$("#chooseId").on("change", getJSONById);
$("#jsonTemplate").on("change", getJSONTemplate);
$("#stringTemplate").on("change", function(){
	if ($(this).val() == 0){
		$("#string_to_json_name").hide();		
	} else {
		$("#string_to_json_name").val("");
		$("#string_to_json_name").show();
	}
	keepSize();
});
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
		$("#stringeditor").hide();
		$("#jsonTemplate").val("0");
		editor.set({});
	} else if (val === "string") {
		$("#jsoneditor").hide();
		$("#stringeditor").show();
		$("#string_to_json_name").hide();
		$("#stringTemplate").val("0");
		$("#string_to_json").val("");
	}
}

$("#insertTypeRadio > div > span").on("click",function(){
	$("#insertTypeRadio input:radio").prop("checked",false);
	$(this).prev()[0].checked=true;
	setInsertType();
})

function createNewCol(){
	editColName(true);
	$("#chooseCollection > option").prop("selected","");
	deselectCol();
	$("#colName").focus();
}

function selectCol(){
	$("#editColName, #delCol, #addJSON").prop("disabled","");
	$("#jsonBlock").show();
	deselectJSON();
}

function deselectCol(){
	$("#editColName, #delCol, #addJSON, #delJSON").prop("disabled","disabled");
	$("#jsonblock, #newObjectTypeBlock").hide();
	$("#chooseId").html("");
	$("#colName").val("");
	$("#jsonBlock").hide();
	deselectJSON();
}

function getCols(name){
	var options = {
		url: "./col/names",
		datatype : 'text',
		type : "GET",
		success : function(data) {
			deselectCol();
			$("#chooseCollection").html(data);
			editColName(false);
			if (name !== ""){
				$("#chooseCollection").val(name);
				getColByName();
				selectCol();
			}
		}
	};
	$.ajax(options);
};

function getColByName(){
	editColName(false);
	var val = $("#chooseCollection").val();
	$("#colName").val(val);
	var options = { 
		url: "./col/get/"+val,
		type : "GET",
		datatype : 'text',
		success : function(data) {
			setIds(data);
			selectCol();
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
				getCols(val);
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
			editColName(false);
			deselectCol();
			$("#chooseCollection option:selected").remove();
		}
	};
	$.ajax(options);
}

function createJSON(){
	deselectJSON();
	$("#newObjectTypeBlock, #jsonblock, #jsoneditor").show();
	$("#jsonTemplateBlock").show();
	$("#stringeditor").hide();
	$("#chooseId > option").prop("selected","");
	$("input:radio[name=insertType]").prop("checked",false);
	$("input:radio[name=insertType]")[0].checked=true;
	editor.set(templates[0]);
	keepSize();
	$("#json_to_json").height(startSize - $("#jsonTemplateBlock").height() );
}

function selectJSON(){
	$("#jsonblock, #jsoneditor").show();
	$("#delJSON").prop("disabled","");
	$("#stringeditor, #newObjectTypeBlock").hide();
	$("#jsonTemplateBlock").hide();
	keepSize();
}

function deselectJSON(){
	$("#delJSON").prop("disabled","disabled");
	$("#newObjectTypeBlock, #jsonblock").hide();
	editor.set({});
	$("#string_to_json").val("");
	jsonFromDb = {};
}

function getIds(id){
	var options = {
		url: "./json/get/ids",
		type : "GET",
		datatype : 'text',
		success : function(data) {
			deselectJSON();
			$("#delJSON").prop("disabled","disabled");
			setIds(data);
			if (id !== ""){
				selectJSON();
				$("#chooseId").val(id);
				getJSONById();
			}
		}
	};
	$.ajax(options);
};

function setIds(data){
	$("#chooseId").html(data);
};

function getJSONById(){	
	var options = {
		url: "./json/get/"+$("#chooseId").val(),
		type : "GET",
		datatype : 'json',
		success : function(data) {
			selectJSON();
			if (Object.keys(data).length === 0){
				alert(no_elem_msg)
			} else {
				editor.set(JSON.parse(data));
			}
		}
	};
	$.ajax(options);
};

function setJSONId(){
	if ($("#chooseId > option[value=" + $("#jsonIdSearcher").val() + "]").length){
		$("#chooseId").val($("#jsonIdSearcher").val());
		getJSONById();
	} else {
		alert("Object with ID you entered doesn't exist");	
	}
}

function getJSONTemplate(){
	editor.set(templates[$(this).val()]);
};

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
		data_json = JSON.stringify($("#string_to_json").val()).split("\\\"").join("\"").split("\\\\").join("\\\\\\");
		data_json = data_json.substring(1,data_json.length-1);
		if ($("#stringTemplate").val() == 1){
			data_json = "{\"name\":\"" + $("#nameForString").val() + "\",\"content\":" + data_json + "}";
		}
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
			getIds(data);
		}
	};
	$.ajax(options);	
};

function updateJSON(){	
	var json = editor.get();
	jsonFromDb = editor.get();
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
			deselectJSON();
			$("#chooseId option:selected").remove();
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