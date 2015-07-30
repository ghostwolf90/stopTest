
<?php
session_start();
$dbhost = "localhost"; //資料庫位置
$dbname = "laiDb"; //資料庫名稱
$dbuser = "laibit"; //帳戶名稱
$dbpass = "ym2546433"; //帳戶密碼

$un = preg_replace("/[\' \/-;\"]+/", '', $_POST["CITY_NO"]);
$pw = preg_replace("/[\' \/-;\"]+/", '', $_POST["CITY_NAME"]);

//$un = preg_replace("/[\' \/-;\"]+/", '', $_GET["CITY_NO"]);
//$pw = preg_replace("/[\' \/-;\"]+/", '', $_GET["CITY_NAME"]);

function output($success, $Message){
    echo 'InOupt';
    $Status = json_encode(['success' => $success
                          ,'message' => $Message]);
    printf("%s", $Status);
}

//Connect MySql
$conn = mysql_connect($dbhost, $dbuser, $dbpass);

if (!$conn) {
    echo 'No Connect';
    $Error = ['No' => mysql_errno($conn),'Msg' => mysql_error($conn)];
    output("false", $Error);
    exit();
}

mysql_query("SET NAMES UTF8");

//指定資料庫
mysql_select_db($dbname, $conn);
//$sql = sprintf("select * from parking where CITY_NO = '%s' ", $un);
$sql = sprintf("select * from parking ");
//$sql = "select * from test_users where nickname = ? and secret_code = ?"; //MySQL語法
//$results = $conn->prepare("select * from users where username=? and password = ?"); // only pdo or mysqli

//$results->bindParam(1,$un); // Not Class, error
//$results->bindParam(2,$pw); // Not Class, error
//$result = mysql_query($sql) or die('MySQL query error'); not input connect handle

$result = mysql_query($sql, $conn);

if (!$result) {
    print("ABC");
    $Error = ['No' => mysql_errno($conn),'Msg' => mysql_error($conn)];
    output("false", $Error);
    exit();
}

//var_dump($result);

if($result)
{
    //printf("Lai <br>");
    //output("true", "null", $un, $pw);
    header('Content-Type: application/json');
    while($row = mysql_fetch_array($result)){
        //echo json_encode(array('city_no' => $row[0], 'city_name' => $row[1], 'parking_name' => $row[3], 'parking_address' => $row[5]));
        //$return_arr[] = $row;
        $return_arr[] = array('city_no' => $row[0], 'city_name' => $row[1], 'area' => $row[2],'parking_name' => $row[3],
                              'parking_address' => $row[4], 'structure' => $row[5],'lattiude' => $row[6],'longitude' => $row[7],
                              'number_car' => $row[8],'number_moto' => $row[9],'s_hour' => $row[10],'e_hour' => $row[11],
                              'toll_car' => $row[12], 'toll_moto' => $row[13]);

    }
    echo json_encode($return_arr);
}
else{
    printf("Faile");
    error_log("User $username: password doesn't match.");
    $Error = ['error_message' => 'Invalid Username/Password'];
    output("false", $Error);
}

mysql_close($conn)
?>