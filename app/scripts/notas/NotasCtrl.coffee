'use strict'

angular.module('myvcFrontApp')
.controller('NotasCtrl', ['$scope', 'toastr', '$http', '$uibModal', '$state', '$rootScope', '$filter', 'App', 'AuthService', '$timeout', 'EscalasValorativasServ', '$stateParams', 'NotasServ', ($scope, toastr, $http, $modal, $state, $rootScope, $filter, App, AuthService, $timeout, EscalasValorativasServ, $stateParams, NotasServ) ->

	AuthService.verificar_acceso()

	$scope.asignatura 	  = {}
	$scope.asignatura_id  = $state.params.asignatura_id
	$scope.datos 		      = {}
	$scope.UNIDAD 		    = $scope.USER.unidad_displayname
	$scope.SUBUNIDAD 	    = $scope.USER.subunidad_displayname
	$scope.UNIDADES 	    = $scope.USER.unidades_displayname
	$scope.SUBUNIDADES 	  = $scope.USER.subunidades_displayname
	$scope.perfilPath 	  = App.images+'perfil/'
	$scope.views 		      = App.views
	$scope.nota_minima_aceptada = parseInt($scope.USER.nota_minima_aceptada)
	$scope.ocultando_ausencias 	= true
	$scope.ausencia_edit 	= {} # Para editar en el popover
	$scope.tardanza_edit 	= {}
	$scope.alumno_aus_tard_edit 	= {}
	$scope.opts_picker 		= { minDate: new Date('1/1/2017'), showWeeks: false, startingDay: 0 }
	$scope.hasRoleOrPerm  = AuthService.hasRoleOrPerm

	NotasServ.detalladas($stateParams.asignatura_id, $stateParams.profesor_id, true).then((r)->
		$scope.asignatura		= r.asignatura
		$scope.alumnos			= r.alumnos
		$scope.unidades 		= r.unidades
		$scope.asignaturas		= r.asignaturas

		$scope.arreglarDatos()

		###
		$timeout(()->
			$scope.$parent.bigLoader 	= false
		, 1000)
		###
	, (r2)->
		toastr.error 'No se pudo traer las notas con asignaturas.'
	)



	EscalasValorativasServ.escalas().then((r)->
		$scope.escalas = r
	, (r2)->
		console.log 'No se trajeron las escalas valorativas', r2
	)

	$scope.escala_maxima = EscalasValorativasServ.escala_maxima()


	$scope.arreglarDatos = ()->

		# Las Subunidades están en cada Unidad. Necesito agregarlas juntas en un solo Array
		$scope.subunidadesunidas = []

		for unidad in $scope.unidades
			if unidad.subunidades.length == 0
				$scope.subunidadesunidas.push {empty: true}
			for subunidad in unidad.subunidades
				$scope.subunidadesunidas.push subunidad

		if localStorage.ocultando_ausencias
			$scope.ocultando_ausencias = (localStorage.ocultando_ausencias == 'true')

		if localStorage.historial_activado
			$scope.historial_activado = (localStorage.historial_activado == 'true')



		for alumno in $scope.alumnos
			for ausencia in alumno.ausencias
				if ausencia.fecha_hora
					ausencia.fecha_hora = new Date(ausencia.fecha_hora)
			for tardanza in alumno.tardanzas
				if tardanza.fecha_hora
					tardanza.fecha_hora = new Date(tardanza.fecha_hora)

		for asignat in $scope.asignaturas
			if parseInt(asignat.asignatura_id) == parseInt($scope.asignatura.asignatura_id)
				asignat.active = true

		$timeout(()->

			if localStorage.tab_horiz_or_verti
				if localStorage.tab_horiz_or_verti == 'vertical'
					$scope.setTabVertically()
				else
					$scope.setTabHorizontally()
			else
				$scope.setTabHorizontally()

		, 1)



	$scope.setTabVertically = ()->
		localStorage.tab_horiz_or_verti = 'vertical'
		$scope.tab_horiz_or_verti       = 'vertical'
		filas = angular.element('table tr')

		angular.forEach(filas, (value, key)->
			fila 	= angular.element(value);
			inputs 	= fila.find('.input-nota')

			angular.forEach(inputs, (value2, key2)->
				a = angular.element(value2);
				a.attr('tabindex', key2+1)
			)
		)
		if $scope.eleFocus
			if $scope.eleFocus.focus
				$scope.eleFocus.focus()



	$scope.setTabHorizontally = ()->
		localStorage.tab_horiz_or_verti   = 'horizontal'
		$scope.tab_horiz_or_verti         = 'horizontal'
		filas                             = angular.element('.input-nota')

		angular.forEach(filas, (value, key)->
			a = angular.element(value);
			a.attr('tabindex', key+1)
		)
		if $scope.eleFocus
			$scope.eleFocus.focus()

	$scope.onInputFocus = ($event)->
		$scope.eleFocus = $event.currentTarget


	$scope.traerNotasDeAsignatura = (asignatura)->
		#$scope.$parent.bigLoader 	= true
		$state.go('.', {asignatura_id: asignatura.asignatura_id}, {notify: false});

		NotasServ.detalladas(asignatura.asignatura_id, asignatura.profesor_id, false).then((r)->
			$scope.asignatura		= r.asignatura
			$scope.alumnos			= r.alumnos
			$scope.unidades 		= r.unidades

			$scope.arreglarDatos()
			###
			$timeout(()->
				$scope.$parent.bigLoader 	= false
			, 500)
			###
		)

		for asignat in $scope.asignaturas
			asignat.active = false

		asignatura.active     = true
		$scope.asignatura_id  = asignatura.asignatura_id



	$scope.toggleHistorial = ()->
		$scope.historial_activado 			  = !$scope.historial_activado
		localStorage.historial_activado 	= $scope.historial_activado
		if $scope.historial_activado
			toastr.info 'Ahora dale doble click a la nota que quieres ver'



	$scope.seleccionarFila = (alumno)->
		for alum in $scope.alumnos
			alum.seleccionado = false
		alumno.seleccionado = true








	#####################################################################
	##############   AUSENCIAS Y TARDANZAS   ############################
	#####################################################################

	$scope.toggleAusencias = ()->
		$scope.ocultando_ausencias 			= !$scope.ocultando_ausencias
		localStorage.ocultando_ausencias 	= $scope.ocultando_ausencias

	$scope.cambiaAusencia = (alumno)->

		# Si incrementó el número
		if alumno.ausencias_count > alumno.ausencias.length
			pedidas = alumno.ausencias_count - alumno.ausencias.length

			for pedida in [0..pedidas-1]
				datos =
					alumno_id: 			alumno.alumno_id
					asignatura_id: 		$scope.asignatura_id
					cantidad_ausencia: 	1
				# fecha_hora = new Date(numYearActual, parseInt($scope.dato.mes), dia)

				$http.post('::ausencias/store', datos).then((r)->
					r 		= r.data
					#r.fecha_hora = new Date(r.fecha_hora)
					alumno.ausencias.push r
				, (r2)->
					toastr.warning 'No se pudo agregar ausencia.', 'Problema'
				)

		# Si bajó el número
		else if alumno.ausencias_count < alumno.ausencias.length
			pedidas = alumno.ausencias.length - alumno.ausencias_count

			for pedida in [0..pedidas-1]
				ausencia_id = alumno.ausencias[alumno.ausencias.length - pedida - 1].id

				$http.delete('::ausencias/destroy/' + ausencia_id).then((r)->
					r 		= r.data
					#r.fecha_hora = new Date(r.fecha_hora)
					alumno.ausencias = $filter('filter')(alumno.ausencias, { id: '!'+r.id })
				, (r2)->
					toastr.warning 'No se pudo quitar ausencia.', 'Problema'
				)




	$scope.cambiaTardanza = (alumno)->

		if alumno.tardanzas_count > alumno.tardanzas.length
			pedidas = alumno.tardanzas_count - alumno.tardanzas.length

			for pedida in [0..pedidas-1]
				datos =
					alumno_id: 			alumno.alumno_id
					asignatura_id: 		$scope.asignatura_id
					cantidad_tardanza: 	1
				# fecha_hora = new Date(numYearActual, parseInt($scope.dato.mes), dia)

				$http.post('::ausencias/store', datos).then((r)->
					r 		= r.data
					#r.fecha_hora = new Date(r.fecha_hora)
					alumno.tardanzas.push r
				, (r2)->
					toastr.warning 'No se pudo agregar tardanza.', 'Problema'
				)

		# Si bajó el número
		else if alumno.tardanzas_count < alumno.tardanzas.length
			pedidas = alumno.tardanzas.length - alumno.tardanzas_count

			for pedida in [0..pedidas-1]
				tardanza_id = alumno.tardanzas[alumno.tardanzas.length - pedida - 1].id

				$http.delete('::ausencias/destroy/' + tardanza_id).then((r)->
					r 		= r.data
					#r.fecha_hora = new Date(r.fecha_hora)
					alumno.tardanzas = $filter('filter')(alumno.tardanzas, { id: '!'+r.id })
				, (r2)->
					toastr.warning 'No se pudo quitar tardanza.', 'Problema'
				)



	$scope.clickAusenciaObject = (ausencia, alumno)->
		ausencia.backup 		= ausencia.fecha_hora
		if ausencia.fecha_hora
			ausencia.fecha_hora 	= new Date(ausencia.fecha_hora)
		else
			ausencia.fecha_hora 	= new Date()
		$scope.ausencia_edit 	  = ausencia
		$scope.alumno_aus_tard_edit 	= alumno
		ausencia.isOpen = !ausencia.isOpen


	$scope.clickTardanzaObject = (tardanza, alumno)->
		tardanza.backup 		= tardanza.fecha_hora
		if tardanza.fecha_hora
			tardanza.fecha_hora 	= new Date(tardanza.fecha_hora)
		else
			tardanza.fecha_hora 	= new Date()
		$scope.tardanza_edit 	= tardanza
		$scope.alumno_aus_tard_edit 	= alumno
		tardanza.isOpen = !tardanza.isOpen



	$scope.guardarCambioAusencia = (ausencia)->
		datos =
			ausencia_id: ausencia.id
			fecha_hora: $filter('date')(ausencia.fecha_hora, 'yyyy-MM-dd HH:mm:ss')

		$http.put('::ausencias/guardar-cambios-ausencia', datos).then((r)->
			r 		= r.data
			#r.fecha_hora = new Date(r.fecha_hora)
			alumno.tardanzas.push r
			$scope.ausencia_edit.isOpen = false
			$scope.tardanza_edit.isOpen = false
		, (r2)->
			toastr.warning 'No se pudo agregar tardanza.', 'Problema'
		)


	$scope.cancelarCambioAusencia = (ausencia_edit)->
		ausencia_edit.isOpen = false
	$scope.cancelarCambioTardanza = (tardanza_edit)->
		tardanza_edit.isOpen = false

	$scope.eliminarAusencia = (ausencia, alumno_aus_tard_edit)->
		$http.delete('::ausencias/destroy/' + ausencia.id).then((r)->
			r 		= r.data
			alumno_aus_tard_edit.ausencias = $filter('filter')(alumno_aus_tard_edit.ausencias, { id: '!'+r.id })
			ausencia.isOpen = false
		, (r2)->
			toastr.warning 'No se pudo quitar ausencia.', 'Problema'
		)

	$scope.eliminarTardanza = (tardanza, alumno_aus_tard_edit)->
		$http.delete('::ausencias/destroy/' + tardanza.id).then((r)->
			r 		= r.data
			alumno_aus_tard_edit.tardanzas = $filter('filter')(alumno_aus_tard_edit.tardanzas, { id: '!'+r.id })
			tardanza.isOpen = false
		, (r2)->
			toastr.warning 'No se pudo quitar tardanza.', 'Problema'
		)








	#####################################################################
	######################      NOTAS       #############################
	#####################################################################


	$scope.cambiaNotaDef = (alumno, nota, nf_id)->

		if nota > $scope.escala_maxima.porc_final or nota == 'undefined' or nota == undefined
			toastr.error 'No puede ser mayor de ' + $scope.escala_maxima.porc_final, 'NO guardada', {timeOut: 8000}
			return
		$http.put('::definitivas_periodos/update', {nf_id: nf_id, nota: nota}).then((r)->
			if !alumno.nota_final.manual
				alumno.nota_final.manual = 1
			toastr.success 'Cambiada: ' + nota
		, (r2)->
			if r2.status == 400
				toastr.warning 'Parece que no tienes permisos', 'Lo sentimos'
			else
				toastr.error 'No pudimos guardar la nota ' + nota, '', {timeOut: 8000}
		)

	$scope.toggleNotaFinalRecuperada = (alumno, recuperada, nf_id)->
		$http.put('::definitivas_periodos/toggle-recuperada', {nf_id: nf_id, recuperada: recuperada}).then((r)->

			if recuperada and !alumno.nota_final.manual
				alumno.nota_final.manual = 1
				toastr.success 'Indicará que es recuperada, así que también será manual.'
			else if recuperada
				toastr.success 'Recuperada'
			else
				toastr.success 'No recuperada'
		, (r2)->
			if r2.status == 400
				toastr.warning 'Parece que no tienes permisos', 'Lo sentimos'
			else
				toastr.error 'No pudimos cambiar.', '', {timeOut: 8000}
		)

	$scope.toggleNotaFinalManual = (alumno, manual, nf_id)->
		$http.put('::definitivas_periodos/toggle-manual', {nf_id: nf_id, manual: manual}).then((r)->

			if !manual and alumno.nota_final.recuperada
				alumno.nota_final.recuperada = false
				toastr.success 'Será automática y no recuperada.'
			else if manual
				toastr.success 'Nota manual.'
			else
				toastr.success 'Ahora la calculará el sistema.'
		, (r2)->
			if r2.status == 400
				toastr.warning 'Parece que no tienes permisos', 'Lo sentimos'
			else
				toastr.error 'No pudimos cambiar.', '', {timeOut: 8000}
		)




	$scope.cambiaNota = (nota, otra)->
		if nota.nota > $scope.escala_maxima.porc_final or nota.nota == 'undefined' or nota.nota == undefined
			toastr.error 'No puede ser mayor de ' + $scope.escala_maxima.porc_final, 'NO guardada', {timeOut: 8000}
			return
		$http.put('::notas/update/'+nota.id, {nota: nota.nota}).then((r)->
			toastr.success 'Cambiada: ' + nota.nota
			nota.updated_at = nota.updated_at
		, (r2)->
			if r2.status == 400
				toastr.warning 'Parece que no tienes permisos', 'Lo sentimos'
			else
				toastr.error 'No pudimos guardar la nota ' + nota.nota, '', {timeOut: 8000}
		)


	$scope.showFrases = (alumno)->

		modalInstance = $modal.open({
			templateUrl: '==notas/showFrases.tpl.html'
			controller: 'ShowFrasesCtrl'
			size: 'lg'
			resolve:
				alumno: ()->
					alumno
				frases: ()->
					$http.get('::frases')
				asignatura: ()->
					$scope.asignatura
				USER: ()->
					$scope.USER
		})
		modalInstance.result.then( (datos)->
			alumno.frases = datos.frases_asignatura
		(res)->
			console.log res
		)


	$scope.promedioTotal = (alumno)->

		acumSub = 0

		for nota in alumno.notas
			valorNota   = nota.nota * nota.subunidad_porc * nota.unidad_porc
			acumSub     = acumSub + valorNota

		alumno.total_definit = parseInt($filter('number')(acumSub, 0))
		return $filter('number')(acumSub, 1)



	$scope.verDetalleNota = (notaObject, alumno)->
		if !$scope.historial_activado
			return

		modalInstance = $modal.open({
			templateUrl: '==notas/notaDetalleModal.tpl.html'
			controller: 'NotaDetalleModalCtrl'
			resolve:
				alumno: ()->
					alumno
				nota: ()->
					notaObject
		})
		modalInstance.result.then( (r)->
			if r=='Eliminada'
				notaObject.eliminada = true
		, ()->
			# nada
		)
		return


	$scope.verifClickNotaRapida = (notaObject)->

		$timeout(()->
			if $rootScope.notaRapida.enable
				if notaObject.backup
					if $rootScope.notaRapida.valorNota != notaObject.nota
						notaObject.backup = notaObject.nota
						notaObject.nota = $rootScope.notaRapida.valorNota
					else
						temp = notaObject.backup
						notaObject.backup = notaObject.nota
						notaObject.nota = temp
				else
					notaObject.backup = notaObject.nota
					notaObject.nota = $rootScope.notaRapida.valorNota

				$scope.cambiaNota(notaObject)

		)
		return


	$scope.columnaNotaRapida = (subunidad_id)->

		$timeout(()->

			if $rootScope.notaRapida.enable
				for alumno in $scope.alumnos
					for nota in alumno.notas
						if nota.subunidad_id == subunidad_id
							if nota.backup
								if $rootScope.notaRapida.valorNota != nota.nota
									nota.backup   = nota.nota
									nota.nota     = $rootScope.notaRapida.valorNota
								else
									temp 				= nota.backup
									nota.backup = nota.nota
									nota.nota 	= temp
							else
								nota.backup 	= nota.nota
								nota.nota 		= $rootScope.notaRapida.valorNota

							contadorGuardadas = 0
							$http.put('::notas/update/'+nota.id, {nota: nota.nota}).then((r)->
								# Toca hacerlo con promesa
								contadorGuardadas = contadorGuardadas + 1
								if contadorGuardadas == ($scope.alumnos.length-1)
									toastr.success (contadorGuardadas + 1) + ' notas guardadas.'
							, (r2)->
								toastr.error 'No pudimos guardar la nota ' + nota.nota, '', {timeOut: 8000}
							)
			else
				toastr.info 'Activa la Nota Rápida para cambiar todas las notas de esta columna.'
		)
		return



	$scope.filaNotaRapida = (alumno, $index)->

		$timeout(()->
			if $rootScope.notaRapida.enable

				for notaObject in alumno.notas

					if notaObject.backup
						if $rootScope.notaRapida.valorNota != notaObject.nota
							notaObject.backup 	= notaObject.nota
							notaObject.nota 		= $rootScope.notaRapida.valorNota
						else
							temp 							= notaObject.backup
							notaObject.backup = notaObject.nota
							notaObject.nota 	= temp
					else
						notaObject.backup = notaObject.nota
						notaObject.nota = $rootScope.notaRapida.valorNota

					contadorGuardadas = 0
					$http.put('::notas/update/'+notaObject.id, {nota: notaObject.nota}).then((r)->
						# Toca hacerlo con promesa
						contadorGuardadas = contadorGuardadas + 1
						if contadorGuardadas == (alumno.notas.length-1)
							toastr.success (contadorGuardadas + 1) + ' notas guardadas.'
					, (r2)->
						toastr.error 'No pudimos guardar la nota ' + notaObject.nota, '', {timeOut: 8000}
					)
			else
				toastr.info 'Activa la Nota Rápida para cambiar todas las notas de este alumno.'

		)
		return
		$timeout(()->
			if $rootScope.notaRapida.enable

				for subunidad in $scope.subunidadesunidas

					notaObject = subunidad.notas[$index]

					if notaObject.backup
						if $rootScope.notaRapida.valorNota != notaObject.nota
							notaObject.backup = notaObject.nota
							notaObject.nota = $rootScope.notaRapida.valorNota
						else
							temp = notaObject.backup
							notaObject.backup = notaObject.nota
							notaObject.nota = temp
					else
						notaObject.backup = notaObject.nota
						notaObject.nota = $rootScope.notaRapida.valorNota

					contadorGuardadas = 0
					$http.put('::notas/update/'+notaObject.id, {nota: notaObject.nota}).then((r)->
						# Toca hacerlo con promesa
						contadorGuardadas = contadorGuardadas + 1
						if contadorGuardadas == ($scope.subunidadesunidas.length-1)
							toastr.success (contadorGuardadas + 1) + 'Notas guardadas.'
					, (r2)->
						toastr.error 'No pudimos guardar la nota ' + notaObject.nota, '', {timeOut: 8000}
					)
			else
				toastr.info 'Activa la Nota Rápida para cambiar todas las notas de este alumno.'

		)
		return

	return
])


