<form method="post" action="<?php echo $_SERVER['PHP_SELF']; ?>">

Red (0–255):
<input type="range" name="slider1" min="0" max="255" value="0"
oninput="this.nextElementSibling.value=this.value"><output>0</output><br>

Green (0–255):
<input type="range" name="slider2" min="0" max="255" value="0"
oninput="this.nextElementSibling.value=this.value"><output>0</output><br>

Blue (0–255):
<input type="range" name="slider3" min="0" max="255" value="0"
oninput="this.nextElementSibling.value=this.value"><output>0</output><br>

Power:
<label><input type="radio" name="on" value="1" checked> On</label>
<label><input type="radio" name="on" value="0"> Off</label><br>

<input type="submit" value="Submit">
</form>

<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $r = isset($_POST["slider1"]) ? (int)$_POST["slider1"] : 0;
    $g = isset($_POST["slider2"]) ? (int)$_POST["slider2"] : 0;
    $b = isset($_POST["slider3"]) ? (int)$_POST["slider3"] : 0;
    $on = isset($_POST["on"]) ? ($_POST["on"] == "1") : true;

    echo "On: " . ($on ? "true" : "false") . "<br>";
    echo "Red: $r<br>Green: $g<br>Blue: $b<br>";

    $data = array("Node1" => array("On"=>$on, "Red"=>$r, "Green"=>$g, "Blue"=>$b));
    $json = json_encode($data);

    $f = fopen("results2.txt", "w") or die("Can't open file!");
    fwrite($f, $json);
    fclose($f);
}
?>
