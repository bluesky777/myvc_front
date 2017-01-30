'use strict'

angular.module("myvcFrontApp")

.controller('FileManagerCtrl', ['$scope', '$upload', '$timeout', '$filter', 'App', '$http', 'Perfil', '$uibModal', 'resolved_user', 'toastr', 'AuthService', ($scope, $upload, $timeout, $filter, App, $http, Perfil, $modal, resolved_user, toastr, AuthService)->
	
	$scope.USER = resolved_user
	$scope.subir_intacta = {}
	$scope.hasRoleOrPerm = AuthService.hasRoleOrPerm

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

	$http.get('::myimages').then((r)->
		r = r.data
		$scope.imagenes_privadas = r.imagenes_privadas
		$scope.imagenes_publicas = r.imagenes_publicas
		$scope.dato.imgParaUsuario = r.imagenes_privadas[0]
	, (r2)->
		toastr.error 'No se trajeron las imágenes.'
	)

	$scope.upload =  (files)->
		$scope.imgFiles = files
		$scope.errorMsg = ''

		if files and files.length

			for i in [0...files.length]
				file = files[i]
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

		intactaUrl = if $scope.subir_intacta.intacta then '-intacta' else ''

		if file.size > 10000000
			$scope.errorMsg = 'Archivo excede los 10MB permitidos.'
			return

		$upload.upload({
			url: App.Server + 'myimages/store' + intactaUrl,
			#fields: {'username': $scope.username},
			file: file
		}).progress( (evt)->
			progressPercentage = parseInt(100.0 * evt.loaded / evt.total)
			file.porcentaje = progressPercentage
			#console.log('progress: ' + progressPercentage + '% ' + evt.config.file.name, evt.config)
		).success( (data, status, headers, config)->
			if $scope.subir_intacta.intacta
				$scope.imagenes_publicas.push data
			else
				$scope.imagenes_privadas.push data
		).error((r2)->
			console.log 'Falla uploading: ', r2
		).xhr((xhr)->
			#xhr.upload.addEventListener()
			#/* return $http promise then(). Note that this promise does NOT have progress/abort/xhr functions */
		)#.then((), error, progress)


	$scope.pedirCambioUsuario = (imgUsu)->
		$http.put('::myimages/cambiarimagenperfil/'+$scope.USER.user_id, {imagen_id: imgUsu.id}).then((r)->
			r = r.data
			Perfil.setImagen(r.imagen_id, imgUsu.nombre)
			$scope.$emit 'cambianImgs', {image: r}
			toastr.success 'Imagen principal cambiada'
		, (r2)->
			toastr.error 'No se pudo cambiar imagen', 'Problema'
		)

	$scope.pedirCambioOficial = (imgOfi)->
		$http.put('::myimages/cambiarimagenoficial/'+$scope.USER.user_id, {foto_id: imgOfi.id}).then((r)->
			r = r.data
			if r.asked_by_user_id
				toastr.info 'Pedido realizado, espera respuesta.'
			else if r == 'En espera'
				toastr.info 'Espera respuesta.'
			else
				Perfil.setOficial(r.foto_id, imgOfi.nombre)
				$scope.$emit 'cambianImgs', {foto: r}
				toastr.success 'Foto oficial cambiada'
		, (r2)->
			toastr.error 'No se pudo cambiar foto', 'Problema'
		)

	$scope.cambiarLogoColegio = (imgLogo)->
		$http.put('::myimages/cambiarlogocolegio', {logo_id: imgLogo.id}).then((r)->
			toastr.success 'Logo del colegio cambiado'
		, (r2)->
			toastr.error 'No se pudo cambiar el logo', 'Problema'
		)

	$scope.imagenSelect = (item, model)->
		#console.log 'imagenSelect: ', item, model

	$scope.fotoSelect = (item, model)->
		#console.log 'imagenSelect: ', item, model

	$scope.grupoSelect = (item, model)->
		#console.log 'grupoSelect: ', item, model
		$http.get('::grupos/listado/'+item.id).then((r)->
			r = r.data
			$scope.alumnos = r
			$scope.dato.alumnoElegido = r[0]
		, (r2)->
			toastr.error 'No se pudo traer los usuarios'
		)

	$scope.rotarImagen = (imagen)->
		$http.put('::myimages/rotarimagen/'+imagen.id).then((r)->
			imagen.nombre = ''
			toastr.success 'Imagen rotada'
			imagen.nombre = r + '?' + new Date().getTime()
		, (r2)->
			toastr.error 'Imagen no rotada'
		)


	$scope.publicarImagen = (imagen)->
		$http.put('::myimages/publicar-imagen/'+imagen.id).then((r)->
			toastr.info 'Ahora la imagen es pública'

			$scope.imagenes_privadas = $filter('filter')($scope.imagenes_privadas, {id: '!'+imagen.id})
			$scope.imagenes_publicas.push imagen

		, (r2)->
			toastr.error 'Imagen no publicada'
		)


	$scope.privatizarImagen = (imagen)->
		$http.put('::myimages/privatizar-imagen/'+imagen.id).then((r)->
			r = r.data
			if r.imagen 
				toastr.warning 'No puede ser logo del año ' + r.imagen.is_logo_of_year
				return

			toastr.info 'Ahora la imagen es privada'

			if imagen.user_id == $scope.USER.id
				$scope.imagenes_privadas.push imagen
			
			$scope.imagenes_publicas = $filter('filter')($scope.imagenes_publicas, {id: '!'+imagen.id})

		, (r2)->
			toastr.error 'Imagen no privatizada'
		)



	$scope.borrarImagen = (imagen)->

		modalInstance = $modal.open({
			templateUrl: '==fileManager/removeImage.tpl.html'
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

					$http.get('::myimages/datos-imagen', codigos).then((r)->
						return $scope.datos_imagen = r.data
					, (r2)->
						toastr.error 'Error al traer datos de imagen', 'Problema'
						return {}
					)

		})
		modalInstance.result.then( (imag)->
			if imag.publica
				$scope.imagenes_publicas = $filter('filter')($scope.imagenes_publicas, {id: '!'+imag.id})
			else
				$scope.imagenes_privadas = $filter('filter')($scope.imagenes_privadas, {id: '!'+imag.id})
		)


	$http.get('::perfiles/usuariosall?year_id=' + $scope.USER.year_id).then((r)->
		r = r.data
		$scope.usuariosall = r
		$scope.usuariosprofes = $filter('filter')(r, {tipo: 'Pr'}, true)
		$scope.dato.usuarioElegido = r[0]
	, (r2)->
		toastr.error 'No se pudo traer los usuarios', r2
	)



	$http.get('::grupos').then((r)->
		$scope.grupos = r.data
	)

	$scope.cambiarImgUnUsuario = (usuarioElegido, imgParaUsuario)->
		
		aEnviar = {
			imgParaUsuario: imgParaUsuario.id
		}
		$http.put('::perfiles/cambiarimgunusuario/'+usuarioElegido.user_id, aEnviar).then((r)->

			usuarSelect = $filter('filter')($scope.usuariosall, {user_id: usuarioElegido.user_id})
			usuarSelect[0].imagen_id = imgParaUsuario.id
			usuarSelect[0].imagen_nombre = imgParaUsuario.nombre

			toastr.success 'Imagen asignada con éxito'
		, (r2)->
			toastr.error 'Error al asignar imagen a usuario', 'Problema'
		)

	$scope.usuarioSelect = (item, model)->
		$scope.dato.selectUsuarioModel = item


	$scope.cambiarFotoUnAlumno = (alumnoElegido, imgOficialAlumno)->
		aEnviar = {
			imgOficialAlumno: imgOficialAlumno.id
		}
		$http.put('::perfiles/cambiarimgunalumno/'+alumnoElegido.alumno_id, aEnviar).then((r)->

			usuarSelect = $filter('filter')($scope.alumnos, {id: alumnoElegido.id})
			usuarSelect[0].foto_id = imgOficialAlumno.id
			usuarSelect[0].foto_nombre = imgOficialAlumno.nombre

			toastr.success 'Foto oficial asignada con éxito'
		, (r2)->
			toastr.error 'Error al asignar foto al alumno', 'Problema'
		)

	

	$scope.cambiarFotoUnProfe = (profeElegido, imgOficialProfe)->
		aEnviar = {
			imgOficialProfe: imgOficialProfe.id
		}
		$http.put('::perfiles/cambiarimgunprofe/'+profeElegido.persona_id, aEnviar).then((r)->
			toastr.success 'Foto oficial asignada con éxito'
		, (r2)->
			toastr.error 'Error al asignar foto al profesor', 'Problema'
		)



	$scope.pedirCambioFirma = (profeElegido, imgFirmaProfe)->
		
		aEnviar = {
			imgFirmaProfe: imgFirmaProfe.id
		}
		$http.put('::perfiles/cambiarfirmaunprofe/'+profeElegido.persona_id, aEnviar).then((r)->
			toastr.success 'Firma asignada con éxito'
		, (r2)->
			toastr.error 'Error al asignar foto al profesor', 'Problema'
		)



	return
])

