<html>
  <head>
    <title>PHP version <?= phpversion(); ?></title>
  </head>
  <body>
    <?php
      $limit = rand(1, 10);
      for ($i=0; $i<$limit; $i++){
        echo "<p>[$i -> $limit] Hello, world!</p>";
      }
    ?>
  </body>
</html>
