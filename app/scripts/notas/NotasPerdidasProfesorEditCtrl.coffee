'use strict'

angular.module('myvcFrontApp')
.controller('NotasPerdidasProfesorEditCtrl', ['$scope', 'toastr', '$http', '$uibModal', '$state', '$filter', 'App', 'AuthService', ($scope, toastr, $http, $modal, $state, $filter, App, AuthService) ->

	AuthService.verificar_acceso()
	$scope.hasRoleOrPerm = AuthService.hasRoleOrPerm
	$scope.datos 		= {}
	$scope.grupos 		= []
	$scope.profesores 	= []
	$scope.perfilPath 	= App.images+'perfil/'
	$scope.views 		= App.views

	if AuthService.hasRoleOrPerm(['profesor'])
		$http.put('::notas-perdidas/profesor-grupos', {profesor_id: $scope.USER.persona_id, periodo_a_calcular: $scope.USER.numero_periodo}).then((r)->
			$scope.grupos = r.data
		, (r2)->
			toastr.error 'No se trajeron las notas'
		)
	else
		$http.get('::contratos').then((r)->
			$scope.profesores = r.data
		, (r2)->
			toastr.error 'No se trajeron los profesores'
		)

	$scope.verNotasPerdidasProfesor = ()->
		if $scope.datos.profesor
			$http.put('::notas-perdidas/profesor-grupos', {profesor_id: $scope.datos.profesor.profesor_id, periodo_a_calcular: 10}).then((r)->
				$scope.grupos = r.data
			, (r2)->
				toastr.error 'No se trajeron las notas'
			)
		else
			toastr.warning 'Debes elegir profesor'



	$scope.cambiaNota = (nota)->
		$http.put('::notas/update/' + nota.nota_id, {nota: nota.nota}).then((r)->
			r = r.data
			toastr.success 'Cambiada: ' + nota.nota
		, (r2)->
			toastr.error 'No pudimos guardar la nota ' + nota.nota, '', {timeOut: 8000}
		)


	return
])



