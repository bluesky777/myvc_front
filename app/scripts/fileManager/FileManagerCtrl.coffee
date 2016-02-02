'use strict'

angular.module("myvcFrontApp")

.controller('FileManagerCtrl', ['$scope', '$upload', '$timeout', '$filter', 'App', 'Restangular', 'Perfil', '$modal', 'resolved_user', 'GruposServ', ($scope, $upload, $timeout, $filter, App, Restangular, Perfil, $modal, resolved_user, GruposServ)->
	
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

	Restangular.one('myimages').customGET().then((r)->
		$scope.imagenes_privadas = r.imagenes_privadas
		$scope.imagenes_publicas = r.imagenes_publicas
		$scope.dato.imgParaUsuario = r.imagenes_privadas[0]
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

			if r.asked_by_user_id
				$scope.toastr.info 'Pedido realizado, espera respuesta.'
			else if r == 'En espera'
				$scope.toastr.info 'Espera respuesta.'
			else
				Perfil.setOficial(r.foto_id, imgOfi.nombre)
				$scope.$emit 'cambianImgs', {foto: r}
				$scope.toastr.success 'Foto oficial cambiada'
		, (r2)->
			console.log 'NO Se pedirCambioOficial: ', r2
			$scope.toastr.error 'No se pudo cambiar foto', 'Problema'
		)

	$scope.cambiarLogoColegio = (imgLogo)->
		Restangular.one('myimages/cambiarlogocolegio').put({logo_id: imgLogo.id}).then((r)->

			#$scope.$emit 'cambianImgs', {foto: r}
			$scope.toastr.success 'Logo del colegio cambiado'
		, (r2)->
			console.log 'No se cambió logo: ', r2
			$scope.toastr.error 'No se pudo cambiar el logo', 'Problema'
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


	$scope.publicarImagen = (imagen)->
		Restangular.one('myimages/publicar-imagen', imagen.id).customPUT().then((r)->
			console.log 'Ahora la imagen es pública.'
			$scope.toastr.info 'Ahora la imagen es pública'

			$scope.imagenes_privadas = $filter('filter')($scope.imagenes_privadas, {id: '!'+imagen.id})
			$scope.imagenes_publicas.push imagen

		, (r2)->
			console.log 'No se pudo publicar la imagen.', r2
			$scope.toastr.error 'Imagen no publicada'
		)


	$scope.privatizarImagen = (imagen)->
		Restangular.one('myimages/privatizar-imagen', imagen.id).customPUT().then((r)->
			
			if r.imagen 
				$scope.toastr.warning 'No puede ser logo del año ' + r.imagen.is_logo_of_year
				return

			console.log 'Ahora la imagen es privada.'
			$scope.toastr.info 'Ahora la imagen es privada'

			if imagen.user_id == $scope.USER.id
				$scope.imagenes_privadas.push imagen
			
			$scope.imagenes_publicas = $filter('filter')($scope.imagenes_publicas, {id: '!'+imagen.id})

		, (r2)->
			console.log 'No se pudo privatizar la imagen.', r2
			$scope.toastr.error 'Imagen no privatizada'
		)



	$scope.borrarImagen = (imagen)->

		modalInstance = $modal.open({
			templateUrl: App.views + 'fileManager/removeImage.tpl.html'
			controller: 'RemoveImageCtrl'
			size: 'sm',
			resolve: 
				imagen: ()->
					imagen
				user_id: ()->
					$scope.USER.id
				datos_imagen: ()->

					codigos = 
						imagen_id: imagen.id
						user_id: $scope.USER.id

					Restangular.one('myimages/datos-imagen').customGET('', codigos).then((r)->
						console.log 'Datos imagen traidos.', r
						return $scope.datos_imagen = r
					, (r2)->
						console.log 'No se pudo traer datos de imagen.', r2
						$scope.toastr.error 'Error al traer datos de imagen', 'Problema'
						return {}
					)

		})
		modalInstance.result.then( (imag)->
			$scope.imagenes = $filter('filter')($scope.imagenes, {id: '!'+imag.id})
			console.log 'Resultado del modal: ', imag
		)


	Restangular.all('perfiles/usuariosall').getList().then((r)->
		$scope.usuariosall = r
		$scope.usuariosprofes = $filter('filter')(r, {tipo: 'Profesor'}, true)
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

	

	$scope.cambiarFotoUnProfe = (profeElegido, imgOficialProfe)->
		console.log 'Vamos a guardar el cambio de foto', profeElegido, imgOficialProfe
		aEnviar = {
			imgOficialProfe: imgOficialProfe.id
		}
		Restangular.one('perfiles/cambiarimgunprofe', profeElegido.persona_id).customPUT(aEnviar).then((r)->
			$scope.toastr.success 'Foto oficial asignada con éxito'
			console.log r
		, (r2)->
			console.log 'Error al asignar foto al profesor', r2
			$scope.toastr.error 'Error al asignar foto al profesor', 'Problema'
		)



	$scope.pedirCambioFirma = (profeElegido, imgFirmaProfe)->
		console.log 'Cambiaremos firma ', profeElegido, imgFirmaProfe

		aEnviar = {
			imgFirmaProfe: imgFirmaProfe.id
		}
		Restangular.one('perfiles/cambiarfirmaunprofe', profeElegido.persona_id).customPUT(aEnviar).then((r)->
			$scope.toastr.success 'Firma asignada con éxito'
			console.log r
		, (r2)->
			console.log 'Error al asignar foto al profesor', r2
			$scope.toastr.error 'Error al asignar foto al profesor', 'Problema'
		)



	return
])

