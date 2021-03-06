angular.module('myvcFrontApp')

.controller('ModalDetallesSesionCtrl', ['$scope', '$uibModalInstance', 'historial', '$http', 'toastr', 'App', '$filter', ($scope, $modalInstance, historial, $http, toastr, App, $filter)->

	$scope.imagesPath = App.images + 'perfil/'
	$scope.historial = historial

	if historial.logout_at
		desde = new Date(historial.created_at)
		hasta = new Date(historial.logout_at)

		duracion        = (hasta.getTime() - desde.getTime())

		milliseconds = parseInt((duracion%1000)/100)
		seconds = parseInt((duracion/1000)%60)
		minutes = parseInt((duracion/(1000*60))%60)
		hours = parseInt((duracion/(1000*60*60))%24);

		hours = if (hours < 10) then ("0" + hours) else hours;
		minutes = if (minutes < 10) then ("0" + minutes) else minutes;
		seconds = if (seconds < 10) then ("0" + seconds) else seconds;

		$scope.duracion = hours + ":" + minutes + ":" + seconds

	else
		$scope.duracion = 'No cerró sesión.'


	$scope.ok = ()->
		$modalInstance.close()



	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])


