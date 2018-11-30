'use strict'

angular.module("myvcFrontApp")

.controller('VerTodosLosCertificadosCtrl', ['$scope', 'App', '$state', '$interval', '$uibModal', '$filter', 'AuthService', 'toastr', '$http', ($scope, App, $state, $interval, $modal, $filter, AuthService, toastr, $http)->

	AuthService.verificar_acceso()

	console.log($state)
	$http.put('::certificados-persona', {alumno_id: $state.params.alumno_id}).then((r)->
		console.log(r.data)
		$scope.certificados = r.data
	, (r2)->
		toastr.error 'No se pudo traer los requisitos'
	)


	return
])
