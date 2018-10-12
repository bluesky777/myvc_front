angular.module('myvcFrontApp')

.directive('anunciosDir',['App', '$http', 'toastr', '$uibModal', '$state', 'AuthService', '$sce', (App, $http, toastr, $modal, $state, AuthService, $sce)->

	restrict: 'E'
	templateUrl: "#{App.views}panel/anunciosDir.tpl.html"


	link: (scope, iElem, iAttrs)->

		scope.perfilPath      = App.images+'perfil/'
		scope.views 		      = App.views



		if $state.is 'panel'
			$http.get('::ChangesAsked/to-me').then((r)->
				scope.changes_asked = r.data

				for publi in scope.changes_asked.publicaciones
					publi.contenido = $sce.trustAsHtml(publi.contenido)

				if AuthService.hasRoleOrPerm(['alumno', 'acudiente'])
					scope.publicaciones_actuales   = [ scope.changes_asked.publicaciones[0] ]

					if scope.changes_asked.publicaciones.length > 1
						scope.publicaciones_actuales.push(scope.changes_asked.publicaciones[1])


				if AuthService.hasRoleOrPerm(['admin', 'profesor'])
					if scope.changes_asked.publicaciones.length > 0
						scope.publicacion_actual = scope.changes_asked.publicaciones[0]



				if AuthService.hasRoleOrPerm(['admin', 'profesor', 'alumno'])

					scope.options = {
						chart: {
							type: 'discreteBarChart',
							height: 180,
							margin : {
								top: 20,
								right: 20,
								bottom: 60,
								left: 55
							},
							useInteractiveGuideline: true,
							x: (d)-> return d.label;
							y: (d)-> return d.value;
							showValues: true,
							valueFormat: (d)-> d3.format(',.0f')(d);
							transitionDuration: 500
							xAxis: {
								axisLabel: "X Axis",
								rotateLabels: 30,
								showMaxMin: false
							}
							zoom: {
								enabled: true,
								scaleExtent: [1,10],
								useFixedDomain: false,
								useNiceScale: false,
								horizontalOff: false,
								verticalOff: true,
								unzoomEventType: "dblclick.zoom"
							}
						}
						title: {
							enable: false,
							text: 'Asignaturas correctas'
						}
					};


					valores = []
					for profe in scope.changes_asked.profes_actuales
						valores.push { label: profe.nombres + ' ' + profe.apellidos.substr(0,1) + '.', value: profe.porcentaje }


					scope.data = [{
						key: "Asignaturas correctas",
						values: valores
					}];
				# fin de IF AuthService





			, (r2)->
				#toastr.error 'No se pudo traer los anuncios.'
				console.log r2
			)

	controller: 'AnunciosDirCtrl'
])


.directive('publicacionesPanelDir',['App', '$http', 'toastr', '$uibModal', '$state', 'AuthService', (App, $http, toastr, $modal, $state, AuthService)->

	restrict: 'E'
	templateUrl: "#{App.views}panel/publicacionesPanelDir.tpl.html"

])




