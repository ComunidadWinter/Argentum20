<?php
	// Le pongo una simple contraseña para evitar cambios innecesarios.
	if (!isset($_GET['password']) || $_GET['password'] !== '8MzsShBUPUTOELQUELEE') {
		die("<strong>Acceso Restringido!<strong>");
	}

	// En esta clase se establecen los filtros para el iterador.
	class MyRecursiveFilterIterator extends RecursiveFilterIterator {

		// Acá podemos evitar que ciertos archivos se listen.
	    public static $EXCLUDE = array(
	        'version.php',
	        'Version.json'
	    );

	    // Aca van las condiciones para la lista.
	    public function accept() {
	        return !in_array($this->current()->getFilename(), self::$EXCLUDE, true);
	    }

	}

	/*
		Escanea los archivos que estan en el directorio actual y, aplicando el filto
		lista los archivos y los guarda en el array `files[numeroDeArchivo]`
	*/
	function listFiles() {
		//Subimos los archivos en el pipeline de test o para prod
		if (isset($_GET['testFiles'])) {
			$subfolder = 'C:\temp-test-re20-cliente-parche';
		} else {
			$subfolder = 'C:\temp-re20-cliente-parche';
		}

		$iterator 	= new RecursiveDirectoryIterator($subfolder);
		$iterator->setFlags(RecursiveDirectoryIterator::SKIP_DOTS);
		
		$filter 	= new MyRecursiveFilterIterator($iterator);
		$all_files  = new RecursiveIteratorIterator($filter, RecursiveIteratorIterator::SELF_FIRST);

		$file = array();
		$folders = array();
		$file_count = 0;
		$folder_count = 0;

		foreach ($all_files as $file) {
			$path_name = $file->getPathname();
			// Hacemos que sea un path relativo.
			$name = substr($path_name, strlen($subfolder));

			// Si empieza con el caracter \ lo borramos.
			while ($name[0] == '\\') {
			  $name = substr($name, 1);
			}

			// Si es un directorio, no lo guardo en el array.
			if (is_dir($path_name)) {
				$folders[$folder_count] = $name;
				$folder_count++;
			}
			else {
				$files[$name] = md5_file($path_name);
				$file_count++;
			}
		}

		$manifest = array(
			'TotalFiles' => $file_count,
			'TotalFolders' => $folder_count
		);

		return array(
			'Manifest' => $manifest,
			'Files' => $files,
			'Folders' => $folders
		);

	}

	// Transformamos el array que nos devuelve la funcion `listfiles()` a JSON
	$output = json_encode(listFiles());
	
	// Guardamos el archivo.
	file_put_contents("Version.json", $output);

	// Mostramos lo que grabamos en el .json
	echo $output;
?>