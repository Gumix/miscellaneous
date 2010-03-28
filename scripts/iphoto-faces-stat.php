<?php

    $width  = 1200;
    $height = 1600;

    $username = exec('whoami');
    $face_db  = "/Users/$username/Pictures/iPhoto Library.photolibrary/Database/apdb/Faces.db";

    header("Content-type: image/svg+xml");
    echo '<?xml version="1.0" encoding="utf-8" standalone="no"?>' . "\n";
    echo '<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.0//EN" "http://www.w3.org/TR/SVG/DTD/svg10.dtd">' . "\n";
    echo '<svg width="' . $width . 'px" height="' . $height . 'px" xmlns="http://www.w3.org/2000/svg">' . "\n";
    echo '<desc>iPhoto faces statistics</desc>' . "\n";

    $db = new SQLite3($face_db, SQLITE3_OPEN_READONLY);

    $result = $db->query('SELECT RKFaceName.name AS name, COUNT(*) AS count
                          FROM RKFaceName, RKDetectedFace
                          WHERE RKFaceName.faceKey = RKDetectedFace.faceKey
                          GROUP BY RKFaceName.faceKey
                          ORDER BY 2 DESC');

    while ($row = $result->fetchArray())
    {
        $name  = $row['name'];
        $count = $row['count'];
        $arr[$name] = $count;
    }
    $db->close();

    $max_width = current($arr);
    $y = 20;

    foreach ($arr as $name => $count)
    {
        $w = round($count / $max_width * ($width-300));

        $red   = 100 + round(rand(0, 155));
        $green = 255 - $red + round(rand(0, 100));
        $blue  = 255 - $red + round(rand(0, 100));
        $color = "rgb($red,$green,$blue)";

        echo '<text x="10" y="' . $y . '" style="font-family:verdana; font-size:15;">' . "$name</text>\n";
        echo '<rect x="190" y="' . ($y-12) . '" width="' . $w . '" height="15" style="fill:' . $color . ';"/>' . "\n";
        echo '<text x="' . ($w+200) . '" y="' . $y . '" style="font-family:verdana; font-size:15;">' . "$count</text>\n";

        $y += 20;
        if ($y >= $height) break;
    }

    echo '</svg>';

?>