.controller('AnunciosDirCtrl', ['$scope', '$uibModal', 'AuthService', '$http', 'toastr', '$filter', 'App', '$timeout', 'Upload', '$sce', ($scope, $modal, AuthService, $http, toastr, $filter, App, $timeout, $upload, $sce)->

	$scope.hasRoleOrPerm    = AuthService.hasRoleOrPerm
	$scope.perfilPath       = App.images+'perfil/'
	$scope.views 			      = App.views
	$scope.srcCant 				  = $scope.views + 'informes2/verCantAlumnosPorGrupos.tpl.html'
	$scope.fileReaderSupported 	= window.FileReader != null && (window.FileAPI == null || FileAPI.html5 != false);
	$scope.imgFiles         = []
	$scope.imagen_subida    = true
	$scope.mostrar_publicaciones = true
	$scope.new_publicacion  = {
		publi_para: 'publi_para_todos',
		para_alumnos: 1
	}
	$scope.USER             = $scope.USER

	$scope.profe_seleccionado = false


	$scope.editarPublicacion = (publicacion)->
		if publicacion.para_todos
			publicacion.publi_para = 'publi_para_todos'
		else
			publicacion.publi_para = 'publi_privada'

		publicacion.editar          = true
		$scope.new_publicacion      = publicacion
		$scope.creando_publicacion  = true




	$scope.verPublicacion = (publi, $index)->
		if $index > -1
			$scope.publicaciones_actuales   = [ publi ]

			if $scope.changes_asked.publicaciones.length > ($index + 1)
				$scope.publicaciones_actuales.push($scope.changes_asked.publicaciones[$index + 1])

			$scope.creando_publicacion      = false
		else
			$scope.publicacion_actual   = publi
			$scope.creando_publicacion  = false


	$scope.eliminarPublicacion = (publi)->
		$http.put('::publicaciones/delete', { publi_id: publi.id }).then((r)->

			toastr.success 'Eliminada.'
			publi.deleted_at = new Date().toString()

		, (r2)->
			toastr.error 'Error al eliminar', 'Problema'
			return {}
		)

	$scope.verPublicacionDetalle = (publica)->

		modalInstance = $modal.open({
			templateUrl: '==panel/VerPublicacionModal.tpl.html'
			controller: 'VerPublicacionModalCtrl'
			size: 'lg',
			windowClass: 'modal-publicacion'
			resolve:
				publicacion_actual: ()->
					publica
				USER: ()->
					$scope.USER
		})
		modalInstance.result.then( (imag)->
			console.log 'Cerrado'
		)


	$scope.restaurarPublicacion = (publi)->
		$http.put('::publicaciones/restaurar', { publi_id: publi.id }).then((r)->

			toastr.success 'Restaurada.'
			publi.deleted_at = null

		, (r2)->
			toastr.error 'Error al Restaur', 'Problema'
			return {}
		)


	$scope.crearPublicacion = (new_publicacion)->
		if new_publicacion.editar
			$http.put('::publicaciones/guardar-edicion', new_publicacion).then((r)->

				new_publicacion.id          	= r.data.publicacion_id
				new_publicacion.imagen_nombre = if $scope.imagen_temporal then $scope.imagen_temporal.name else null
				new_publicacion.contenido     = $sce.trustAsHtml(new_publicacion.contenido)
				new_publicacion.updated_at 		= $filter('date')(new Date(), 'short')

				$scope.imagen_temporal = undefined

				toastr.success 'Guardado. Recargue la página'

				$scope.new_publicacion  = {
					publi_para: 'publi_para_todos',
					para_alumnos: 1
				}
				$scope.creando_publicacion  = false

			, (r2)->
				toastr.error 'Error al publicar', 'Problema'
				return {}
			)
		else
			$http.put('::publicaciones/store', new_publicacion).then((r)->

				new_publicacion.id          	= r.data.publicacion_id
				new_publicacion.imagen_nombre = if $scope.imagen_temporal then $scope.imagen_temporal.name else null
				new_publicacion.contenido     = $sce.trustAsHtml(new_publicacion.contenido)
				new_publicacion.updated_at 		= $filter('date')(new Date(), 'short')

				$scope.changes_asked.mis_publicaciones.unshift new_publicacion
				$scope.changes_asked.publicaciones.unshift new_publicacion

				$scope.imagen_temporal = undefined

				toastr.success 'Publicado con éxito'

				$scope.new_publicacion  = {
					publi_para: 'publi_para_todos',
					publi_para_alumnos: 1
				}
				$scope.creando_publicacion  = false

			, (r2)->
				toastr.error 'Error al publicar', 'Problema'
				return {}
			)

	$scope.toggle_mis_publicaciones = (publi)->
		$scope.mostrar_publicaciones = false
		$scope.mostrar_mis_publicaciones = !$scope.mostrar_mis_publicaciones

	$scope.toggle_publicaciones = (publi)->
		$scope.mostrar_mis_publicaciones = false
		$scope.mostrar_publicaciones = !$scope.mostrar_publicaciones


	###########################################################
	############### 	SUBIDA DE IMÁGENES 		###############
	###########################################################
	$scope.uploadFiles =  (files)->

		$scope.errorMsg       = ''

		if files and files.length

			for i in [0...files.length]
				file = files[i]
				$scope.imagen_temporal = file
				generateThumbAndUpload file


	generateThumbAndUpload = (file)->
		$scope.errorMsg = null
		uploadUsing$upload(file)
		$scope.generateThumb(file)

	$scope.generateThumb = (file)->
		console.log file
		if file != null
			if $scope.fileReaderSupported and file.type.indexOf('image') > -1
				$timeout ()->
					fileReader = new FileReader()
					fileReader.readAsDataURL(file)
					fileReader.onload = (e)->
						$timeout(()->
							file.dataUrl = e.target.result
							$scope.imgFiles.push file
						)

	uploadUsing$upload = (file)->

		$scope.imagen_subida  = false

		if file.size > 5000000
			$scope.errorMsg = 'Archivo excede los 5MB permitidos.'
			return

		$upload.upload({
			url: App.Server + 'myimages/store-intacta-privada',
			file: file
		}).progress( (evt)->
			progressPercentage = parseInt(100.0 * evt.loaded / evt.total)
			file.porcentaje = progressPercentage
			#console.log('progress: ' + progressPercentage + '% ' + evt.config.file.name, evt.config)
		).success( (data, status, headers, config)->
			$scope.new_publicacion.imagen = data
			$scope.imagen_subida          = true
		).error((r2)->
			$scope.imagen_subida          = true
			console.log 'Falla uploading: ', r2
		)



	$scope.borrarImagen = (imagen_temp)->
		imagen = {}
		angular.copy(imagen_temp, imagen)

		if imagen.imagen_id
			imagen.id     = imagen.imagen_id
			imagen.nombre = imagen.imagen_nombre

		modalInstance = $modal.open({
			templateUrl: '==fileManager/removeImage.tpl.html'
			controller: 'RemoveImageCtrl'
			size: 'md',
			resolve:
				imagen: ()->
					imagen
				user_id: ()->
					$scope.USER.user_id
				datos_imagen: ()->

					codigos =
						imagen_id: if imagen.imagen_id then imagen.imagen_id else imagen.id
						user_id: $scope.USER.user_id

					$http.put('::myimages/datos-imagen', codigos).then((r)->
						return $scope.datos_imagen = r.data
					, (r2)->
						toastr.error 'Error al traer datos de imagen', 'Problema'
						return {}
					)

		})
		modalInstance.result.then( (imag)->
			$scope.new_publicacion.imagen 				= undefined
			$scope.new_publicacion.imagen_nombre 	= undefined
			$scope.new_publicacion.imagen_id 			= undefined
			$scope.imgFiles               				= []
		)







	$scope.seleccionar_profe = (profesor)->

		$http.put('::historiales/de-usuario', {user_id: profesor.user_id}).then((r)->
			$scope.profe_seleccionado = r.data
			$scope.profe_seleccionado.profesor = profesor
		, (r2)->
			console.log 'Error trayendo detalles', r2
		)

	$scope.mostrar_crear_publicacion = ()->
		$scope.creando_publicacion = true
		$timeout(()->
			$('#textarea-new-publicacion').focus()
		)

	# Editor options.
	$scope.options = {
		language: 'es',
		allowedContent: true,
		entities: false
	};

	# Called when the editor is completely ready.
	$scope.onReady = ()->
		console.log('Listo para editar')


	$scope.desseleccionar_profe = ()->
		$scope.profe_seleccionado = false



	$scope.verDetalles = (change_asked)->
		if change_asked.mostrando
			change_asked.mostrando = false
		else
			change_asked.mostrando = true

			if not change_asked.detalles
				datos = { asked_id: change_asked.asked_id,  }

				$http.put('::ChangesAsked/ver-detalles', datos).then((r)->
					change_asked.detalles = r.data.detalles
				, (r2)->
					console.log 'Error trayendo detalles', r2
				)



	$scope.traerCatAlumnosPorGrupos = ()->

		$http.put('::grupos/con-cantidad-alumnos').then((r)->
			$scope.grupos_cantidades  = r.data.grupos
			$scope.periodos_total     = r.data.periodos_total

			$scope.cant_total_alumnos = 0

			for grup in $scope.grupos_cantidades
				$scope.cant_total_alumnos = $scope.cant_total_alumnos + grup.cant_alumnos

		, (r2)->
			console.log 'Error trayendo cantidad de alumnos', r2
		)


	$scope.rechazarCambio = (asked, tipo)->

		modalInstance = $modal.open({
			templateUrl: '==panel/rechazarAsked.tpl.html'
			controller: 'RechazarAskedCtrl'
			resolve:
				asked: ()->
					asked
				tipo: ()->
					tipo
		})
		modalInstance.result.then( (r)->
			toastr.info 'Pedido rechazado.'
			asked.finalizado = r.finalizado

			if tipo == 'img_perfil' 	then asked.detalles.image_id_accepted = false
			if tipo == 'foto_oficial' 	then asked.detalles.foto_id_accepted = false
			if tipo == 'img_delete' 	then asked.detalles.image_to_delete_accepted = false
			if tipo == 'nombres' 	then asked.detalles.nombres_accepted = false
			if tipo == 'apellidos' 	then asked.detalles.apellidos_accepted = false
			if tipo == 'sexo' 	then asked.detalles.sexo_accepted = false
			if tipo == 'fecha_nac' 	then asked.detalles.fecha_nac_accepted = false
		)

	$scope.aprobarCambio = (asked, tipo, valor_nuevo)->

		modalInstance = $modal.open({
			templateUrl: '==panel/aceptarAsked.tpl.html'
			controller: 'AceptarAskedCtrl'
			resolve:
				asked: ()->
					asked
				tipo: ()->
					tipo
				valor_nuevo: ()->
					valor_nuevo
		})
		modalInstance.result.then( (r)->
			toastr.success 'Pedido aceptado.'
			asked.finalizado = r.finalizado

			if tipo == 'img_perfil' 	then asked.detalles.image_id_accepted = true
			if tipo == 'img_delete' 	then asked.detalles.image_to_delete_accepted = true
			if tipo == 'nombres' 	    then asked.detalles.nombres_accepted = true
			if tipo == 'apellidos' 	  then asked.detalles.apellidos_accepted = true
			if tipo == 'sexo' 	      then asked.detalles.sexo_accepted = true
			if tipo == 'fecha_nac' 	  then asked.detalles.fecha_nac_accepted = true
			if tipo == 'foto_oficial'
				asked.detalles.foto_id_accepted = true
				asked.foto_nombre 				= asked.detalles.foto_new_nombre

			if tipo == 'asignatura' then asked.finalizado = true

		)

	$scope.eliminarSolicitudes = (asked)->

		modalInstance = $modal.open({
			templateUrl: '==panel/eliminarAsked.tpl.html'
			controller: 'EliminarAskedCtrl'
			resolve:
				asked: ()->
					asked
		})
		modalInstance.result.then( (r)->
			toastr.success 'Pedido eliminado.'
			asked.finalizado = true
		)


	$scope.verDetalleDeMiSesion = (historial)->


		$http.put('::historiales/sesion', { historial_id: historial.id, tipo: historial.tipo }).then((r)->

			modalInstance = $modal.open({
				templateUrl: '==panel/modalDetallesSesion.tpl.html'
				controller: 'ModalDetallesSesionCtrl'
				resolve:
					historial: ()->
						r.data.historial
			})
			modalInstance.result.then( (r)->
				console.log historial
			)

		, (r2)->
			toastr.error 'No se pudo traer el detalle'
		)




	$scope.eliminarIntentoFallido = (intento)->
		res = false
		res = confirm('¿Está seguro de eliminar este registro?')

		if res

			$http.delete('::bitacoras/destroy/'+intento.id).then((r)->
					toastr.success 'Eliminado. Recargue para ver los cambios.'
					intento.eliminada = true
					$scope.changes_asked.intentos_fallidos = $filter('filter')($scope.changes_asked.intentos_fallidos, {id: '!'+intento.id}, true)
			, (r2)->
				toastr.error 'No se pudo eliminar'
			)



])









