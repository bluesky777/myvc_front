angular.module("myvcFrontApp")

.controller('ForceRemoveAlumnoCtrl', ['$scope', '$uibModalInstance', 'alumno', '$http', 'toastr', ($scope, $modalInstance, alumno, $http, toastr)->
	$scope.alumno = alumno

	$scope.ok = ()->

		$http.delete('::alumnos/forcedelete/'+alumno.alumno_id).then((r)->
			toastr.success 'Alumno eliminado con éxito.', 'Eliminado'
		, (r2)->
			toastr.warning 'No se pudo eliminar al alumno.', 'Problema'
		)
		$modalInstance.close(alumno)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])

.controller('ForceRemoveGrupoCtrl', ['$scope', '$uibModalInstance', 'grupo', '$http', 'toastr', ($scope, $modalInstance, grupo, $http, toastr)->
	$scope.grupo = grupo

	$scope.ok = ()->

		$http.delete('::grupos/forcedelete/'+grupo.id).then((r)->
			toastr.success 'Grupo eliminado con éxito.', 'Eliminado'
		, (r2)->
			toastr.warning 'No se pudo eliminar al grupo.', 'Problema'
		)
		$modalInstance.close(grupo)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])

.controller('ForceRemoveUnidadCtrl', ['$scope', '$uibModalInstance', 'unidad', '$http', 'toastr', ($scope, $modalInstance, unidad, $http, toastr)->
	$scope.unidad = unidad

	$scope.ok = ()->

		$http.delete('::unidades/forcedelete/'+unidad.id).then((r)->
			toastr.success 'Unidad eliminada con éxito.', 'Eliminado'
		, (r2)->
			toastr.warning 'No se pudo eliminar la unidad.', 'Problema'
		)
		$modalInstance.close(unidad)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])
