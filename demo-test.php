<?php
header("Content-Type: application/json");

$array_json = array("show", "me", "the", "money");

$dict_json = array(
    "show" => "me", 
    "the" => "money"
);

$mix_json = array(
    "show" => "me", 
    "the" => array("money")
);

$type = $_GET['type'];

$result = array();

if ($type == 'array') {
    $result = $array_json;
} else if ($type == 'dict') {
    $result = $dict_json;
} else if ($type == 'mix') {
    $result = $mix_json;
}

echo json_encode($result);