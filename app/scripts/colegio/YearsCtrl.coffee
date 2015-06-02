'use strict'

angular.module('myvcFrontApp')
.controller('YearsCtrl', ['App', '$scope', '$http', 'Restangular', '$modal', '$state', '$cookies', '$rootScope', 'RYears', '$filter', 'toastr', 
	(App, $scope, $http, Restangular, $modal, $state, $cookies, $rootScope, RYears, $filter, toastr) ->

		RYears.getList().then((r)->
			$scope.years = r
		, (r)->
			console.log 'No se trajeron los años'
		)


		$scope.newcertif = {}

		
		$scope.addPeriodo = (year)->

			modalInstance = $modal.open({
			templateUrl: App.views + 'colegio/addPeriodo.tpl.html'
			controller: 'AddPeriodoCtrl'
			resolve: 
				year: ()->
					year
			})
			modalInstance.result.then( (periodo)->
				year.periodos.push periodo
			)

		
		
		$scope.removePeriodo = (year, periodo)->

			modalInstance = $modal.open({
			templateUrl: App.views + 'colegio/removePeriodo.tpl.html'
			controller: 'RemovePeriodoCtrl'
			resolve: 
				periodo: ()->
					periodo
			})
			modalInstance.result.then( (periodo)->
				year.periodos = $filter('filter')(year.periodos, {id: '!'+periodo.id})
			)


		
		$scope.actualPeriodo = (periodo)->

			Restangular.one('periodos/establecer-actual', periodo.id).customPUT().then((r)->
				toastr.success 'Periodo ' + periodo.numero + ' establecido como actual.'
			, (r2)->
				toastr.warning 'No se pudo establecer como actual.', 'Problema'
				console.log 'No se pudo establecer como actual: ', r2
			)




		return



	]
)


.controller('RemovePeriodoCtrl', ['$scope', '$modalInstance', 'periodo', 'Restangular', 'toastr', ($scope, $modalInstance, periodo, Restangular, toastr)->
	$scope.periodo = periodo

	$scope.ok = ()->

		Restangular.all('periodos/destroy/'+periodo.id).remove().then((r)->
			toastr.success 'Priodo eliminado con éxito.', 'Eliminado'
			$modalInstance.close(periodo)
		, (r2)->
			toastr.warning 'No se pudo eliminar el periodo.', 'Problema'
			console.log 'Error eliminando periodo: ', r2
			$modalInstance.dismiss()
		)
		

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])

.controller('AddPeriodoCtrl', ['$scope', '$modalInstance', 'year', 'Restangular', 'toastr', ($scope, $modalInstance, year, Restangular, toastr)->
	$scope.year = year

	$scope.new_periodo = {}
	$scope.year_id = $scope.year.id


	$scope.ok = ()->

		Restangular.one('periodos/store', year.id).customPOST($scope.new_periodo).then((r)->
			toastr.success 'Periodo creado con éxito.', 'Creado'
			$modalInstance.close($scope.new_periodo)
		, (r2)->
			toastr.warning 'No se pudo crear el periodo.', 'Problema'
			console.log 'Error creando periodo: ', r2
			$modalInstance.dismiss()
		)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])
