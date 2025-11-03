<!DOCTYPE html>
<html>
<head>
  <title>IoT Course</title>
</head>
<body>

<h1 style="color:green;">EE470 IoT assignment3pt2A</h1>
<h4>Used to turn an LED on or off</h4></h4>

<form method="post" action="<?php echo $_SERVER['PHP_SELF']; ?>">
  Click to turn ON:
  <input type="submit" name="fname" value="on">
  <p></p>
  Click to turn OFF:
  <input type="submit" name="fname" value="off">
</form>

<?php
// -- Using PHP Script: passing 'fname' via POST_METHOD --
$var1 = "";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $var1 = $_POST["fname"];
    if (empty($var1)) {
        $var1 = "";
    } else {
        echo "Last time you clicked was: $var1";
    }

    $myfile = fopen("results.txt", "w") or die("Unable to open file!");
    fwrite($myfile, $var1);
    fclose($myfile);
}
?>

</body>
</html>
