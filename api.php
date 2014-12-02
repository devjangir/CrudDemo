<?php
$db = mysql_connect("localhost","root","") or die("error occured");
mysql_select_db("crud",$db) or die("DB selection error");
/*
update the user 
@ param id,name
*/
if(isset($_POST['ws_type']) &&  $_POST['ws_type'] == 'update'){
		$sql = "update users set name='".$_POST['name']."' where id=".$_POST['id'];
		$query = mysql_query($sql);

		header('Content-type: application/json');
		echo json_encode(array("status"=>'YES'));
		die;
}

/*
delete the user 
@ param id
*/
if(isset($_POST['ws_type']) &&  $_POST['ws_type'] == 'delete'){
		$sql = "delete from users where id=".$_POST['id'];
		$query = mysql_query($sql);
		header('Content-type: application/json');
		echo json_encode(array("status"=>'YES'));
		die;
 }

 /*
update the user 
@ param id,name
*/
 if(isset($_POST['ws_type']) &&  $_POST['ws_type'] == 'create'){
		$sql = "insert into users set `name`='".$_POST['name']."'";
		$query = mysql_query($sql);
		$id = mysql_insert_id();
		header('Content-type: application/json');
		echo json_encode(array("id"=>$id));
		die;
 }

 /*
update the user 
@ param id,name
*/
 if(isset($_POST['ws_type']) &&  $_POST['ws_type'] == 'list'){
		$sql = "select  * from  users";
		$query = mysql_query($sql);
		$result = array();
		while($record=mysql_fetch_array($query)) {
			$result[] = array("id"=>$record['id'],"name"=>$record['name']);
		}
		header('Content-type: application/json');
		echo json_encode($result);
		die;
 } 
?>