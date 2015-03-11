'use strict'

angular.module("myvcFrontApp")

.controller('FileManagerCtrl', ['$scope', '$upload', '$timeout', '$filter', 'App', 'RImages', 'Restangular', 'Perfil', '$modal', 'resolved_user', 'GruposServ', ($scope, $upload, $timeout, $filter, App, RImages, Restangular, Perfil, $modal, resolved_user, GruposServ)->
	
	$scope.USER = resolved_user

	fixDato = ()->
		$scope.dato = 
			imgUsuario:
				id:		$scope.USER.imagen_id
				nombre:	$scope.USER.imagen_nombre 
			imgOficial:
				id:		$scope.USER.foto_id
				nombre:	$scope.USER.foto_nombre 

	fixDato()

	$scope.perfilPath = App.images + 'perfil/'
	$scope.imgFiles = []
	$scope.errorMsg = ''
	$scope.fileReaderSupported = window.FileReader != null && (window.FileAPI == null || FileAPI.html5 != false);
	$scope.dato.usuarioElegido = []

	RImages.getList().then((r)->
		$scope.imagenes = r
		$scope.dato.imgParaUsuario = r[0]
	, (r2)->
		console.log 'No se trajeron las imágenes.', r2
	)

	$scope.upload =  (files)->
		$scope.imgFiles = files
		$scope.errorMsg = ''
		console.log 'Entra al upload', files

		if files and files.length

			for i in [0...files.length]
				file = files[i]
				console.log 'file: ', file

				generateThumbAndUpload file


	generateThumbAndUpload = (file)->
		$scope.errorMsg = null
		uploadUsing$upload(file)
		$scope.generateThumb(file)

	$scope.generateThumb = (file)->
		if file != null
			if $scope.fileReaderSupported and file.type.indexOf('image') > -1
				$timeout ()->
					fileReader = new FileReader()
					fileReader.readAsDataURL(file)
					fileReader.onload = (e)->
						$timeout(()->
							file.dataUrl = e.target.result
						)
	
	uploadUsing$upload = (file)->

		if file.size > 10000000
			$scope.errorMsg = 'Archivo excede los 10MB permitidos.'
			return

		$upload.upload({
			url: App.Server + 'myimages/store',
			#fields: {'username': $scope.username},
			file: file
		}).progress( (evt)->
			progressPercentage = parseInt(100.0 * evt.loaded / evt.total)
			file.porcentaje = progressPercentage
			console.log('progress: ' + progressPercentage + '% ' + evt.config.file.name, evt.config)
		).success( (data, status, headers, config)->
			$scope.imagenes.push data
			console.log('Success file ', config.file, '   -uploaded: ', data, status)
		).error((r2)->
			console.log 'Falla uploading: ', r2
		).xhr((xhr)->
			#xhr.upload.addEventListener()
			#/* return $http promise then(). Note that this promise does NOT have progress/abort/xhr functions */
		)#.then((), error, progress)


	$scope.pedirCambioUsuario = (imgUsu)->
		Restangular.one('myimages/cambiarimagenperfil', $scope.USER.user_id).put({imagen_id: imgUsu.id}).then((r)->

			Perfil.setImagen(r.imagen_id, imgUsu.nombre)
			$scope.$emit 'cambianImgs', {image: r}
			$scope.toastr.success 'Imagen principal cambiada'
		, (r2)->
			console.log 'NO Se pedirCambioUsuario: ', r2
			$scope.toastr.error 'No se pudo cambiar imagen', 'Problema'
		)

	$scope.pedirCambioOficial = (imgOfi)->
		Restangular.one('myimages/cambiarimagenoficial', $scope.USER.user_id).put({foto_id: imgOfi.id}).then((r)->

			Perfil.setOficial(r.foto_id, imgOfi.nombre)
			$scope.$emit 'cambianImgs', {foto: r}
			$scope.toastr.success 'Foto oficial cambiada'
		, (r2)->
			console.log 'NO Se pedirCambioOficial: ', r2
			$scope.toastr.error 'No se pudo cambiar foto', 'Problema'
		)

	$scope.imagenSelect = (item, model)->
		console.log 'imagenSelect: ', item, model

	$scope.fotoSelect = (item, model)->
		console.log 'imagenSelect: ', item, model

	$scope.grupoSelect = (item, model)->
		console.log 'grupoSelect: ', item, model

		Restangular.all('grupos/listado/'+item.id).getList().then((r)->
			$scope.alumnos = r
			$scope.dato.alumnoElegido = r[0]
		, (r2)->
			console.log 'No se pudo traer los usuarios'
		)

	$scope.rotarImagen = (imagen)->
		Restangular.one('myimages/rotarimagen', imagen.id).customPUT().then((r)->
			imagen.nombre = ''
			console.log 'Imagen rotada con éxito.'
			$scope.toastr.success 'Imagen rotada'
			imagen.nombre = r + '?' + new Date().getTime()
		, (r2)->
			console.log 'No se pudo rotar la imagen.', r2
			$scope.toastr.error 'Imagen no rotada'
		)



	$scope.borrarImagen = (imagen)->

		modalInstance = $modal.open({
			templateUrl: App.views + 'fileManager/removeImage.tpl.html'
			controller: 'RemoveImageCtrl'
			size: 'sm',
			resolve: 
				imagen: ()->
					imagen
		})
		modalInstance.result.then( (imag)->
			$scope.imagenes = $filter('filter')($scope.imagenes, {id: '!'+imag.id})
			console.log 'Resultado del modal: ', imag
		)


	Restangular.all('perfiles/usuariosall').getList().then((r)->
		$scope.usuariosall = r
		$scope.dato.usuarioElegido = r[0]
	, (r2)->
		console.log 'No se pudo traer los usuarios'
	)



	GruposServ.getGrupos().then((r)->
		$scope.grupos = r
	)

	$scope.cambiarImgUnUsuario = (usuarioElegido, imgParaUsuario)->
		console.log 'Vamos a guardar el cambio de imagen', usuarioElegido, imgParaUsuario
		aEnviar = {
			imgParaUsuario: imgParaUsuario.id
		}
		Restangular.one('perfiles/cambiarimgunusuario', usuarioElegido.user_id).customPUT(aEnviar).then((r)->

			usuarSelect = $filter('filter')($scope.usuariosall, {user_id: usuarioElegido.user_id})
			usuarSelect[0].imagen_id = imgParaUsuario.id
			usuarSelect[0].imagen_nombre = imgParaUsuario.nombre

			$scope.toastr.success 'Imagen asignada con éxito'
			console.log r
		, (r2)->
			console.log 'Error al asignar imagen a usuario', r2
			$scope.toastr.error 'Error al asignar imagen a usuario', 'Problema'
		)

	$scope.usuarioSelect = (item, model)->
		$scope.dato.selectUsuarioModel = item


	$scope.cambiarFotoUnAlumno = (alumnoElegido, imgOficialAlumno)->
		console.log 'Vamos a guardar el cambio de foto', alumnoElegido, imgOficialAlumno
		aEnviar = {
			imgOficialAlumno: imgOficialAlumno.id
		}
		Restangular.one('perfiles/cambiarimgunalumno', alumnoElegido.alumno_id).customPUT(aEnviar).then((r)->

			usuarSelect = $filter('filter')($scope.alumnos, {id: alumnoElegido.id})
			usuarSelect[0].foto_id = imgOficialAlumno.id
			usuarSelect[0].foto_nombre = imgOficialAlumno.nombre

			$scope.toastr.success 'Foto oficial asignada con éxito'
			console.log r
		, (r2)->
			console.log 'Error al asignar foto al alumno', r2
			$scope.toastr.error 'Error al asignar foto al alumno', 'Problema'
		)



	return
])