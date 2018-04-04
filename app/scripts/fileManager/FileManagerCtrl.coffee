'use strict'

angular.module("myvcFrontApp")

.controller('FileManagerCtrl', ['$scope', 'Upload', '$timeout', '$filter', 'App', '$http', 'Perfil', '$uibModal', 'resolved_user', 'toastr', 'AuthService', 'ProfesoresServ', ($scope, $upload, $timeout, $filter, App, $http, Perfil, $modal, resolved_user, toastr, AuthService, ProfesoresServ)->

	$scope.USER 			= resolved_user
	$scope.subir_intacta 	= {}
	$scope.hasRoleOrPerm 	= AuthService.hasRoleOrPerm
	$scope.cantUp 			= 10 # cantidad de imágenes que pueden subir
	$scope.tabFileManager 	= 'mis_img' # 'mis_img' 'imgs_usus'

	fixDato = ()->
		$scope.dato =
			imgUsuario:
				id:		$scope.USER.imagen_id
				nombre:	$scope.USER.imagen_nombre
			imgOficial:
				id:		$scope.USER.foto_id
				nombre:	$scope.USER.foto_nombre

	fixDato()

	$scope.perfilPath 			= App.images + 'perfil/'
	$scope.imgFiles 			= []
	$scope.errorMsg 			= ''
	$scope.fileReaderSupported 	= window.FileReader != null && (window.FileAPI == null || FileAPI.html5 != false);
	$scope.dato.usuarioElegido 	= []
	$scope.dato.tipo_a_cambiar 	= 'alumno'
	$scope.usuariosall 			= []
	$scope.profesores 			= []


	$http.get('::myimages').then((r)->
		r = r.data
		$scope.imagenes_privadas 	= r.imagenes_privadas
		$scope.imagenes_publicas 	= r.imagenes_publicas
		#$scope.imagenes_all 		= r.imagenes_publicas.concat( r.imagenes_privadas )
		$scope.logo 				= r.logo
		$scope.dato.imgParaUsuario 	= r.imagenes_privadas[0]
		$scope.grupos 				= r.grupos
		$scope.profesores 			= r.profesores

	, (r2)->
		toastr.error 'No se trajeron las imágenes.'
	)


	if $scope.hasRoleOrPerm(['profesor', 'admin'])
		$scope.cantUp = 2


	if localStorage.tabFileManager
		$scope.tabFileManager = localStorage.tabFileManager
	else
		localStorage.tabFileManager = $scope.tabFileManager
		$timeout ()->
			$scope.tabFileManager 	= 'mis_img'



	$scope.selectTab = (indice)->
		localStorage.tabFileManager 	= indice
		$scope.tabFileManager 			= localStorage.tabFileManager



	###########################################################
	############### 	SUBIDA DE IMÁGENES 		###############
	###########################################################
	$scope.uploadFiles =  (files)->
		if $scope.imagenes_privadas.length > 2 and $scope.hasRoleOrPerm(['alumno', 'acudiente'])
			toastr.warning 'No tiene permiso para subir más imágenes'

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



	###########################################################
	############### 	PEDIDOS PERSONALES 		###############
	###########################################################
	$scope.pedirCambioUsuario = (imgUsu)->
		if imgUsu.id
			$http.put('::images-users/cambiar-imagen-perfil/'+$scope.USER.user_id, {imagen_id: imgUsu.id}).then((r)->
				r = r.data
				if $scope.hasRoleOrPerm('admin')
					Perfil.setImagen(r.imagen_id, imgUsu.nombre)
					$scope.$emit 'cambianImgs', {image: r}
					toastr.success 'Imagen principal cambiada'
				else
					toastr.info 'Ahora espera que un administrador acepte tu imagen', 'Solicitado'

			, (r2)->
				toastr.error 'No se pudo cambiar imagen', 'Problema'
			)
		else
			toastr.warning 'Selecciona una imagen'

	$scope.pedirCambioOficial = (imgOfi)->
		if imgOfi.id
			$http.put('::images-users/cambiar-imagen-oficial/'+$scope.USER.user_id, {foto_id: imgOfi.id}).then((r)->
				r = r.data
				if $scope.hasRoleOrPerm('admin')
					Perfil.setOficial(r.foto_id, imgOfi.nombre)
					$scope.$emit 'cambianImgs', {foto: r}
					toastr.success 'Foto oficial cambiada'
				else
					toastr.info 'Ahora espera que un administrador acepte tu imagen', 'Solicitado'

			, (r2)->
				toastr.error 'No se pudo cambiar foto', 'Problema'
			)
		else
			toastr.warning 'Selecciona una imagen'

	$scope.pedirCambioFirma = (imgFirmaProfe)->
		if imgFirmaProfe.id
			aEnviar = { imgFirmaProfe: imgFirmaProfe.id }
			$http.put('::perfiles/cambiarfirmaunprofe/'+$scope.USER.persona_id, aEnviar).then((r)->
				toastr.success 'Firma cambiada con éxito'
				$scope.USER.firma_id      = r.data.id
				$scope.USER.firma_nombre  = r.data.nombre

			, (r2)->
				toastr.error 'Error al asignar foto al profesor', 'Problema'
			)
		else
			toastr.warning 'Selecciona una imagen'

	$scope.cambiarLogoColegio = (imgLogo)->
		$http.put('::myimages/cambiarlogocolegio', {logo_id: imgLogo.id}).then((r)->
			toastr.success 'Logo del colegio cambiado'
			$scope.logo.logo 	= imgLogo.nombre
			$scope.logo.logo_id = imgLogo.id
			console.log $scope.logo, imgLogo
		, (r2)->
			toastr.error 'No se pudo cambiar el logo', 'Problema'
		)

	$scope.grupoSelect = (item, model)->
		$http.get('::grupos/listado/'+item.id).then((r)->
			r = r.data
			$scope.alumnos = r
			$scope.dato.alumnoElegido = r[0]
			$scope.alumSelect($scope.dato.alumnoElegido)
		, (r2)->
			toastr.error 'No se pudo traer los usuarios'
		)

	$scope.rotarImagen = (imagen)->
		$http.put('::images-users/rotarimagen/'+imagen.id).then((r)->
			imagen.nombre = ''
			toastr.success 'Imagen rotada'
			imagen.nombre = r.data + '?' + new Date().getTime()
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

			if imagen.user_id == $scope.USER.user_id
				$scope.imagenes_privadas.push imagen

			$scope.imagenes_publicas = $filter('filter')($scope.imagenes_publicas, {id: '!'+imagen.id})

		, (r2)->
			toastr.error 'Imagen no privatizada'
		)



	$scope.borrarImagen = (imagen, usuario_id)->

		modalInstance = $modal.open({
			templateUrl: '==fileManager/removeImage.tpl.html'
			controller: 'RemoveImageCtrl'
			size: 'md',
			resolve:
				imagen: ()->
					imagen
				user_id: ()->
					usuario_id
				datos_imagen: ()->

					codigos =
						imagen_id: imagen.id
						user_id: usuario_id

					$http.put('::myimages/datos-imagen', codigos).then((r)->

						return $scope.datos_imagen = r.data
					, (r2)->
						toastr.error 'Error al traer datos de imagen', 'Problema'
						return {}
					)

		})
		modalInstance.result.then( (imag)->
			if $scope.hasRoleOrPerm('admin')
				if imag.publica
					$scope.imagenes_publicas = $filter('filter')($scope.imagenes_publicas, {id: '!'+imag.id})
				else
					$scope.imagenes_privadas = $filter('filter')($scope.imagenes_privadas, {id: '!'+imag.id})
				toastr.success 'La imagen ha sido removida.'
			else
				if imag.user_id == $scope.USER.user_id
					toastr.success 'La imagen ha sido removida.'
					if imag.publica
						$scope.imagenes_publicas = $filter('filter')($scope.imagenes_publicas, {id: '!'+imag.id})
					else
						$scope.imagenes_privadas = $filter('filter')($scope.imagenes_privadas, {id: '!'+imag.id})
				else
					toastr.info 'Un administrador borrará la imagen ya que no fuiste tú quien la subió', 'Solicitado'
		)



	###########################################################
	############### 	CAMBIAR A USUARIOS 		###############
	###########################################################
	$scope.cambiarImgUnUsuario = (usuarioElegido, imgParaUsuario)->

		confirmando = false
		if imgParaUsuario
			confirmando = confirm('Esto quitará la imágen de tu lista. ¿Seguro que deseas cambiar la imagen de este usuario?')
		else
			confirmando = confirm('¿Ya no quieres que esta sea su imagen de perfil?')

		if confirmando

			aEnviar = {}

			if imgParaUsuario
				aEnviar.imagen_id = imgParaUsuario.id

			$http.put('::images-users/cambiar-imagen-un-usuario/'+usuarioElegido.user_id, aEnviar).then((r)->

				if imgParaUsuario
					usuarioElegido.imagen_id 		= imgParaUsuario.id
					usuarioElegido.imagen_nombre 	= imgParaUsuario.nombre

					$scope.imagenes_privadas = $filter('filter')($scope.imagenes_privadas, (item)->
						return item.id != imgParaUsuario.id;
					)

					$scope.dato.selectedImg = undefined

					toastr.success 'Imagen quitada con éxito'
				else
					usuarioElegido.imagen_id 		  = null
					usuarioElegido.imagen_nombre 	= 'default_male.png'
					toastr.success 'Imagen asignada con éxito'
			, (r2)->
				toastr.error 'Error al asignar imagen a usuario', 'Problema'
			)


	$scope.cambiarFotoUnUsuario = (usuarioElegido, imgParaUsuario)->

		confirmando = false
		if imgParaUsuario
			confirmando = confirm('Esto quitará la imágen de tu lista. ¿Seguro que deseas cambiar la imagen de este usuario?')
		else
			confirmando = confirm('¿Ya no quieres que esta sea su foto oficial?')

		if confirmando

			aEnviar = {}

			if imgParaUsuario
				aEnviar.imagen_id = imgParaUsuario.id

			$http.put('::images-users/cambiar-foto-un-usuario/'+usuarioElegido.user_id, aEnviar).then((r)->

				if imgParaUsuario
					usuarioElegido.imagen_id 		= imgParaUsuario.id
					usuarioElegido.foto_nombre 		= imgParaUsuario.nombre

					$scope.imagenes_privadas = $filter('filter')($scope.imagenes_privadas, (item)->
						return item.id != imgParaUsuario.id;
					)

					$scope.dato.selectedImg = undefined
					toastr.success 'Foto quitada con éxito'
				else
					usuarioElegido.foto_id 		  = null
					usuarioElegido.foto_nombre 	= 'default_male.png'
					toastr.success 'Foto asignada con éxito'
			, (r2)->
				toastr.error 'Error al asignar foto oficial', 'Problema'
			)





	$scope.cambiarFirmaUnProfe = (profeElegido, imgParaUsuario)->

		aEnviar = { imagen_id: imgParaUsuario.id }

		$http.put('::images-users/cambiar-firma-un-profe/'+profeElegido.profesor_id, aEnviar).then((r)->

				profeElegido.firma_id 			= imgParaUsuario.id
				profeElegido.firma_nombre 		= imgParaUsuario.nombre

				$scope.imagenes_privadas = $filter('filter')($scope.imagenes_privadas, (item)->
					return item.id != imgParaUsuario.id;
				)

				$scope.dato.selectedImg = undefined

				toastr.success 'Firma asignada con éxito'
		, (r2)->
			toastr.error 'Error al asignar firma', 'Problema'
		)





	$scope.alumSelect = ($item, $model)->

		aEnviar = { usuario_id: $item.user_id }

		$http.put('::images-users/imagenes-de-usuario', aEnviar).then((r)->
				$scope.imagenes_del_usuario       = r.data
				$scope.mostrando_opt_img_de_alum  = true
		, (r2)->
			toastr.error 'Error trayendo imagenes del usuario', 'Problema'
		)




	$scope.profeSelect = ($item, $model)->

		aEnviar = { usuario_id: $item.user_id }

		$http.put('::images-users/imagenes-de-usuario', aEnviar).then((r)->
				$scope.imagenes_del_usuario       = r.data
				$scope.mostrando_opt_img_de_prof  = true
		, (r2)->
			toastr.error 'Error trayendo imagenes del usuario', 'Problema'
		)




	$scope.moveImgToMe = ($item, $model)->

		aEnviar = { img_id: $item.id }

		$http.put('::images-users/move-img-to-me', aEnviar).then((r)->
			toastr.success 'Ahora la imagen te pertenece.'
		, (r2)->
			toastr.error 'Error mover imagen', 'Problema'
		)




	return
])

