'use strict'

angular.module('myvcFrontApp')
.controller('NotasCtrl', ['$scope', 'toastr', '$http', '$uibModal', '$state', 'notas', '$rootScope', '$filter', 'App', 'AuthService', '$timeout', ($scope, toastr, $http, $modal, $state, notas, $rootScope, $filter, App, AuthService, $timeout) ->

	AuthService.verificar_acceso()

	$scope.asignatura 	= {}
	$scope.asignatura_id = $state.params.asignatura_id
	$scope.datos 		= {}
	$scope.UNIDAD 		= $scope.USER.unidad_displayname
	$scope.SUBUNIDAD 	= $scope.USER.subunidad_displayname
	$scope.UNIDADES 	= $scope.USER.unidades_displayname
	$scope.SUBUNIDADES 	= $scope.USER.subunidades_displayname
	$scope.perfilPath 	= App.images+'perfil/'
	$scope.views 		= App.views
	$scope.nota_minima_aceptada = parseInt($scope.USER.nota_minima_aceptada)
	$scope.ocultando_ausencias 	= true
	$scope.ausencia_edit 	= {} # Para editar en el popover
	$scope.tardanza_edit 	= {}
	$scope.alumno_aus_tard_edit 	= {}
	$scope.opts_picker 		= { minDate: new Date('1/1/2017'), showWeeks: false, startingDay: 0 }

	$scope.asignatura 	= notas[0]
	$scope.alumnos 		= notas[1]
	$scope.unidades 	= notas[2]

	$scope.subunidadesunidas = []



	# Las Subunidades están en cada Unidad. Necesito agregarlas juntas en un solo Array
	for unidad in $scope.unidades

		if unidad.subunidades.length == 0
			$scope.subunidadesunidas.push {empty: true}

		for subunidad in unidad.subunidades
			$scope.subunidadesunidas.push subunidad


	if localStorage.ocultando_ausencias
		$scope.ocultando_ausencias = (localStorage.ocultando_ausencias == 'true')



	for alumno in $scope.alumnos
		for ausencia in alumno.ausencias
			if ausencia.fecha_hora
				ausencia.fecha_hora = new Date(ausencia.fecha_hora)
		for tardanza in alumno.tardanzas
			if tardanza.fecha_hora
				tardanza.fecha_hora = new Date(tardanza.fecha_hora)

	$scope.$parent.bigLoader 	= false

	$scope.setTabVertically = ()->
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
		filas = angular.element('.input-nota')

		angular.forEach(filas, (value, key)->
			a = angular.element(value);
			a.attr('tabindex', key+1)
		)
		$scope.eleFocus.focus()

	$scope.onInputFocus = ($event)->
		$scope.eleFocus = $event.currentTarget







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


	$scope.cambiaNota = (nota, otra)->
		$http.put('::notas/update/'+nota.id, {nota: nota.nota}).then((r)->
			toastr.success 'Cambiada: ' + nota.nota
		, (r2)->
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
		})
		modalInstance.result.then( (alum)->
			#console.log 'Resultado del modal: ', alum
		)


	$scope.promedioTotal = (alumno_id)->
		$scope.subunidadesunidas

		acumUni = 0
		for unidad in $scope.unidades

			porcUni = unidad.porcentaje
			acumSub = 0

			for subunidad in unidad.subunidades

				porcSub = subunidad.porcentaje
				#console.log subunidad.notas, alumno_id, $filter('filter')(subunidad.notas, {'alumno_id': alumno_id})[0]

				notaTemp = $filter('filter')(subunidad.notas, {'alumno_id': alumno_id}, true)[0]
				valorNota = parseInt(notaTemp.nota) * parseInt(porcSub) / 100
				acumSub = acumSub + valorNota

			valorUni = acumSub * parseInt(porcUni) / 100
			acumUni = acumUni + valorUni

		return $filter('number')(acumUni, 1);


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


	$scope.columnaNotaRapida = (subunidad)->

		$timeout(()->
			if $rootScope.notaRapida.enable
				for notaObject, indice in subunidad.notas

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
						if contadorGuardadas == (subunidad.notas.length-1)
							toastr.success (contadorGuardadas + 1) + ' notas guardadas.'
					, (r2)->
						toastr.error 'No pudimos guardar la nota ' + notaObject.nota, '', {timeOut: 8000}
					)
			else
				toastr.info 'Activa la Nota Rápida para cambiar todas las notas de esta columna.'

		)
		return


	$scope.filaNotaRapida = (alumno, $index)->

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


.controller('ShowFrasesCtrl', ['$scope', '$uibModalInstance', 'alumno', 'frases', 'asignatura', '$http', 'toastr', '$filter', ($scope, $modalInstance, alumno, frases, asignatura, $http, toastr, $filter)->
	$scope.alumno = alumno
	$scope.frases = frases.data
	$scope.asignatura = asignatura

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
		$modalInstance.close(alumno)


])



