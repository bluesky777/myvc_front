'use strict'

angular.module("myvcFrontApp")


.controller('CambiarNotaModalCtrl', ['$scope', 'App', '$uibModalInstance', 'alumno', 'subunidad', 'nota', '$http', 'toastr', 'EscalasValorativasServ', ($scope, App, $modalInstance, alumno, subunidad, nota, $http, toastr, EscalasValorativasServ)->
	$scope.subunidad 				  = subunidad
	$scope.datos 				      = {}
	$scope.perfilPath 			  = App.images+'perfil/'
	$scope.alumno             = alumno
	$scope.nota               = nota


	EscalasValorativasServ.escalas().then((r)->
		$scope.escalas = r
	, (r2)->
		console.log 'No se trajeron las escalas valorativas', r2
	)



	$scope.cambiaNota = (n)->
		console.log(n)
		$http.put('::notas/update/'+nota.id, {nota: n}).then((r)->
			toastr.success 'Cambiada: ' + n
			nota.nota = n
			$modalInstance.close(nota.nota)
		, (r2)->
			if r2.status == 400
				toastr.warning 'Parece que no tienes permisos', 'Lo sentimos'
			else
				toastr.error 'No pudimos guardar la nota ' + nota.nota, '', {timeOut: 8000}
		)





	$scope.ok = ()->
		$modalInstance.close()


])




