angular.module('myvcFrontApp')

.directive('editNotasMatYearDir',['App', 'Perfil', (App, Perfil)-> 

	restrict: 'EA'
	templateUrl: "#{App.views}informes/editNotasMatYearDir.tpl.html"
	scope: 
		asignatura: "="
		alumno: "="
		alumnosasigs: "="


	controller: ($scope, App, Restangular, EscalasValorativasServ, AuthService, toastr)->

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

		Restangular.one('editnota/alum-asignatura').customPUT(datos).then((r)->
			$scope.periodos_materia = r
		, (r2)->
			console.log r2
		)




		$scope.cambiaNota = (nota, otra)->
			console.log nota, otra
			Restangular.one('notas/update', nota.id).customPUT({nota: nota.nota}).then((r)->
				toastr.success 'Cambiada: ' + nota.nota
				console.log 'Cuando la nota cambia, el objeto nota: ', nota
			, (r2)->
				console.log 'No pudimos guardar la nota ', nota
				toastr.error 'No pudimos guardar la nota ' + nota.nota
			)


	

])