.controller('AceptarAskedCtrl', ['$scope', '$uibModalInstance', 'asked', 'tipo', 'valor_nuevo', '$http', 'toastr', 'App', ($scope, $modalInstance, asked, tipo, valor_nuevo, $http, toastr, App)->

	$scope.imagesPath = App.images + 'perfil/'
	$scope.asked = asked


	$scope.aceptarAsignatura = ()->
			datos = { pedido: asked, tipo: tipo, asker_id: asked.asked_by_user_id }

			$http.put('::ChangesAsked/aceptar-asignatura', datos).then((r)->
				$modalInstance.close(r.data)
			, (r2)->
				toastr.warning 'Problema', 'No se pudo aceptar petición.'
			)


	$scope.ok = ()->
		if asked.assignment_id
			$scope.aceptarAsignatura()
		else
			datos = { asked_id: asked.asked_id, data_id: asked.detalles.data_id, tipo: tipo, valor_nuevo: valor_nuevo, asker_id: asked.asked_by_user_id }

			if asked.alumno_id
				datos.alumno_id = asked.alumno_id

			$http.put('::ChangesAsked/aceptar-alumno', datos).then((r)->
				$modalInstance.close(r.data)
			, (r2)->
				toastr.warning 'Problema', 'No se pudo aceptar petición.'
			)



	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')


])




