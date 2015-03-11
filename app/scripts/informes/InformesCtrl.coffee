angular.module('myvcFrontApp')
.controller('InformesCtrl', ['$scope', 'Restangular', '$state', '$rootScope', '$filter', 'App', 'AuthService', 'GruposServ', '$timeout', ($scope, Restangular, $state, $rootScope, $filter, App, AuthService, GruposServ, $timeout) ->

	AuthService.verificar_acceso()
	$scope.rowsAlum = [] 

	$scope.datos = {grupo: ''}


	GruposServ.getGrupos().then((r)->
		$scope.grupos = r
	)

	$scope.verBoletines = ()->

		Restangular.one('alumnos/detailed-notas', $scope.datos.grupo.id).getList().then((r)->
			$scope.alumnos = r
			for alum in $scope.alumnos
				$scope.rowsAlum.push alum
			
		, (r2)->
			console.log 'No se trajo los alumnos', r2
		)

	$scope.pdfMaker = ()->
		
		docDefinition = {
			content: [
				['Este es un ejemplo de reporte en pdf'],
				{
					table: {
						headerRows: 1,
						widths: [ '*', 'auto', 100, '*' ],

						body: [
								[ 'No', 'Primero', 'Segundo', 'Tercero' ],
								[ '0', 'No me gusta!!', 'No queda bonito', 'FACILMENTE!' ],
								[ '1', { text: 'En negrita', bold: true }, 'Así que ', 'me mordió la vaca' ]
							]
					}
				}
			]
		}

		pdfMake.createPdf(docDefinition).open()

	
])