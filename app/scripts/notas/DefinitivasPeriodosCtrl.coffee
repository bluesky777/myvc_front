'use strict'

angular.module('myvcFrontApp')
.controller('DefinitivasPeriodosCtrl', ['$scope', 'toastr', '$http', '$uibModal', '$state', '$rootScope', '$filter', 'App', 'AuthService', '$timeout', ($scope, toastr, $http, $modal, $state, $rootScope, $filter, App, AuthService, $timeout) ->

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
	$scope.opts_picker 		= { minDate: new Date('1/1/2017'), showWeeks: false, startingDay: 0 }


	$scope.$parent.bigLoader 	= false






	#####################################################################
	######################      NOTAS       #############################
	#####################################################################


	$scope.cambiaNotaDef = (nota, otra)->
		$http.put('::notas/update/'+nota.id, {nota: nota.nota}).then((r)->
			toastr.success 'Cambiada: ' + nota.nota
		, (r2)->
			toastr.error 'No pudimos guardar la nota ' + nota.nota, '', {timeOut: 8000}
		)



	$scope.promedioTotalDef = (alumno_id)->
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


	return
])