.controller('RechazarAskedCtrl', ['$scope', '$uibModalInstance', 'asked', 'tipo', '$http', 'toastr', 'App', ($scope, $modalInstance, asked, tipo, $http, toastr, App)->

	$scope.imagesPath = App.images + 'perfil/'
	$scope.asked = asked

	$scope.ok = ()->

		data_id       = if asked.detalles then asked.detalles.data_id else asked.assignment_id
		assignment_id = asked.detalles.assignment_id

		datos = { asked_id: asked.asked_id, data_id: data_id, assignment_id: assignment_id, tipo: tipo, asker_id: asked.asked_by_user_id }

		$http.put('::ChangesAsked/rechazar', datos).then((r)->
			$modalInstance.close(r.data)
		, (r2)->
			toastr.error 'Problema', 'No se pudo rechazar petición.'
		)


	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])


.controller('EliminarAskedCtrl', ['$scope', '$uibModalInstance', 'asked', '$http', 'toastr', 'App', ($scope, $modalInstance, asked, $http, toastr, App)->
	$scope.imagesPath = App.images + 'perfil/'
	$scope.asked = asked

	$scope.ok = ()->

		datos = { asked_id: asked.asked_id, data_id: asked.detalles.data_id }

		$http.put('::ChangesAsked/destruir', datos).then((r)->
			$modalInstance.close(r.data)
		, (r2)->
			toastr.error 'Problema', 'No se pudo eliminar peticiones.'
		)


	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])


