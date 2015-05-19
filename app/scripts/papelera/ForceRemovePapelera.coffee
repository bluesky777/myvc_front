angular.module("myvcFrontApp")

.controller('ForceRemoveAlumnoCtrl', ['$scope', '$modalInstance', 'alumno', 'Restangular', 'toastr', ($scope, $modalInstance, alumno, Restangular, toastr)->
	$scope.alumno = alumno

	$scope.ok = ()->

		Restangular.all('alumnos/forcedelete/'+alumno.alumno_id).remove().then((r)->
			toastr.success 'Alumno eliminado con éxito.', 'Eliminado'
		, (r2)->
			toastr.warning 'No se pudo eliminar al alumno.', 'Problema'
			console.log 'Error eliminando alumno: ', r2
		)
		$modalInstance.close(alumno)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])

.controller('ForceRemoveGrupoCtrl', ['$scope', '$modalInstance', 'grupo', 'Restangular', 'toastr', ($scope, $modalInstance, grupo, Restangular, toastr)->
	$scope.grupo = grupo

	$scope.ok = ()->

		Restangular.all('grupos/forcedelete/'+grupo.id).remove().then((r)->
			toastr.success 'Grupo eliminado con éxito.', 'Eliminado'
		, (r2)->
			toastr.warning 'No se pudo eliminar al grupo.', 'Problema'
			console.log 'Error eliminando grupo: ', r2
		)
		$modalInstance.close(grupo)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])

.controller('ForceRemoveUnidadCtrl', ['$scope', '$modalInstance', 'unidad', 'Restangular', 'toastr', ($scope, $modalInstance, unidad, Restangular, toastr)->
	$scope.unidad = unidad

	$scope.ok = ()->

		Restangular.all('unidades/forcedelete/'+unidad.id).remove().then((r)->
			toastr.success 'Unidad eliminada con éxito.', 'Eliminado'
		, (r2)->
			toastr.warning 'No se pudo eliminar la unidad.', 'Problema'
			console.log 'Error eliminando unidad: ', r2
		)
		$modalInstance.close(unidad)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])
