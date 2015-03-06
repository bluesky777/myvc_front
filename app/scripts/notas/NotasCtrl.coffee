'use strict'

angular.module('myvcFrontApp')
.controller('NotasCtrl', ['$scope', 'toastr', 'Restangular', '$state', 'notas', '$rootScope', '$filter', 'App', 'AuthService', ($scope, toastr, Restangular, $state, notas, $rootScope, $filter, App, AuthService) ->

	AuthService.verificar_acceso()

	$scope.asignatura = {}
	$scope.asignatura_id = $state.params.asignatura_id
	$scope.datos = {}
	$scope.UNIDAD = $scope.USER.unidad_displayname
	$scope.SUBUNIDAD = $scope.USER.subunidad_displayname
	$scope.UNIDADES = $scope.USER.unidades_displayname
	$scope.SUBUNIDADES = $scope.USER.subunidades_displayname
	$scope.perfilPath = App.images+'perfil/'

	$scope.asignatura 	= notas[0]
	$scope.alumnos 		= notas[1]
	$scope.unidades 	= notas[2]

	$scope.subunidadesunidas = []




	for unidad in $scope.unidades

		if unidad.subunidades.length == 0
			$scope.subunidadesunidas.push {empty: true}

		for subunidad in unidad.subunidades
			$scope.subunidadesunidas.push subunidad

	console.log '$scope.subunidadesunidas ', $scope.subunidadesunidas


	$scope.traerSubunidad = (unidad)->



	$scope.cambiaNota = (nota)->
		Restangular.one('notas/update', nota.id).customPUT({nota: nota.nota}).then((r)->
			toastr.success 'Nota cambiada: ' + nota.nota
		, (r2)->
			console.log 'No pudimos guardar la nota ', nota
			toastr.error 'No pudimos guardar la nota ' + nota.nota
		)


	$scope.promedioTotal = (alumno_id)->
		$scope.subunidadesunidas

		acumUni = 0
		for unidad in $scope.unidades

			porcUni = unidad.porcentaje
			acumSub = 0

			for subunidad in unidad.subunidades

				porcSub = subunidad.porcentaje

				notaTemp = $filter('filter')(subunidad.notas, {'alumno_id': alumno_id})[0]
				valorNota = parseInt(notaTemp.nota) * parseInt(porcSub) / 100
				acumSub = acumSub + valorNota

			valorUni = acumSub * parseInt(porcUni) / 100
			acumUni = acumUni + valorUni

		return $filter('number')(acumUni, 2);


	#console.log Restangular.all('disciplinas').getList()
	return
])


.directive('celdasDefinicionesSubunidades', ['App', (App)-> 

	restrict: 'A'
	template: '<th ng-repeat="subunidad in subunidades" ><div class="text-center nombresellipsis" tooltip="{{subunidad.porcentaje}}% {{subunidad.definicion}}" tooltip-popup-delay="1000"> {{$index + 1}}</div></th>'
	transclude: true
	scope: 
		celdasDefinicionesSubunidades: "="

	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if
		console.log 'Entré a la directiva. ', scope.celdasDefinicionesSubunidades
		scope.subunidades = scope.celdasDefinicionesSubunidades.subunidades

])