.controller('ShowFrasesCtrl', ['$scope', '$uibModalInstance', 'alumno', 'frases', 'asignatura', '$http', 'toastr', '$filter', 'USER', 'AuthService', ($scope, $modalInstance, alumno, frases, asignatura, $http, toastr, $filter, USER, AuthService)->
	$scope.alumno     		= alumno
	$scope.frases     		= frases.data
	$scope.asignatura 		= asignatura
	$scope.USER       		= USER
	$scope.hasRoleOrPerm  = AuthService.hasRoleOrPerm

	$scope.alumno.newFrase = ''


	$http.get('::frases_asignatura/show/'+alumno.alumno_id+'/'+asignatura.asignatura_id).then((r)->
		$scope.frases_asignatura = r.data
	, (r2)->
		toastr.warning 'No se pudo traer frases.', 'Problema'
	)



	$scope.addFrase = ()->

		if $scope.alumno.newFrase != ''
			dato =
				alumno_id:		alumno.alumno_id
				frase:			$scope.alumno.newFrase
				asignatura_id:	$scope.asignatura.asignatura_id

			$http.post('::frases_asignatura/store', dato).then((r)->
				$scope.frases_asignatura = r.data
				toastr.success 'Frase añadida.'
			, (r2)->
				toastr.warning 'No se pudo añadir frase.', 'Problema'
			)
		else
			toastr.warning 'No ha copiado ninguna frase'


	$scope.addFrase_id = ()->

		if $scope.alumno.newFrase_by_id
			dato =
				alumno_id:		alumno.alumno_id
				frase_id:		$scope.alumno.newFrase_by_id.id
				asignatura_id:	$scope.asignatura.asignatura_id

			$http.post('::frases_asignatura/store/'+$scope.alumno.newFrase_by_id.id, dato).then((r)->
				toastr.success 'Frase añadida.'
				$scope.frases_asignatura = r.data
			, (r2)->
				toastr.warning 'No se pudo añadir frase.', 'Problema'
			)
		else
			toastr.warning 'No ha seleccionado frase'


	$scope.quitarFrase = (fraseasig)->
		$http.delete('::frases_asignatura/destroy/'+fraseasig.id).then((r)->
			toastr.success 'Frase quitada'
			$scope.frases_asignatura = $filter('filter')($scope.frases_asignatura, {id: '!'+fraseasig.id})
		, (r2)->
			toastr.warning 'No se pudo quitar la frase.', 'Problema'
		)


	$scope.ok = ()->
		$modalInstance.close({alumno: alumno, frases_asignatura: $scope.frases_asignatura})


	$scope.$on('modal.closing', (event, reason, closed)->
		switch (reason)
			# clicked outside
			when "backdrop click"
				$modalInstance.close({alumno: alumno, frases_asignatura: $scope.frases_asignatura})
				event.preventDefault();

			# cancel button
			when "cancel"
				$modalInstance.close({alumno: alumno, frases_asignatura: $scope.frases_asignatura})
				event.preventDefault();

			# escape key
			when "escape key press"
				$modalInstance.close({alumno: alumno, frases_asignatura: $scope.frases_asignatura})
				event.preventDefault();


	)

])



.controller('NotaDetalleModalCtrl', ['$scope', '$uibModalInstance', 'alumno', 'nota', 'AuthService', '$http', 'toastr', '$filter', ($scope, $modalInstance, alumno, nota, AuthService, $http, toastr, $filter)->
	$scope.alumno         = alumno
	$scope.nota     	    = nota
	$scope.hasRoleOrPerm  = AuthService.hasRoleOrPerm

	$http.put('::historiales/nota-detalle', {nota_id: nota.id}).then((r)->
		$scope.cambios        = r.data.cambios
		$scope.nota_detalle   = r.data.nota
	, (r2)->
		toastr.warning 'No se pudo traer el historial.', 'Problema'
	)



	$scope.eliminarNota = ()->

			$http.delete('::notas/destroy/' + nota.id).then((r)->
				toastr.success 'Nota eliminada', 'Puede recargar y será creada de nuevo'
				$modalInstance.close('Eliminada')
			, (r2)->
				toastr.error 'No se pudo eliminar nota.', 'Problema'
			)


	$scope.ok = ()->
		$modalInstance.close(alumno)


])



