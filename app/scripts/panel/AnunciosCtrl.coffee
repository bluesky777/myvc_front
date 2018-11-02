angular.module('myvcFrontApp')


.controller('AnunciosDirCtrl', ['$scope', '$uibModal', 'AuthService', '$http', 'toastr', '$filter', 'App', '$timeout', 'Upload', '$sce', 'uiCalendarConfig', '$compile', ($scope, $modal, AuthService, $http, toastr, $filter, App, $timeout, $upload, $sce, uiCalendarConfig, $compile)->

	$scope.hasRoleOrPerm          = AuthService.hasRoleOrPerm
	$scope.perfilPath             = App.images+'perfil/'
	$scope.views 			            = App.views
	$scope.srcCant 				        = $scope.views + 'informes2/verCantAlumnosPorGrupos.tpl.html'
	$scope.fileReaderSupported 	  = window.FileReader != null && (window.FileAPI == null || FileAPI.html5 != false);
	$scope.imgFiles               = []
	$scope.imagen_subida          = true
	$scope.mostrar_publicaciones  = true
	$scope.guardando_publicacion  = false
	$scope.USER                   = $scope.USER
	$scope.profe_seleccionado     = false
	$scope.mostrando_edit_evento  = false
	$scope.actualizando_cumples   = false
	$scope.IS_PROF_ADMIN 		      = $scope.hasRoleOrPerm(['admin', 'profesor']);
	$scope.IS_ALUM_ACUD 		      = $scope.hasRoleOrPerm(['alumno', 'acudiente']) || $scope.USER.tipo == 'Acudiente';


	$scope.new_publicacion  = {
		publi_para: 'publi_para_todos',
		para_alumnos: 1
	}

	$scope.evento_actual =
		title:  ''
		start:  null
		end:    null
		allDay: 1
		solo_profes: 0



	# CALENDARIO
	$scope.data = {} # Para el popup del Datapicker

	$scope.dateOptions =
		formatYear: 'yyyy'

	if localStorage.panel_tab_actual
		$scope.panel_tab_actual = localStorage.panel_tab_actual


	$scope.guardarEvento = (evento)->
		console.log evento
		if evento.title.length==0 or !evento.start
			toastr.warning 'Escribe título y fecha inicio'
			return

		if !evento.allDay and !evento.end
			toastr.warning 'Escribe fecha fin o elige Todo el día'
			return

		evento.guardando = true

		if evento.editar
			$http.put('::calendario/guardar-evento', evento).then(()->
				toastr.success 'Guardado'
				evento.guardando  = false
				evento.editar     = false

				$scope.evento_actual =
					title:  ''
					start:  null
					end:    null
					allDay: 1
					solo_profes: 0
					id:     null

			, ()->
				toastr.error 'Error guardando'
				evento.guardando = false
			)
		else
			$http.put('::calendario/crear-evento', evento).then((r)->
				toastr.success 'Creado'
				evento.guardando  = false

				evento.id = r.data.evento_id
				$scope.eventos[0].push(evento)

				$scope.evento_actual =
					title:  ''
					start:  null
					end:    null
					allDay: 1
					solo_profes: 0
					id:     null

			, ()->
				toastr.error 'Error creando'
				evento.guardando = false
			)


	$scope.actualizarEventos = ()->
		$http.put('::calendario/this-year').then((r)->
			$scope.eventos = null

			$timeout(()->
				for evento in r.data
					evento.start      = new Date(evento.start);
					evento.end        = if evento.end then new Date(evento.end) else null;
					if evento.solo_profes
						evento.className  = 'evento-solo-profes'
					else
						evento.className  = if evento.cumple_alumno_id or evento.cumple_profe_id then 'evento-cumpleanios' else null

				$scope.eventos = [
					r.data
				];
				toastr.success 'Actualizado'
			, 500)

		, ()->
			toastr.error 'Error actualizando'
		)



	$scope.noMostrarEditEvento = ()->
		$scope.mostrando_edit_evento = false


	$scope.mostrarEditEvento = ()->
		$scope.mostrando_edit_evento = true


	$scope.cancelarEdicion = ()->
		$scope.evento_actual =
			title:  ''
			start:  null
			end:    null
			allDay: 1
			id:     null

	$scope.eliminarEvento = (evento)->
		console.log evento
		if evento.guardando
			return

		respu = confirm('¿Seguro que desea eliminar evento?')
		if !respu
			return

		evento.guardando = true

		if evento.editar
			$http.put('::calendario/eliminar-evento', evento).then(()->
				toastr.success 'Eliminado'
				evento.guardando  = false

				$scope.evento_actual =
					title:  ''
					start:  null
					end:    null
					solo_profes: 0
					allDay: 1

			, ()->
				toastr.error 'Error eliminando'
				evento.guardando = false
			)

	$scope.actualizarCumplesEnCalendario = ()->

		respu = confirm('Esto borrará y creará de nuevo los cumpleaños, ¿continuar?')
		if !respu
			return

		$scope.actualizando_cumples = true

		$http.put('::calendario/sincronizar-cumples').then(()->
			toastr.success 'Sincronizado', 'Actualice'
			$scope.actualizando_cumples = false
		, ()->
			toastr.error 'Error sincronizando'
			$scope.actualizando_cumples = false
		)


	$scope.fromEventoToActual = (date)->

		$scope.evento_actual =
			title:  date.title
			start:  if date.start then new Date(date.start) else null
			end:    if date.end then new Date(date.end) else null
			allDay: if date.allDay then 1 else 0
			solo_profes: 0
			editar: true
			id:     date.id


	$scope.alertOnEventClick = ( date, jsEvent, view)->
		$scope.fromEventoToActual(date)
		$scope.mostrando_edit_evento = true


	$scope.alertOnDrop = (event, delta, revertFunc, jsEvent, ui, view)->
		$scope.fromEventoToActual(event)
		$scope.guardarEvento($scope.evento_actual)
		console.log('Event Droped to make dayDelta ' + delta, event);


	$scope.alertOnResize = (event, delta, revertFunc, jsEvent, ui, view )->
		$scope.fromEventoToActual(event)
		$scope.guardarEvento($scope.evento_actual)
		console.log('Event Resized to make dayDelta ' + delta, event);

	###
	$scope.changeView = (view)->
		$timeout(()->
			uiCalendarConfig.calendars['myCalendar'].fullCalendar('changeView',view);
		, 100)
	###

	$scope.eventRender = ( event, element, view)->
		element.attr({'uib-tooltip-html': "\'<p>" + event.title + "</p>Por: " + event.created_by_nombres + "\'", 'tooltip-append-to-body': true})
		$compile(element)($scope);



	$scope.uiConfig = {
		calendar:{
			height: 450,
			editable: if $scope.IS_PROF_ADMIN then true else false,
			eventRender: $scope.eventRender
			header:{
				left: 'month agendaWeek agendaDay',
				center: 'title',
				right: 'today prev,next'
			},
			eventDurationEditable: if $scope.IS_PROF_ADMIN then true else false
			eventClick: $scope.alertOnEventClick,
			eventDrop: $scope.alertOnDrop,
			eventResize: if $scope.IS_PROF_ADMIN then $scope.alertOnResize else null
			buttonText: {
				today:'Hoy',
				month: 'Mes',
				agendaWeek: 'Semana',
				agendaDay: 'Día'
			},
		}
	}


	$scope.selectTab = (tab)->
		$scope.panel_tab_actual = tab
		localStorage.panel_tab_actual = $scope.panel_tab_actual




	# PUBLICACIONES
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
		$scope.guardando_publicacion = true

		if new_publicacion.editar
			$http.put('::publicaciones/guardar-edicion', new_publicacion).then((r)->

				new_publicacion.id          		= r.data.publicacion_id
				new_publicacion.imagen_nombre 	= if $scope.new_publicacion.imagen then $scope.new_publicacion.imagen.nombre else null
				new_publicacion.contenido_tr 		= $sce.trustAsHtml(new_publicacion.contenido)
				new_publicacion.updated_at 			= $filter('date')(new Date(), 'short')

				$scope.imagen_temporal = undefined

				toastr.success 'Guardado. Recargue la página'

				$scope.new_publicacion  = {
					publi_para: 'publi_para_todos',
					para_alumnos: 1
				}
				$scope.creando_publicacion    = false
				$scope.guardando_publicacion  = false

			, (r2)->
				toastr.error 'Error al publicar', 'Problema'
				$scope.guardando_publicacion = false
				return {}
			)
		else
			$http.put('::publicaciones/store', new_publicacion).then((r)->

				new_publicacion.id          		= r.data.publicacion_id
				new_publicacion.imagen_nombre 	= if $scope.new_publicacion.imagen then $scope.new_publicacion.imagen.name else null
				new_publicacion.contenido_tr 		= $sce.trustAsHtml(new_publicacion.contenido)
				new_publicacion.updated_at 			= $filter('date')(new Date(), 'short')

				$scope.changes_asked.mis_publicaciones.unshift new_publicacion
				$scope.changes_asked.publicaciones.unshift new_publicacion

				$scope.imagen_temporal = undefined

				toastr.success 'Publicado con éxito'

				$scope.new_publicacion  = {
					publi_para: 'publi_para_todos',
					publi_para_alumnos: 1
				}
				$scope.creando_publicacion    = false
				$scope.guardando_publicacion  = false

			, (r2)->
				toastr.error 'Error al publicar', 'Problema'
				$scope.guardando_publicacion = false
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



