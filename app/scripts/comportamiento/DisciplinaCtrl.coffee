'use strict'

angular.module('myvcFrontApp')

.controller('DisciplinaCtrl', ['$scope', 'toastr', '$http', '$uibModal', '$state', '$filter', 'App', 'AuthService', 'escalas', 'EscalasValorativasServ', 'ComportamientoServ', 'ProfesoresServ', ($scope, toastr, $http, $modal, $state, $filter, App, AuthService, escalas, EscalasValorativasServ, ComportamientoServ, ProfesoresServ)->

	AuthService.verificar_acceso()

	$scope.perfilPath 	  	= App.images+'perfil/'
	$scope.views 		      	= App.views
	$scope.nota_minima_aceptada = parseInt($scope.USER.nota_minima_aceptada)
	$scope.escalas 					= escalas
	$scope.escala_maxima 		= EscalasValorativasServ.escala_maxima()
	$scope.datos 		      	= {
		grupo: ''
	}


	$scope.toggleMostrarDetalle = (alumno, prop)->
		alumno[prop] = !alumno[prop]


	$scope.traerProceso = ()->
		grupo_id = $scope.datos.grupo.id

		$http.put('::disciplina/alumnos', {grupo_id: grupo_id}).then((r)->
			$scope.alumnos = r.data.alumnos
		, (r2)->
			toastr.error('No se trajo los alumnos')
		)


	$scope.crearFalta = (alumno, periodo, per_num)->

		modalInstance = $modal.open({
			templateUrl: '==comportamiento/crearFaltaModal.tpl.html'
			controller: 'CrearFaltaCtrl'
			size: 'lg'
			scope: $scope
			resolve:
				alumno: ()->
					alumno
				per_num: ()->
					per_num
				periodos: ()->
					$scope.periodos
				config: ()->
					$scope.config
				profesores: ()->
					$scope.profesores
				ordinales: ()->
					$scope.ordinales
				creando: ()->
					true
		})
		modalInstance.result.then( (ficha)->
			#console.log($scope.alumnos)
		, ()->
			#console.log($scope.alumnos)
		)



	$scope.verFaltasModal = (alumno, periodo, per_num, tipo_falta_num)->

		modalInstance = $modal.open({
			templateUrl: '==comportamiento/crearFaltaModal.tpl.html'
			controller: 'CrearFaltaCtrl'
			size: 'lg'
			scope: $scope
			resolve:
				alumno: ()->
					alumno
				per_num: ()->
					per_num
				periodos: ()->
					$scope.periodos
				config: ()->
					$scope.config
				profesores: ()->
					$scope.profesores
				ordinales: ()->
					$scope.ordinales
				creando: ()->
					false
		})
		modalInstance.result.then( (ficha)->
			#console.log($scope.alumnos)
		, ()->
			#console.log($scope.alumnos)
		)




	$http.put('::grupos/con-disciplina').then((r)->

		matr_grupo = 0

		if localStorage.matr_grupo
			matr_grupo = parseInt(localStorage.matr_grupo)

		$scope.grupos 		= r.data.grupos
		$scope.config 		= r.data.config
		$scope.ordinales 	= r.data.ordinales

		for grupo in $scope.grupos
			if grupo.id == matr_grupo
				$scope.datos.grupo = grupo
				grupo.active = true

		$scope.traerProceso()

	, ()->
		toastr.error('No se pudo traer los grupos y datos')
	)

	ProfesoresServ.contratos().then((r)->
		$scope.profesores = r
	, (r2)->
		toastr.error 'No se pudo traer los profesores.'
	)


	$scope.selectGrupo = (grupo)->
		localStorage.matr_grupo = grupo.id
		$scope.datos.grupo 		= grupo

		for grup in $scope.grupos
			grup.active = false

		grupo.active = true

		$scope.traerProceso()






])


