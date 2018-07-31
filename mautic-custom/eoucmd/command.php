<?php
/**
 * Executa um comando e faz um post com o retorno
**/

require "vendor/autoload.php";

use mikehaertl\shellcommand\Command;

if (!(isset($argv[1]))):
  die("nenhum argumento informado.");
endif;

$opcao = $argv[1];

switch ($opcao) {

    case "segments:update":
      $path = "php /var/www/html/app/console mautic:segments:update";
      break;

    case "campaigns:rebuild":
      $path = "php /var/www/html/app/console mautic:campaigns:rebuild";
      break;

    case "campaigns:trigger":
      $path = "php /var/www/html/app/console mautic:campaigns:trigger";
      break;

    case "emails:send":
      $path = "php /var/www/html/app/console mautic:emails:send";
      break;

    case "broadcasts:send":
      $path = "php /var/www/html/app/console mautic:broadcasts:send";
      break;

    default:
      die("nenhum argumento informado.");
}

$command = new Command($path);

$inicio = date("Y-m-d h:m:s");

$command->execute();

$fim = date("Y-m-d h:m:s");

$out["stdout"] = $command->getOutput();
$out["stderr"] = $command->getError();
$out["exitcode"] = $command->getExitCode();
$out["completed"] = $command->getExecuted();
$out["start"] = $inicio;
$out["end"] = $fim;
$out["command"] = $command->getCommand();

$ch = curl_init('http://requestbin.fullcontact.com/1dtgdwl1');

curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);

curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($out) );

curl_exec($ch);

curl_close($ch);

//echo $command->getError();

//echo $command->getOutput();

echo json_encode($out);

?>
