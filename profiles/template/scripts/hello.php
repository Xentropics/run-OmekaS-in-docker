<?php
echo "<h1>Hello, world!</h1>";
if (isset($_GET['action_par'])) {
    echo "<p>Action: " . $_GET['action_par'] . "!</p>";
}