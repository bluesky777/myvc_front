'use strict'

angular.module("myvcFrontApp")

.controller('EditarActividadCtrl', ['$scope', 'App', '$rootScope', '$state', '$http', '$uibModal', '$filter', 'AuthService', 'datos', 'toastr', '$stateParams', '$timeout', '$location', '$anchorScroll', ($scope, App, $rootScope, $state, $http, $modal, $filter, AuthService, datos, toastr, $stateParams, $timeout, $location, $anchorScroll)->

	AuthService.verificar_acceso()

	$scope.actividad_id 	= $stateParams.actividad_id
	$scope.datos 			= { selected_grupos: [] }
	$scope.mostrando_detalles_actividad = true

	$scope.perfilPath 		= App.images + 'perfil/'
	$scope.views 			= App.views

	$scope.actividad 	= datos.actividad
	$scope.grupos 		= datos.grupos
	$scope.compartidas 	= datos.compartidas


	for compart in $scope.compartidas
		for grupo in $scope.grupos
			if grupo.id == compart.grupo_id
				$scope.datos.selected_grupos.push grupo



	if $scope.actividad.finaliza_at
		$scope.actividad.finaliza_at = new Date($scope.actividad.finaliza_at)
	else
		$scope.actividad.finaliza_at = new Date()
	
	if $scope.actividad.inicia_at
		$scope.actividad.inicia_at = new Date($scope.actividad.inicia_at)
	else
		$scope.actividad.inicia_at = new Date()

	$scope.actividad.para_alumnos 		= if $scope.actividad.para_alumnos 		then true else false
	$scope.actividad.para_profesores 	= if $scope.actividad.para_profesores 	then true else false
	$scope.actividad.para_acudientes 	= if $scope.actividad.para_acudientes 	then true else false
	
	$scope.editor_options = 
		allowedContent: true,
		entities: false



	$scope.restar = (modelo)->
		if $scope.actividad[modelo] > 0
			$scope.actividad[modelo] = $scope.actividad[modelo] - 1
	$scope.sumar = (modelo)->
		if $scope.actividad[modelo] < 1000
			$scope.actividad[modelo] = parseInt($scope.actividad[modelo]) + 1

	$scope.onEditorReady = ()->
		console.log 'Editor listo'

	addZero = (i)->
		if (i < 10)
			i = "0" + i;
		return i;


	$scope.ftime_to_string = (ftime)->
		h = addZero(ftime.getHours());
		m = addZero(ftime.getMinutes());
		s = addZero(ftime.getSeconds());
		d = ftime.yyyymmdd();
		res = d + "T" + h + ":" + m + ":" + s + ".000Z";

	$scope.guardarActividad = (salir)->
		finaliza_at 	= $scope.ftime_to_string($scope.actividad.finaliza_at)
		$scope.actividad.finaliza_at_str 	= finaliza_at
		inicia_at 		= $scope.ftime_to_string($scope.actividad.inicia_at)
		$scope.actividad.inicia_at_str 		= inicia_at

		$http.put('::actividades/guardar', $scope.actividad ).then((r)->
			r = r.data
			toastr.success 'Cambios guardados'
			
			if salir
				$state.go('panel.actividades', { asign_id: $scope.actividad.asignatura_id })

		(r2)->
			toastr.error 'No se pudo guardar cambios'
		)



	$scope.editar_pregunta = (pregunta)->
		$state.go('panel.editar_actividad', { actividad_id: $scope.actividad.id })
		localStorage.pregunta_edit = JSON.stringify(pregunta)
		
		$timeout ()->
			$state.go 'panel.editar_actividad.pregunta'

		
	$scope.crearPregunta = ()->
		datos = 
			actividad_id: $scope.actividad_id

		$http.post('::preguntas/crear', datos ).then((r)->
			r = r.data
			$scope.actividad.preguntas.push r
			$scope.editar_pregunta(r)
		(r2)->
			toastr.error 'No se pudo crear pregunta'
		)

	$scope.cambios_pregunta_guardados = (preg_editada)->
		$scope.actividad.preguntas = $filter('filter')($scope.actividad.preguntas, {id: '!'+preg_editada.id})
		$scope.actividad.preguntas.push preg_editada
		$scope.actividad.preguntas = $filter('orderBy')($scope.actividad.preguntas, 'orden')


		

	$scope.duplicar_pregunta = (pregunta)->
		pregunta.orden = $scope.actividad.preguntas.length
		$http.put('::preguntas/duplicar-pregunta', pregunta ).then((r)->
			r = r.data
			toastr.success 'Pregunta duplicada'
			$scope.actividad.preguntas.push r
			$timeout(()->
				$location.hash('end-preguntas');
				$anchorScroll();
			)
		(r2)->
			toastr.error 'No se pudo duplicar'
		)


	$scope.on_sort_preguntas = ($item, $partFrom, $partTo, $indexFrom, $indexTo)->
		
		sortHash = []

		for pregunta, index in $partFrom #subunidades
			pregunta.orden = index

			hashEntry = {}
			hashEntry["" + pregunta.id] = index
			sortHash.push(hashEntry)
		
		datos = 
			sortHash: sortHash
		
		$http.put('::preguntas/update-orden', datos).then((r)->
			return true
		, (r2)->
			toastr.warning 'No se pudo ordenar', 'Problema'
			return false;
		)


	$scope.para_alumnos_toggle = (para)->
		
		$http.put('::actividades/para-alumnos-toggle', {actividad_id: $scope.actividad.id, para_alumnos: para}).then((r)->
			if para
				toastr.success 'Debe haber al menos un grupo seleccionado'
			else
				toastr.info 'No la realizarán los alumnos'
		, (r2)->
			toastr.warning 'No se pudo guardar cambio', 'Problema'
			return false;
		)

	$scope.para_profesores_toggle = (para_prof)->
		
		$http.put('::actividades/para-profesores-toggle', {actividad_id: $scope.actividad.id, para_profesores: para_prof}).then((r)->
			if para_prof
				toastr.success 'La realizarán los docentes'
			else
				toastr.info 'No la realizarán los docentes'
		, (r2)->
			toastr.warning 'No se pudo guardar cambio', 'Problema'
			return false;
		)


	$scope.para_acudientes_toggle = (para)->
		
		$http.put('::actividades/para-acudientes-toggle', {actividad_id: $scope.actividad.id, para_acudientes: para}).then((r)->
			if para
				toastr.success 'La realizarán los acudientes'
			else
				toastr.info 'No la realizarán los acudientes'
		, (r2)->
			toastr.warning 'No se pudo guardar cambio', 'Problema'
			return false;
		)


	$scope.toggle_compartida = (compar)->
		
		$http.put('::actividades/set-compartida', {actividad_id: $scope.actividad.id, compartida: compar}).then((r)->
			toastr.success 'Compartida: ' + compar
		, (r2)->
			toastr.warning 'No se pudo establecer compartida', 'Problema'
			return false;
		)


	$scope.select_grupo_compartido = ($item)->
		
		$http.put('::actividades/insert-grupo-compartido', {actividad_id: $scope.actividad.id, grupo_id: $item.id}).then((r)->
			toastr.success 'Grupo agregado'
		, (r2)->
			toastr.warning 'No se pudo agregar grupo', 'Problema'
			return false;
		)


	$scope.quitando_grupo_compartido = ($item)->
		
		$http.put('::actividades/quitando-grupo-compartido', {actividad_id: $scope.actividad.id, grupo_id: $item.id}).then((r)->
			toastr.success 'Grupo quitado'
		, (r2)->
			toastr.warning 'No se pudo quitar grupo', 'Problema'
			return false;
		)

	$scope.ver_preguntas = ()->
		$scope.mostrando_preguntas = true
		$scope.mostrando_detalles_actividad = false

	$scope.ver_detalles_actividad = ()->
		$scope.mostrando_detalles_actividad = true

	return
])


