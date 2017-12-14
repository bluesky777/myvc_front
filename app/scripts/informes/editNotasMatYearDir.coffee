angular.module('myvcFrontApp')

.directive('editNotasMatYearDir',['App', 'Perfil', (App, Perfil)-> 

	restrict: 'EA'
	templateUrl: "==informes/editNotasMatYearDir.tpl.html"
	scope: 
		asignatura: "="
		alumno: "="
		alumnosasigs: "="


	controller: ($scope, App, $http, EscalasValorativasServ, AuthService, toastr)->

		$scope.USER = Perfil.User()
		$scope.USER.nota_minima_aceptada = parseInt($scope.USER.nota_minima_aceptada)
		$scope.perfilPath = App.images+'perfil/'


		$scope.periodos_materia = []

		$scope.solo_notas_perdidas = true
		$scope.hasRoleOrPerm = AuthService.hasRoleOrPerm
		

		EscalasValorativasServ.escalas().then((r)->
			$scope.escalas = r
		)


		datos = 
			alumno_id: $scope.alumno.alumno_id
			asignatura_id: $scope.asignatura.asignatura_id
			periodos_a_calcular: 'de_usuario'

		$http.put('::editnota/alum-asignatura', datos).then((r)->
			$scope.periodos_materia = r.data
		, (r2)->
			#console.log r2
		)




		$scope.cambiaNota = (nota, otra)->
			$http.put('::notas/update/'+nota.id, {nota: nota.nota}).then((r)->
				toastr.success 'Cambiada: ' + nota.nota
			, (r2)->
				toastr.error 'No pudimos guardar la nota ' + nota.nota
			)


	

])






