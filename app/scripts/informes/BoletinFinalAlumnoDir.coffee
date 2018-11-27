angular.module('myvcFrontApp')

.directive('boletinFinalAlumnoDir',['App', 'Perfil', (App, Perfil)->

	restrict: 'EA'
	templateUrl: "==informes/boletinFinalAlumnoDir.tpl.html"
	scope:
		grupo: "="
		year: "="
		alumno: "="
		config: "="
		escalas: "="

	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if

		scope.USER = Perfil.User()
		scope.USER.nota_minima_aceptada = parseInt(scope.USER.nota_minima_aceptada)
		scope.perfilPath = App.images+'perfil/'
		scope.views = App.views;

		#console.log scope.config.orientacion
])



.directive('boletinFinalAlumnoPreescolarDir',['App', 'Perfil', '$http', 'toastr', (App, Perfil, $http, toastr)->

	restrict: 'EA'
	templateUrl: "==informes/boletinFinalAlumnoPreescolarDir.tpl.html"
	scope:
		grupo: "="
		year: "="
		alumno: "="
		config: "="

	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if

		scope.USER = Perfil.User()
		scope.USER.nota_minima_aceptada = parseInt(scope.USER.nota_minima_aceptada)
		scope.perfilPath = App.images+'perfil/'
		scope.views = App.views;

		scope.eliminar_frase = (frase)->
			console.log(frase);
			$http.put('::bolfinales-preescolar/eliminar-frase', { id: frase.id }).then((r)->
				toastr.success('Frase eliminada. Recargue.');

			, ()->
				toastr.error('No se pudo eliminar frase')
			)

		#console.log scope.config.orientacion
])




.filter('promedioPeriodo', [ ->
	(input, periodo_id) ->

		suma = 0
		for asig in input

			for defini in asig.definitivas
				if defini.periodo_id
					if parseFloat(defini.periodo_id) == parseFloat(periodo_id)
						suma += parseFloat(defini.DefMateria)

		promedio = suma / input.length


		return promedio
])






